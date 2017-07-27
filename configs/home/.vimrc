function! Vundle()
    set nocompatible              " be iMproved, required
    filetype off                  " required

    " set the runtime path to include Vundle and initialize
    set rtp+=~/.vim/bundle/Vundle.vim
    call vundle#begin()
    " alternatively, pass a path where Vundle should install plugins
    "call vundle#begin('~/some/path/here')

    " let Vundle manage Vundle, required
    Plugin 'gmarik/Vundle.vim'

    " The following are vim packages
    Plugin 'tpope/vim-fugitive'
    Plugin 'tpope/vim-surround'
    Plugin 'tomtom/tcomment_vim'
    Plugin 'scrooloose/nerdtree'
    Plugin 'jistr/vim-nerdtree-tabs'
    Plugin 'derekwyatt/vim-fswitch'
    Plugin 'scrooloose/syntastic'
    Plugin 'bronson/vim-trailing-whitespace'
    Plugin 'petRUShka/vim-opencl'
    Plugin 'bling/vim-airline'
    Plugin 'kien/ctrlp.vim'
    Plugin 'vim-scripts/EasyGrep'
    Plugin 'klen/python-mode'
    Plugin 'kris89/vim-multiple-cursors'
    Plugin 'junegunn/fzf'
    Plugin 'vim-scripts/AnsiEsc.vim'
    Plugin 'craigemery/vim-autotag'
    Plugin 'vim-scripts/camelcasemotion'
    Plugin 'reedes/vim-pencil'
    Plugin 'inside/vim-search-pulse'
    Plugin 'ludovicchabant/vim-gutentags'
    Plugin 'skammer/vim-css-color'

    " All of your Plugins must be added before the following line'
    call vundle#end()            " required
    filetype plugin indent on    " required
    " To ignore plugin indent changes, instead use:
    " filetype plugin on

    " Brief help
    " :PluginList       - lists configured plugins
    " :PluginInstall    - installs plugins; append `!` to update or just
    " :PluginSearch foo - searches for foo; append `!` to refresh local cache
    " :PluginClean      - confirms removal of unused plugins; append `!` to
    " auto-approve removal

    " see :h vundle for more details or wiki for FAQ
    " Put your non-Plugin stuff after this line
endfunction

function! StartUp()
    autocmd VimEnter * if argc() == 0 | NERDTree | endif
endfunction

function! EditorAppearance()
    syntax on
    set laststatus=2
    set number
    set showtabline=2
    set t_Co=256
    colorscheme eyecandy
    set cursorline
    set fillchars=" split char
    set encoding=utf-8

    " let terminal resize scale the internal windows
    autocmd VimResized * :wincmd =
endfunction

function! EditorBehaviour()
    filetype plugin indent on
    set backupdir=/tmp
    set directory=/tmp
    set title
    set visualbell
    set noerrorbells
    set history=1000
    set undolevels=1000
    set showmatch
    set ignorecase
    set autoindent
    set copyindent
    set shiftround
    set backspace=indent,eol,start
    set smartcase
    set smarttab
    set hlsearch
    set incsearch
    set mouse=a  " enable mouse
    set scrolloff=10  " top/bottom padding when scrolling

    " remove trailing whitespace automatically when saving
    autocmd FileType c,cpp,java,php,python,javascript,markdown
            \ autocmd BufWritePre <buffer> :%s/\s\+$//e

    " reload vimrc after update
    " autocmd BufWritePost .vimrc so ~/.vimrc

    " correct filetype recognition
    autocmd BufRead,BufNewFile *.h set filetype=c
    autocmd FileType c call CMode()
    autocmd FileType java call JavaMode()
    autocmd BufRead /tmp/mutt-* call Mutt()
    " autocmd BufNewFile,BufReadPost *.md set filetype=markdown

    " plain text mode
    autocmd FileType vim,text,mkd call PlainText()
    autocmd BufNewFile,BufRead *.tex call PlainText()
    " autocmd FileType markdown,mkd
    "     \ call pencil#init({"wrap": "hard"})


    " reselect block after indentation
    vnoremap < <gv
    vnoremap > >gv

    map w ,w
    map b ,b

    " restore cursor's last position in file
    autocmd BufReadPost *
        \ if line("'\"") > 0 && line("'\"") <= line("$") |
        \   exe "normal! g`\"" |
        \ endif

    " highlight non-ascii characters
    set listchars=nbsp:¬,eol:¶,tab:>-,extends:»,precedes:«,trail:•

    " softwrap lines
    command! -range=% SoftWrap
        \ <line2>put _ |
        \ <line1>,<line2>g/.\+/ .;-/^$/ join |normal $x


    " scroll to top when jusing jump-to in ctags
    nnoremap <C-]> <C-]>zt
    nnoremap <C-t> <C-t>zt

    " keep search matches in the middle of the screen
    nnoremap n nzz
    nnoremap N Nzz

    " gutentags tag files directory
    let g:gutentags_cache_dir = expand("~/.tags")

