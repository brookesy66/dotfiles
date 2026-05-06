" vim:fileencoding=utf-8:foldmethod=marker:cc=:foldlevel=0

"Plug{{{
"========

if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('~/.vim/plugged')

Plug 'ntpeters/vim-better-whitespace'               " better handling of whitespace
Plug 'nanotech/jellybeans.vim'                      " a nice colorscheme
"Plug 'chrisbra/csv.vim'                            " CSV file manipulation
Plug 'vimwiki/vimwiki'                              " wiki/diary plugin
Plug 'OmniSharp/omnisharp-vim'                      " C# IDE-like plugin
Plug 'tpope/vim-fugitive'                           " powerful Git plugin
Plug 'junegunn/gv.vim'                              " Git commit browser - uses fugitive
Plug 'git://github.com/shime/vim-livedown'          " markdown plugin
Plug 'psf/black', { 'branch': 'stable' }            " python formatting
Plug 'Valloric/YouCompleteMe'                       " auto completion
"Plug 'vim/killersheep'                             " funny game
Plug 'dylanaraps/wal.vim'                           " sync colorscheme from pywal
Plug 'dracula/vim', { 'as': 'dracula' }             " dracula colorscheme
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } } " fuzzy search finder
Plug 'junegunn/fzf.vim'                             " fuzzy search finder
Plug 'preservim/nerdtree'                           " nerdtree file browser
Plug 'vim-airline/vim-airline'                      " status line bar
Plug 'vim-airline/vim-airline-themes'               " status line bar
Plug 'ryanoasis/vim-devicons'                       " show icons in vim statusline etc
Plug 'dense-analysis/ale'                           " linter
Plug 'vim-test/vim-test'
Plug 'mzlogin/vim-markdown-toc'                     " markdown TOC generator
Plug 'puremourning/vimspector', { 'for': ['python', 'cpp'] }
Plug 'szw/vim-maximizer'


call plug#end()
"}}}

"Functions{{{
"=============

"function to check WSL
function! IsWSL()
    if has("unix")
        let lines = readfile("/proc/version")
        if lines[0] =~ "Microsoft"
            return 1
        endif
    endif
    return 0
endfunction

"Copy current file path to Windows clipboard
command! CopyPath execute '!echo %:p | clip.exe'

" Fast diary index for the daily wiki: avoids reading every file by
" computing the weekday from the filename. ~instant for 1000+ entries.
function! DiaryFastIndex() abort
  let l:diary_path = expand('~/vimwiki/diary')
  let l:files = glob(l:diary_path . '/[0-9]*.wiki', 0, 1)
  let l:month_names = ['January','February','March','April','May','June',
        \ 'July','August','September','October','November','December']

  let l:by_year = {}
  for l:f in l:files
    let l:base = fnamemodify(l:f, ':t:r')
    let l:m = matchlist(l:base, '\v^(\d{4})-(\d{2})-(\d{2})$')
    if empty(l:m) | continue | endif
    let [l:y, l:mo] = [l:m[1], l:m[2]]
    if !has_key(l:by_year, l:y) | let l:by_year[l:y] = {} | endif
    if !has_key(l:by_year[l:y], l:mo) | let l:by_year[l:y][l:mo] = [] | endif
    call add(l:by_year[l:y][l:mo], l:base)
  endfor

  let l:lines = ['= Diary =']
  for l:y in reverse(sort(keys(l:by_year)))
    call add(l:lines, '== ' . l:y . ' ==')
    call add(l:lines, '')
    for l:mo in reverse(sort(keys(l:by_year[l:y])))
      call add(l:lines, '=== ' . l:month_names[str2nr(l:mo) - 1] . ' ===')
      for l:date in reverse(sort(l:by_year[l:y][l:mo]))
        let l:weekday = strftime('%A', strptime('%Y-%m-%d', l:date))
        call add(l:lines, '    - [[' . l:date . '|' . l:date . ' ' . l:weekday . ']]')
      endfor
      call add(l:lines, '')
    endfor
  endfor

  call writefile(l:lines, l:diary_path . '/diary.wiki')
  echo 'DiaryFastIndex: wrote ' . len(l:files) . ' entries'
