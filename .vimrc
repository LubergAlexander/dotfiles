set nocompatible
filetype off
filetype plugin indent on

" Setting up Vundle - the vim plugin bundler
    let iCanHazVundle=1
    let vundle_readme=expand('~/.vim/bundle/vundle/README.md')
    if !filereadable(vundle_readme)
        echo "Installing Vundle.."
        echo ""
        silent !mkdir -p ~/.vim/bundle
        silent !git clone https://github.com/gmarik/vundle ~/.vim/bundle/vundle
        let iCanHazVundle=0
    endif
    set rtp+=~/.vim/bundle/vundle/
    call vundle#rc()
    Bundle 'gmarik/vundle'
    "Add your bundles here
    Bundle 'kien/ctrlp.vim'
    Bundle 'tpope/vim-fugitive'
    Bundle 'scrooloose/nerdtree'
    Bundle 'scrooloose/nerdcommenter'
    Bundle 'klen/python-mode'
    Bundle 'altercation/vim-colors-solarized'
    Bundle 'sickill/vim-monokai'
    Bundle 'mileszs/ack.vim'
    Bundle 'msanders/snipmate.vim'
    Bundle 'vim-python-virtualenv'
    Bundle 'vim-django-support'
    Bundle 'fholgado/minibufexpl.vim'
    Bundle 'vim-scripts/DirDiff.vim'
    Bundle 'AndrewRadev/switch.vim'
    "Bundle 'Lokaltog/powerline' " Powerline for everything in python
    "   "...All your other bundles...
    if iCanHazVundle == 0
        echo "Installing Bundles, please ignore key map error messages"
        echo ""
        :BundleInstall
    endif
" Setting up Vundle - the vim plugin bundler end


" My plugins

" to keep backups out of file's dir
set backup
set backupdir=$HOME/.vim/backup
set directory=$HOME/.vim/temp
set encoding=utf-8

set rtp+=~/Code/powerline/powerline/bindings/vim
" VIM settings
syntax on
set t_Co=256
set number
set background=dark
colorscheme solarized
set fillchars+=vert:\ 
"Invisible character colors
highlight NonText ctermfg=Black
highlight SpecialKey ctermfg=Black

set title
set visualbell
set linebreak
set showcmd
set whichwrap=b,s,<,>,[,],l,h
set completeopt=menu,preview
set infercase
set cmdheight=1
set autoindent
set smartindent
set expandtab
set smarttab
set shiftwidth=4
set softtabstop=4
set shiftround
set history=400
set viminfo+=h
set hlsearch
set ignorecase
set smartcase
set incsearch
set showmatch
set matchpairs+=<:>
set wildmenu
set wildcharm=<TAB>
set wildignore=*.pyc
set laststatus=2
set ambiwidth=double
" Powerline configuration
let g:powerline_symbols = 'fancy'
let g:Powerline_colorscheme='solarized256'
set noshowmode


set foldmethod=indent
set foldnestmax=10
set nofoldenable
set foldlevel=1



" This is to hide a documentation window once I choose the completion
" If you prefer the Omni-Completion tip window to close when a selection is
" made, these lines close it on movement in insert mode or when leaving
" " insert mode
autocmd CursorMovedI * if pumvisible() == 0|pclose|endif
autocmd InsertLeave * if pumvisible() == 0|pclose|endif

" Rope settings
let g:pymode_rope_guess_project = 0
"fix autoident after pasting
inoremap <silent> <C-u> <ESC>u:set paste<CR>.:set nopaste<CR>gi

if has("autocmd")
    autocmd BufWritePre *.py,*.js :call <SID>StripTrailingWhitespaces()
endif

nmap <Esc>[D <<
nmap <Esc>[C >>
vmap <Esc>[D <gv
vmap <Esc>[C >gv
nmap <Esc>[A G
nmap <Esc>[B gg

nnoremap <silent> <F5> :call <SID>StripTrailingWhitespaces()<CR>
function! <SID>StripTrailingWhitespaces()
    let _s=@/
    let l = line(".")
    let c = col(".")
    %s/\s\+$//e
    let @/=_s
    call cursor(l,c)
endfunction


" For Mac clipboard support
" set clipboard=unnamed

nmap <C-n> :bn<cr>
nmap <C-p> :bp<cr>
let g:ctrlp_map = '<c-p>'
let g:ctrlp_cmd = 'CtrlPMixed'
let g:ctrlp_working_path_mode = 'ra'

" For switch.vim hotkey for toggle boolean options
nnoremap <C-t> :Switch<cr>
inoremap <C-t> <ESC>:Switch<CR>gi

