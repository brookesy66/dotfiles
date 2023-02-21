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
"}}}

"Prefs{{{
"=========

"set softtabstop=2 shiftwidth=2 tabstop=2 expandtab " From VTX
set shiftwidth=4 tabstop=4 expandtab   		        " Clayton's standard, using @ Grey/PI
"set tabstop=8 shiftwidth=8                         " kernel standard
let g:netrw_browsex_viewer= "xdg-open"

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
set wildoptions=pum             "popup wildmenu
set fdm=syntax                  "folding by syntax
set foldenable!                 "start with all folds open, close with <z-i>
set textwidth=100               "sets line at which gq wraps text
set completeopt=popup,menuone   "use popup window, not preview
set t_RV=                       "fix issue with devicons/airline having junk

"Default to colour scheme set by wal, use F keys to change if it's shit
"colorscheme wal
let g:dracula_colorterm = 0 "remove grey shade background
colorscheme dracula

"Settings for colorcolumn, only set if coding
au FileType c,cs,cpp,python,rust,sh set colorcolumn=81,101
"highlight ColorColumn ctermbg=234 " looks like removing this ensures cc is
"that grey colour always

"Omnicompletion
filetype plugin on
set omnifunc=syntaxcomplete#Complete

"}}}

"Mappings{{{
"============

"Toggle number lines
map <F2> :set number! <bar> set relativenumber! <CR>

"Insert current date as YYYY-MM-DD Day format
map <F3> :r! date +\%F" "\%A <CR> <bar> kdd

"Switch colorscheme to use wal
map <F9> :colorscheme wal <CR>

"Switch colorscheme to jellybeans
map <F10> :colorscheme jellybeans <CR>

" Allow saving of files as sudo when I forget to start vim using sudo.
cmap w!! w !sudo tee /dev/null %

"Tmux-like resizing shortcuts
noremap <C-w><C-y> <C-w>10<
noremap <C-w><C-o> <C-w>10>
noremap <C-w><C-u> <C-w>10-
noremap <C-w><C-i> <C-w>10+
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
""msbuild for make
if IsWSL()
    au FileType cs set makeprg='/mnt/c/Program\ Files\ \(x86\)/Microsoft\ Visual\ Studio/2019/Professional/MSBuild/Current/Bin/MSBuild.exe'\ /nologo\ /v:q\ /property:Platform='x64',WarningLevel=0
    au FileType cs set errorformat=\ %#%f(%l\\\,%c):\ %m
endif

"Python
au FileType python set fdm=indent
au FileType python set foldlevel=1
au FileType python set textwidth=80


":}}}

"Plugins{{{
"===========

""auto remove whitespace
autocmd BufEnter * EnableStripWhitespaceOnSave
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

"""multiple
let wiki_1 = {}
let wiki_1.path = '~/vimwiki'
let wiki_2 = {}
let wiki_2.path = '~/vimwiki/work/wgb-wiki'
let g:vimwiki_list = [wiki_1, wiki_2]

"""folding
let g:vimwiki_folding='custom'
au BufNewFile,BufRead,BufReadPost *.wiki set fdm=syntax
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

""OmniSharp
filetype indent on                          "apparently required for the plugin to work
let g:OmniSharp_highlighting = 0            "disable omnisharp highlighting
let g:OmniSharp_server_stdio = 1            "use the stdio OmniSharp-roslyn server
let g:OmniSharp_timeout = 5                 "timeout in seconds to wait for a response from the server
if IsWSL()
    "let g:OmniSharp_server_path = '/mnt/c/Users/william.brookes/omnisharp-win-x64/OmniSharp.exe'
    let g:OmniSharp_translate_cygwin_wsl = 1    "needed to convert windows and linux paths
    let g:OmniSharp_server_use_mono = 0
else
    let g:OmniSharp_server_use_mono = 1
endif
let g:ale_linters = { 'cs': ['OmniSharp'] } "Tell ALE to use OmniSharp for linting C# files, and no other linters.
augroup omnisharp_commands
    autocmd!

    "The following commands are contextual, based on the cursor position.
    autocmd FileType cs nnoremap <buffer> <C-]> :OmniSharpGotoDefinition<CR>
    autocmd FileType cs nnoremap <buffer> <Leader>dp :OmniSharpPreviewDefinition<CR>
    autocmd FileType cs nnoremap <buffer> <Leader>fi :OmniSharpFindImplementations<CR>
    autocmd FileType cs nnoremap <buffer> <Leader>fs :OmniSharpFindSymbol<CR>
    autocmd FileType cs nnoremap <buffer> <Leader>fu :OmniSharpFindUsages<CR>

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
autocmd BufWritePre *.py execute ':Black'

""YCM
let g:ycm_always_populate_location_list = 1 "use location list
let g:ycm_autoclose_preview_window_after_completion = 1


"" ALE
au FileType python  nmap <C-]> <Plug>(ale_go_to_definition)
au FileType python  nmap <Leader>fu <Plug>(ale_find_references)
au FileType python  nmap <silent> <Leader>fu :ALEFindReferences -quickfix<CR>
au FileType python  nmap <Leader>dc <Plug>(ale_documentation)
au FileType python  nmap <Leader>dp <Plug>(ale_hover)
let g:ale_floating_preview=1
let g:ale_hover_cursor=0 " don't hover by default


"FZF
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


"" Vimtest
nmap <silent> <leader>t :TestNearest<CR>
nmap <silent> <leader>T :TestFile<CR>
nmap <silent> <leader>a :TestSuite<CR>
nmap <silent> <leader>l :TestLast<CR>
nmap <silent> <leader>g :TestVisit<CR>
let test#strategy = "make"