endfunction
command! DiaryFastIndex call DiaryFastIndex()

" Roll yesterday's diary forward into today's: carry over summary sections
" (everything above == Yesterday ==), seed Yesterday's === Non-Summary ===
" with yesterday's Today body, leave Yesterday and Today bodies empty.
" Optional arg: alternate output path (for testing).
function! DiaryRollover(...) abort
  let l:diary_path = expand('~/vimwiki/diary')
  let l:today = strftime('%Y-%m-%d')
  let l:weekday = strftime('%A')
  let l:target = a:0 >= 1 ? a:1 : (l:diary_path . '/' . l:today . '.wiki')

  if a:0 == 0 && filereadable(l:target)
    let l:meaningful = filter(readfile(l:target),
          \ 'v:val !~# ''^=\s.*\s=\s*$'' && v:val !~# ''^\s*$''')
    if !empty(l:meaningful)
      echohl WarningMsg
      echom 'DiaryRollover: ' . l:target . ' already has content — refusing'
      echohl None
      return
    endif
  endif

  " Find most recent prior dated diary
  let l:dates = []
  for l:f in glob(l:diary_path . '/[0-9]*.wiki', 0, 1)
    let l:b = fnamemodify(l:f, ':t:r')
    if l:b =~# '^\d\{4\}-\d\{2\}-\d\{2\}$' && l:b < l:today
      call add(l:dates, l:b)
    endif
  endfor

  let l:out = ['= ' . l:today . ' ' . l:weekday . ' =', '']

  if empty(l:dates)
    call extend(l:out, ['== Notes ==', '', '== Active ==', '', '== Inactive ==',
          \ '', '== Yesterday ==', '', '=== Non-Summary ===', '',
          \ '== Today ==', ''])
    call writefile(l:out, l:target)
    if a:0 == 0 | execute 'edit ' . fnameescape(l:target) | endif
    echo 'DiaryRollover: no prior diary, created stub'
    return
  endif

  let l:source_date = sort(l:dates)[-1]
  let l:source = readfile(l:diary_path . '/' . l:source_date . '.wiki')

  " Parse source by H2 headings; capture preamble (above first H2) too
  let l:sections = []
  let l:cur_h = ''
  let l:cur_b = []
  for l:line in l:source
    if l:line =~# '^==\s.\+\s==\s*$'
      if !empty(l:cur_h)
        call add(l:sections, [l:cur_h, l:cur_b])
      endif
      let l:cur_h = l:line
      let l:cur_b = []
    elseif l:line =~# '^=\s.\+\s=\s*$' && empty(l:cur_h)
      " skip source's H1
    else
      if !empty(l:cur_h)
        call add(l:cur_b, l:line)
      endif
    endif
  endfor
  if !empty(l:cur_h) | call add(l:sections, [l:cur_h, l:cur_b]) | endif

  " Carry forward sections before == Yesterday ==; capture Today body
  let l:today_body = []
  let l:hit_yest = 0
  for [l:h, l:b] in l:sections
    if l:h =~# '^==\s\+Yesterday\s\+==\s*$'
      let l:hit_yest = 1
      continue
    endif
    if l:h =~# '^==\s\+Today\s\+==\s*$'
      let l:today_body = l:b
      continue
    endif
    if !l:hit_yest
      call add(l:out, l:h)
      call extend(l:out, l:b)
    endif
  endfor

  " Trim leading/trailing blanks from Today body before nesting it
  while !empty(l:today_body) && l:today_body[0] =~# '^\s*$'
    call remove(l:today_body, 0)
  endwhile
  while !empty(l:today_body) && l:today_body[-1] =~# '^\s*$'
    call remove(l:today_body, -1)
  endwhile

  call extend(l:out, ['== Yesterday ==', '', '=== Non-Summary ===', ''])
  call extend(l:out, l:today_body)
  call extend(l:out, ['', '== Today ==', ''])

  call writefile(l:out, l:target)
  if a:0 == 0
    execute 'edit ' . fnameescape(l:target)
    call search('^== Today ==$', 'w')
    normal! 2j
  endif
  echo 'DiaryRollover: rolled forward from ' . l:source_date
