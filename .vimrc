" vim:fileencoding=utf-8:foldmethod=marker:cc=:foldlevel=0

"Plug{{{
"========

if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('~/.vim/plugged')

Plug 'vimwiki/vimwiki'                              " wiki/diary plugin
"Plug 'ntpeters/vim-better-whitespace'               " better handling of whitespace
Plug 'nanotech/jellybeans.vim'                      " a nice colorscheme
Plug 'chrisbra/csv.vim'                             " CSV file manipulation
Plug 'OmniSharp/omnisharp-vim'                      " C# IDE-like plugin
Plug 'tpope/vim-fugitive'                           " powerful Git plugin
Plug 'junegunn/gv.vim'                              " Git commit browser - uses fugitive
Plug 'shime/vim-livedown'                           " markdown plugin
Plug 'Valloric/YouCompleteMe'                       " auto completion
"Plug 'vim/killersheep'                             " funny game
Plug 'dracula/vim', { 'as': 'dracula' }             " dracula colorscheme
Plug 'lifepillar/vim-solarized8'
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

"Prefs{{{
"=========

let mapleader = " "             "set before any <leader> mappings are defined

"set softtabstop=2 shiftwidth=2 tabstop=2 expandtab " From VTX
set shiftwidth=4 tabstop=4 expandtab   		        " Clayton's standard, using @ Grey/PI
"set tabstop=8 shiftwidth=8                         " kernel standard

set relativenumber
set number
set background=dark
set t_Co=256
set history=1000
set scrolloff=3                 "keep some context above/below the cursor
set undofile                    "persistent undo across sessions
set undodir=~/.vim/undo
if !isdirectory(expand(&undodir))
    call mkdir(expand(&undodir), 'p')
endif
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
set wildoptions=pum             "popup wildmenu
set fdm=syntax                  "folding by syntax
set nofoldenable                "start with all folds open, close with <z-i>
set textwidth=100               "sets line at which gq wraps text
set completeopt=popup,menuone   "use popup window, not preview
set t_RV=                       "fix issue with devicons/airline having junk
set exrc
set secure
"set spell spelllang=en_au       "turn spell on. FUck spell

"Omnicompletion
set omnifunc=syntaxcomplete#Complete

"Built-in optional packages shipped with Vim 9.2
packadd! comment                "gc/gcc to toggle comments
packadd! hlyank                 "briefly highlight yanked text

"}}}

"Autocommands{{{
"===============

augroup vimrc
autocmd!

"Settings for colorcolumn, only set if coding
au FileType c,cs,cpp,python,rust,sh setlocal colorcolumn=81,101

"Set arduino syntax to c
au BufNewFile,BufRead,BufReadPost *.ino setlocal syntax=c

"Makefile syntax
au FileType make setlocal noexpandtab shiftwidth=8 softtabstop=0

"Addition of wsd as plantuml files
au BufNewFile,BufRead *.wsd setlocal syntax=plantuml

"XML syntax for XAML files
au BufNewFile,BufRead *.xaml setlocal syntax=xml

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
au FileType cs setlocal foldmethod=marker
au FileType cs setlocal foldmarker={,}
au FileType cs setlocal foldtext=substitute(getline(v:foldstart),'{.*','{...}',)
au FileType cs setlocal foldlevel=2
au FileType cs setlocal nofoldenable "start with all folds open

"Python
au FileType python setlocal fdm=indent
au FileType python setlocal foldlevel=1
au FileType python setlocal textwidth=80

"Vimwiki
au BufNewFile,BufRead,BufReadPost *.wiki setlocal foldlevel=1
"ALE and YCM are both off here (too slow), so strip whitespace and complete
"file paths natively. <C-f> in insert mode completes relative to the file.
au BufWritePre *.wiki call s:StripWhitespace()
au FileType vimwiki setlocal completefunc=WikiPathComplete
au FileType vimwiki inoremap <buffer> <C-f> <C-x><C-u>

"YCM mappings for C/C++ (buffer-local so they don't clobber tags elsewhere).
"YCM's clangd is the only language server for C/C++; ALE is disabled for them.
au FileType cpp,c  nmap <buffer> <C-]> :YcmCompleter GoToDefinition<CR>
au FileType cpp,c  nmap <buffer> <silent> <Leader>u :YcmCompleter GoToReferences<CR>
au FileType cpp,c  nmap <buffer> <Leader>dc :YcmCompleter GetDoc<CR>
au FileType cpp,c  nmap <buffer> <Leader>dp <plug>(YCMHover)
au FileType cpp,c  nmap <buffer> <Leader>dd :YcmDiags<CR>
au FileType cpp,c  nmap <buffer> <Leader>h :YcmCompleter GoToAlternateFile<CR>
au FileType cpp,c  nmap <buffer> <Leader>rn :YcmCompleter RefactorRename<Space>