endfunction

function! DefaultCodingStyle()
    set tabstop=4
    set shiftwidth=4
    set softtabstop=4
    set expandtab " expand tabs as spaces

    autocmd FileType c setlocal tabstop=4 shiftwidth=4 softtabstop=4
    autocmd FileType cpp setlocal tabstop=4 shiftwidth=4 softtabstop=4
    autocmd FileType javascript setlocal tabstop=2 shiftwidth=2 softtabstop=2
    autocmd FileType html setlocal tabstop=2 shiftwidth=2 softtabstop=2
    autocmd FileType java setlocal tabstop=2 shiftwidth=2 softtabstop=2

    " highlight when code is over 80 columns
    augroup vimrc_autocmds
        autocmd BufEnter * highlight OverLength ctermbg=darkgrey
        autocmd BufEnter * match OverLength /\%80v.*/
    augroup END
endfunction

function! CommandModeKeyMappings()
    map <C-h> <C-w>h
    map <C-l> <C-w>l
    map <S-x> :wq<CR>
    cmap w!! w !sudo tee % >/dev/null
    nmap <silent> ,/ :nohlsearch<CR>

    set pastetoggle=<F10>

    " run script file
    map <S-r> :!clear && bash run.sh<CR>
    nnoremap <F12> :tabnew<CR>:e run.sh<CR>

    " Show syntax highlighting groups for word under cursor
    nmap <C-G> :call <SID>SynStack()<CR>
endfunction

function! NavImproved()
    nnoremap j gj
    nnoremap k gk
    vnoremap j gj
    vnoremap k gk
endfunction

function! VimTabsKeyMappings()
    map <C-k> :tabr<cr>
    map <C-j> :tabl<cr>
    map <C-h> :tabp<cr>
    map <C-l> :tabn<cr>
endfunction

function! VimSplitsKeyMappings()
    map <S-k> :wincmd k<CR>
    map <S-j> :wincmd j<CR>
    map <S-h> :wincmd h<CR>
    map <S-l> :wincmd l<CR>
endfunction

function! HeaderSwitchMappings()
    nnoremap <F7> :vsplit<CR>:FSLeft<CR>
    nnoremap <F8> :FSHere<CR>
    nnoremap <F9> :vsplit<CR>:FSRight<CR>
    nnoremap <F4> :split<CR>:FSHere<CR><CR>:resize -10<CR>
endfunction

function! EscapeCommonOperationTypos()
    cmap Wq wq
    cmap WQ wq
    map <C-n> <TAB>
endfunction

function! <SID>SynStack()
    if !exists("*synstack")
        return
    endif
    echo map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")')
endfunction

function! Multiple_cursors_before()
    echo 'Disabled autocomplete'
    let g:ycm_auto_trigger = 0  " switch off YCM temporarily
endfunction

function! Multiple_cursors_after()
    echo 'Enabled autocomplete'
    let g:ycm_auto_trigger = 1  " turn YCM back on