endfunction
command! -nargs=? DiaryRollover call DiaryRollover(<f-args>)

"}}}

"Prefs{{{
"=========

"set softtabstop=2 shiftwidth=2 tabstop=2 expandtab " From VTX
set shiftwidth=4 tabstop=4 expandtab   		        " Clayton's standard, using @ Grey/PI
"set tabstop=8 shiftwidth=8                         " kernel standard

set relativenumber
set number
set background=dark
set t_Co=256
set history=50
set hlsearch
set autoread                    "automatically refresh files not edited by vim while open
set ruler
set visualbell                  "stop beeping
set t_vb=                       "deactivate annoying flashing
set incsearch                   "do incremental searching
set fml=3                       "min fold lines
set nowrap                      "prevent text wrapping
set ignorecase                  "required for smartcase
set smartcase                   "smartcase searching
set hidden                      "hides buffer if it is abandoned
set splitbelow splitright       "more natural window split behaviour
set wildmenu                    "cool bar when tab completing
set fdm=syntax                  "folding by syntax
set foldenable!                 "start with all folds open, close with <z-i>
set textwidth=100               "sets line at which gq wraps text
set completeopt=popup,menuone   "use popup window, not preview
set t_RV=                       "fix issue with devicons/airline having junk
"set spell spelllang=en_au       "turn spell on
set exrc                        " allow per-directory vimrc
set secure                      " disable unsafe commands in local vimrcs

" use ripgrep instead of grep. Fixes binary/directory bullshit and not finding entries sometimes
set grepprg=rg\ --vimgrep
set grepformat=%f:%l:%c:%m



let g:dracula_colorterm = 0 "remove grey shade background
colorscheme jellybeans

"Settings for colorcolumn, only set if coding
au FileType c,cs,cpp,python,rust,sh set colorcolumn=81,101
"highlight ColorColumn ctermbg=234 " looks like removing this ensures cc is
"that grey colour always

"Omnicompletion
filetype plugin on
set omnifunc=syntaxcomplete#Complete

"}}}

"Autocommands{{{
"===============

"Set arduino syntax to c
au BufNewFile,BufRead,BufReadPost *.ino set syntax=c

"Makefile syntax
autocmd FileType make set noexpandtab shiftwidth=8 softtabstop=0

"Addition of wsd as plantuml files
autocmd BufNewFile,BufRead *.wsd set syntax=plantuml

"XML syntax for XAML files
autocmd BufNewFile,BufRead *.xaml set syntax=xml

"When editing a file, always jump to the last known cursor position.
"Don't do it when the position is invalid or when inside an event handler
"(happens when dropping a file on gvim).
"Also don't do it when the mark is in the first line, that is the default
"position when opening a file.
autocmd BufReadPost *
  \ if line("'\"") > 1 && line("'\"") <= line("$") && &ft !~# 'commit' |
  \   exe "normal! g`\"" |
  \ endif

"C# Settings:
""Folding : http://vim.wikia.com/wiki/Syntax-based_folding, see comment by Ostrygen
au FileType cs set foldmethod=marker
au FileType cs set foldmarker={,}
au FileType cs set foldtext=substitute(getline(v:foldstart),'{.*','{...}',)
au FileType cs set foldlevel=2
au FileType cs set foldenable! "start with all folds open

"Python
au FileType python set fdm=indent
au FileType python set foldlevel=1
au FileType python set textwidth=80


":}}}

"Plugins{{{
"===========

""auto remove whitespace
let g:better_whitespace_enabled=1
let g:strip_whitespace_on_save=1
let g:strip_whitespace_confirm=0