"ALE mappings (buffer-local so they don't clobber tags in other filetypes)
au FileType python,rust  nmap <buffer> <C-]> <Plug>(ale_go_to_definition)
au FileType python,rust  nmap <buffer> <silent> <Leader>u :ALEFindReferences -quickfix<CR>
au FileType python,rust  nmap <buffer> <Leader>dc <Plug>(ale_documentation)
au FileType python,rust  nmap <buffer> <Leader>dp <Plug>(ale_hover)
au FileType vimwiki let b:ale_enabled = 0 " ALE chugs here

augroup END

":}}}

"Plugins{{{
"===========

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
"must come after the overrides above or they are ignored
colorscheme jellybeans

""VimWiki
nmap <Leader>wv <Plug>VimwikiVSplitLink
nmap <Leader>wt <Plug>VimwikiTabnewLink

"strip trailing whitespace and trailing blank lines, keeping the view
function! s:StripWhitespace() abort
    let l:view = winsaveview()
    silent! keeppatterns %s/\s\+$//e
    silent! keeppatterns %s/\n\+\%$//e
    call winrestview(l:view)
endfunction

"completefunc: complete paths relative to the current file's directory
"(absolute and ~ paths work too). .wiki is dropped as vimwiki links omit it.
function! WikiPathComplete(findstart, base) abort
    if a:findstart
        return match(getline('.')[: col('.') - 2], '\f*$')
    endif
    let l:abs = a:base =~# '^[/~]'
    let l:dir = l:abs ? '' : expand('%:p:h') . '/'
    let l:res = []
    for l:p in glob(l:dir . a:base . '*', 0, 1)
        let l:word = l:abs ? a:base . l:p[len(expand(a:base)):] : l:p[len(l:dir):]
        if isdirectory(l:p)
            call add(l:res, {'word': l:word . '/', 'menu': '[dir]'})
        else
            call add(l:res, {'word': substitute(l:word, '\.wiki$', '', ''), 'menu': '[file]'})
        endif
    endfor
    return l:res
endfunction

"""multiple
let wiki_1 = {}
let wiki_1.path = '~/vimwiki'
let wiki_2 = {}
let wiki_2.path = '~/vimwiki/work/wgb-wiki'
let g:vimwiki_list = [wiki_1, wiki_2]

"""folding
let g:vimwiki_folding='expr'

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
let g:OmniSharp_highlighting = 0            "disable omnisharp highlighting
let g:OmniSharp_server_stdio = 1            "use the stdio OmniSharp-roslyn server
let g:OmniSharp_timeout = 5                 "timeout in seconds to wait for a response from the server
"let g:OmniSharp_server_use_mono = 1
let g:OmniSharp_server_use_net6 = 1 "Had to set this to use .net7 sdk on emerald. msbuild too old
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

""YCM
let g:ycm_clangd_args = ['--background-index-priority=normal']
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
let g:ycm_language_server =
    \ [
    \   {
    \     'name': 'lua',
    \     'cmdline': ['lua-language-server'],
    \     'filetypes': ['lua'],
    \   },
    \ ]

""ALE (mappings are in the Autocommands section)
let g:ale_floating_preview=1
let g:ale_hover_cursor=0 " don't hover by default
let g:ale_fixers = {
            \ '*': ['trim_whitespace', 'remove_trailing_lines'],
            \ 'python': ['isort', 'black'],
            \ 'cpp': ['clang-format'],
            \ }
let g:ale_linters = {
            \ 'cs': ['OmniSharp'],
            \ 'python': ['ruff', 'mypy', 'pyright'],
            \ 'cpp': [],
            \ 'c': [],
            \ }
let g:ale_fix_on_save = 1
let g:ale_virtualenv_dir_names = ['.venv']


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
noremap <leader>a :Rg<cr>
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
nnoremap <F2> :set number! <bar> set relativenumber!<CR>

"Insert current date as YYYY-MM-DD Day format
nnoremap <F9> :r! date +\%F" "\%A<CR>

"Wrap word in backticks
nnoremap <F10> cw`<C-r>"`<Esc>

" Toggle spell
nnoremap <F7> :set spell!<CR>

" Allow saving of files as sudo when I forget to start vim using sudo.
cnoremap w!! w !sudo tee /dev/null %

"Tmux-like resizing shortcuts
noremap <C-w><C-y> <C-w>10<
noremap <C-w><C-o> <C-w>10>
noremap <C-w><C-u> <C-w>10-
noremap <C-w><C-i> <C-w>10+

"}}}