endfunction

function! PlainText()
    " spell checker
    set spell
    set spelllang=en_gb

    " do not highlight extra whitespace
    autocmd ColorScheme * highlight ExtraWhitespace ctermbg=None guibg=None
endfunction

function! SyntasticOptions()
    " c specific settings
    let g:syntastic_c_config_file='.syntastic_config'
    let g:syntastic_enable_highlighting=1
    let g:syntastic_check_on_open=1
    let g:syntastic_enable_signs=1
    let g:syntastic_c_include_dirs=[
        \ 'include',
        \ '/usr/include',
        \ '/usr/local/include',
        \ '/usr/local/CrossPack-AVR/avr/include'
    \ ]
    let g:syntastic_c_checkers=['gcc']
    let g:syntastic_c_compiler = 'clang'
    let g:syntastic_cpp_include_dirs=[
        \ 'src'
    \ ]

    " java specific settings
    let g:syntastic_java_javac_classpath='./bin/classes:'


    " python specific settings
    let g:syntastic_python_checkers=['flake8']
    " let g:syntastic_ignore_files = ['\.py$']

    " html specific settings
    let g:syntastic_html_checkers=['']  " disable syntastic for html files

    " javascript specific settings
    let g:syntastic_javascript_checkers = ['jshint']

    " warning and error symbols
    let g:syntastic_warning_symbol       = 'W'
    let g:syntastic_error_symbol         = 'E'
    let g:syntastic_style_error_symbol   = 'SE'
    let g:syntastic_style_warning_symbol = 'SW'
endfunction

function! Airline()
    let g:airline_powerline_fonts = 0
    let g:airline#extensions#tabline#enabled = 0

    if !exists('g:airline_symbols')
        let g:airline_symbols = {}
    endif

    " unicode symbols
    let g:airline_left_sep = ''
    let g:airline_left_sep = ''
    let g:airline_right_sep = ''
    let g:airline_right_sep = ''
endfunction

function! NerdTree()
    nnoremap <F3> :NERDTreeTabsToggle<CR><CR>
    " let g:NERDTreeDirArrows=0
    let g:NERDTreeWinSize=30 " set NerdTree size
    let g:NERDTreeWinPos='left'

    " if NerdTree is last thing open in vim, close vim completely
    autocmd bufenter * if (
            \ winnr("$") == 1
            \ && exists("b:NERDTreeType")
            \ && b:NERDTreeType == "primary")
            \ | q |
    \ endif

    " switch off dir arrows
    " let g:NERDTreeDirArrows=0
endfunction

function! CMode()
    " shortcut key to bring up corresponding unit test
    map <S-t> :vsplit %:s?src?tests?:r_test.c<CR>

    " header shortcuts
    call HeaderSwitchMappings()
endfunction

function! EasyGrep()
    let g:EasyGrepRecursive=1
    let g:EasyGrepReplaceWindowMode=2
endfunction

function! VimCompletesMe()
    " prevent enter key from creating new line when selecting complete
    inoremap <expr> <CR> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"
endfunction

function! PythonMode()
    let g:pymode_lint=1
    let g:pymode_folding=0
    let g:pymode_doc=0
    let g:pymode_lint_on_fly=0
    let g:pymode_rope_completion=0
    let g:pymode_options_colorcolumn=0

    " shortcut key to bring up corresponding unit test
    " map <S-t> :vsplit %:s?:h?tests?:r_tests.py<CR>
endfunction




" MAIN
call Vundle()
call StartUp()
call EditorAppearance()
call EditorBehaviour()
call CommandModeKeyMappings()
call DefaultCodingStyle()
call NavImproved()
call VimTabsKeyMappings()
call VimSplitsKeyMappings()
call EscapeCommonOperationTypos()

" PLUGIN SETTINGS
call Airline()
call SyntasticOptions()
call NerdTree()
call EasyGrep()
call VimCompletesMe()
call PythonMode()