""jellybeans
let g:jellybeans_use_term_italics=0
let g:jellybeans_use_lowcolor_black = 1
let g:jellybeans_overrides = {
\             'colorcolumn' : { '256ctermbg' : 234 },
\             'matchparen' : { '256ctermfg' : 'red', '256ctermbg' : 'none' },
\             'background': { 'ctermbg': 'none', '256ctermbg': 'none' },
\}
"""uncomment below & background dict for disabling shaded black background
if has('termguicolors') && &termguicolors
        let g:jellybeans_overrides['background']['guibg'] = 'none'
    endif

""VimWiki
nmap <Leader>wv <Plug>VimwikiVSplitLink
nmap <Leader>wt <Plug>VimwikiTabnewLink
" required for it to work
set nocompatible
filetype plugin on
syntax on


"""multiple
"let wiki_1 = {}
"let wiki_1.path = '~/vimwiki'
"let wiki_2 = {}
"let wiki_2.path = '~/vimwiki/work/wgb-wiki'
"let g:vimwiki_list = [wiki_1, wiki_2, { 'path': '~/vimwiki/', 'auto_tags': 1 }]
let g:vimwiki_list = [
  \ { 'path': '/home/wgb/vimwiki',          'auto_tags': 1 },
  \ { 'path': '/home/wgb/vimwiki/lonsdale', 'auto_tags': 1 },
  \ ]


"""folding
let g:vimwiki_folding='expr'
au BufNewFile,BufRead,BufReadPost *.wiki set foldlevel=1

""Ctags
set tags=./tags,tags;$HOME

""Netrw (explorer) settings
let g:netrw_banner = 0
let g:netrw_liststyle = 3
"let g:netrw_browse_split = 4 "open file vsplit
let g:netrw_altv = 1 "vsplit right
let g:netrw_winsize = 85
let g:netrw_bufsettings = 'noma nomod nu nobl nowrap ro' "line numbers
let g:netrw_browsex_viewer= "xdg-open"

""OmniSharp
filetype indent on                          "apparently required for the plugin to work
let g:OmniSharp_highlighting = 0            "disable omnisharp highlighting
let g:OmniSharp_server_stdio = 1            "use the stdio OmniSharp-roslyn server
let g:OmniSharp_timeout = 5                 "timeout in seconds to wait for a response from the server
let g:OmniSharp_translate_cygwin_wsl = 1    "needed to convert windows and linux paths
let g:OmniSharp_server_use_mono = 0
augroup omnisharp_commands
    autocmd!

    "The following commands are contextual, based on the cursor position.
    autocmd FileType cs nnoremap <buffer> <C-]> :OmniSharpGotoDefinition<CR>
    autocmd FileType cs nnoremap <buffer> <Leader>dp :OmniSharpPreviewDefinition<CR>
    autocmd FileType cs nnoremap <buffer> <Leader>fi :OmniSharpFindImplementations<CR>
    autocmd FileType cs nnoremap <buffer> <Leader>fs :OmniSharpFindSymbol<CR>
    autocmd FileType cs nnoremap <buffer> <Leader>u :OmniSharpFindUsages<CR>

    "Finds members in the current buffer
    autocmd FileType cs nnoremap <buffer> <Leader>fm :OmniSharpFindMembers<CR>

    autocmd FileType cs nnoremap <buffer> <Leader>fx :OmniSharpFixUsings<CR>
    autocmd FileType cs nnoremap <buffer> <Leader>tt :OmniSharpTypeLookup<CR>
    autocmd FileType cs nnoremap <buffer> <Leader>dc :OmniSharpDocumentation<CR>
    autocmd FileType cs nnoremap <buffer> <C-\> :OmniSharpSignatureHelp<CR>
    autocmd FileType cs inoremap <buffer> <C-\> <C-o>:OmniSharpSignatureHelp<CR>
    autocmd FileType cs nmap <silent> <buffer> <Leader>osr <Plug>(omnisharp_rename)

augroup END


""livedown
let g:livedown_browser = "firefox"
nmap gm :LivedownToggle<CR>

""black python formatter
"autocmd BufWritePre *.py execute ':Black'

""YCM
let g:ycm_always_populate_location_list = 1 "use location list
let g:ycm_autoclose_preview_window_after_completion = 1
let g:ycm_auto_hover=''
let g:ycm_key_detailed_diagnostics = '' " delete mapping
let g:ycm_filetype_blacklist = {
    \ 'tagbar': 1,
    \ 'netrw': 1,
    \ 'unite': 1,
    \ 'pandoc': 1,
    \ 'infolog': 1,
    \ 'leaderf': 1,
    \ 'vimwiki': 1
    \}

""ALE
au FileType python,cpp,c  nmap <C-]> <Plug>(ale_go_to_definition)
au FileType python,cpp,c  nmap <silent> <Leader>u :ALEFindReferences -quickfix<CR>
au FileType python,cpp,c  nmap <Leader>dc <Plug>(ale_documentation)
au FileType python,cpp,c  nmap <Leader>dp <Plug>(ale_hover)
let g:ale_floating_preview=1
let g:ale_hover_cursor=0 " don't hover by default
let g:ale_fixers = {
            \ 'python': ['isort', 'black'],
            \ 'cpp': ['clang-format'],
            \ }
let g:ale_linters = {
            \ 'cs': ['OmniSharp'],
            \ 'c': ['clangtidy'],
            \ 'python': ['ruff', 'mypy', 'pyright'],
            \ 'cpp': ['clangd'],
            \ }
let g:ale_fix_on_save = 1
let g:ale_virtualenv_dir_names = ['.venv']
autocmd FileType vimwiki let b:ale_enabled = 0 " ALE chugs here


"" FZF
let $FZF_DEFAULT_OPTS = '--bind ctrl-a:select-all'

function! s:build_quickfix_list(lines)
    call setqflist(map(copy(a:lines), '{ "filename": v:val }'))
    copen
    cc
endfunction

let g:fzf_action = {
    \ 'ctrl-q': function('s:build_quickfix_list'),
    \ 'ctrl-t': 'tab split',
    \ 'ctrl-x': 'split',
    \ 'ctrl-v': 'vsplit' }

" some cheeky shortcuts
noremap <leader>f :Files<cr>
noremap <leader>b :Buffers<cr>
noremap <leader>a :Ag<cr>
noremap <leader>l :Lines<cr>


"" Vimtest
nmap <silent> <leader>t :TestNearest<CR>
nmap <silent> <leader>T :TestFile<CR>
nmap <silent> <leader>A :TestSuite<CR>
nmap <silent> <leader>L :TestLast<CR>
nmap <silent> <leader>G :TestVisit<CR>
let test#strategy = "make"

"" NERDTREE
noremap <leader>n :NERDTree %<cr>

"" Fugitive
noremap <leader>gl :Gclog<CR>
noremap <silent> <leader>gs :Git<CR>:only<CR>


"" Vimspector
let g:vimspector_enable_mappings = 'HUMAN'

" mnemonic 'di' = 'debug inspect' (pick your own, if you prefer!)
" for normal mode - the word under the cursor
nmap <Leader>di <Plug>VimspectorBalloonEval
" for visual mode, the visually selected text
xmap <Leader>di <Plug>VimspectorBalloonEval
nmap <LocalLeader><F11> <Plug>VimspectorUpFrame
nmap <LocalLeader><F12> <Plug>VimspectorDownFrame
nmap <LocalLeader>B     <Plug>VimspectorBreakpoints
nmap <LocalLeader>D     <Plug>VimspectorDisassemble

"| Key         | Mapping                                      | Function                                           |
"|-------------|----------------------------------------------|----------------------------------------------------|
"| F5          | <Plug>VimspectorContinue                     | Continue debugging / start debugging               |
"| F3          | <Plug>VimspectorStop                         | Stop debugging                                     |
"| F4          | <Plug>VimspectorRestart                      | Restart debugging with same configuration          |
"| F6          | <Plug>VimspectorPause                        | Pause debuggee                                     |
"| F9          | <Plug>VimspectorToggleBreakpoint             | Toggle breakpoint on current line                  |
"| <leader>F9  | <Plug>VimspectorToggleConditionalBreakpoint  | Toggle conditional breakpoint or logpoint          |
"| F8          | <Plug>VimspectorAddFunctionBreakpoint        | Add function breakpoint under cursor               |
"| <leader>F8  | <Plug>VimspectorRunToCursor                  | Run to cursor                                      |
"| F10         | <Plug>VimspectorStepOver                     | Step over                                          |
"| F11         | <Plug>VimspectorStepInto                     | Step into                                          |
"| F12         | <Plug>VimspectorStepOut                      | Step out of current function                       |



"}}}

"Highlight words{{{
"===================
" Existing match patterns for each highlight group.
let g:hi_interesting_word_patterns = ['', '', '', '', '', '', '']
function! HiInterestingWord(n)
    " Save our location.
    normal! mz
    " Yank the current word into the z register.
    normal! "zyiw
    " Construct a literal pattern that has to match at boundaries.
    let pat = '\V\<' . escape(@z, '\') . '\>'
    " Attempting to highlight the same pattern will toggle the highlight.
    " Turning off a highlight for a word will turn it off for all
    " highlight groups.
    let toggled = 0
    for i in [1, 2, 3, 4, 5, 6]
      let existing_pat = get(g:hi_interesting_word_patterns, i, '')
      " Calculate an arbitrary match ID.  Hopefully nothing else is using it.
      let mid = 86750 + i
      if pat ==? existing_pat
        " Clear existing matches, but don't worry if they don't exist.
        " This is toggle highlight off.
        silent! call matchdelete(mid)
        let g:hi_interesting_word_patterns[i] = ''
        if i == a:n
          let toggled = 1
        endif
      endif
    endfor
    " Current pattern didn't match any existing?  Move highlight to new word
    if toggled == 0
      let mid = 86750 + a:n
      silent! call matchdelete(mid)
      call matchadd("InterestingWord" . a:n, pat, 1, mid)
      let g:hi_interesting_word_patterns[a:n] = pat
    endif
    " Move back to our original location.
    normal! z`
endfunction
nnoremap <silent> <leader>1 :call HiInterestingWord(1)<cr>
nnoremap <silent> <leader>2 :call HiInterestingWord(2)<cr>
nnoremap <silent> <leader>3 :call HiInterestingWord(3)<cr>
nnoremap <silent> <leader>4 :call HiInterestingWord(4)<cr>
nnoremap <silent> <leader>5 :call HiInterestingWord(5)<cr>
nnoremap <silent> <leader>6 :call HiInterestingWord(6)<cr>
function! ConfigureHiInterestingWord()
    highlight def InterestingWord1 guifg=#000000 ctermfg=16 guibg=#ffa724 ctermbg=214
    highlight def InterestingWord2 guifg=#000000 ctermfg=16 guibg=#aeee00 ctermbg=154
    highlight def InterestingWord3 guifg=#000000 ctermfg=16 guibg=#8cffba ctermbg=121
    highlight def InterestingWord4 guifg=#000000 ctermfg=16 guibg=#b88853 ctermbg=137
    highlight def InterestingWord5 guifg=#000000 ctermfg=16 guibg=#ff9eb8 ctermbg=211
    highlight def InterestingWord6 guifg=#000000 ctermfg=16 guibg=#ff2c4b ctermbg=195
endfunction
call ConfigureHiInterestingWord()
" Some colorschemes reset all custom highlights.  Use a ColorScheme
" event to retrigger addition of custom highlights.
" https://jdhao.github.io/2020/09/22/highlight_groups_cleared_in_nvim/
augroup custom_highlight
  autocmd!
  au ColorScheme * call ConfigureHiInterestingWord()
augroup END
"}}}

"Mappings{{{
"============

"Toggle number lines
map <F2> :set number! <bar> set relativenumber! <CR>

"Insert current date as YYYY-MM-DD Day format
map <F9> :r! date +\%F" "\%A <CR> <bar>

"Wrap word in backticks
nnoremap <F10> cw`<C-r>"`<Esc>

" Toggle spell
map <F7> :set spell! <CR>

" Allow saving of files as sudo when I forget to start vim using sudo.
cmap w!! w !sudo tee /dev/null %

"Tmux-like resizing shortcuts
noremap <C-w><C-y> <C-w>10<
noremap <C-w><C-o> <C-w>10>
noremap <C-w><C-u> <C-w>10-
noremap <C-w><C-i> <C-w>10+

nnoremap <SPACE> <Nop>
map <Space> <Leader>
let mapleader = "\<space>" "space as leader key
let mapleader = " " "space as leader key
"}}}
