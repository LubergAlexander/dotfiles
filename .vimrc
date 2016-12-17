set nocompatible

" load vim-plug
source ~/.plugins.vim

silent !mkdir -p ~/.vim/backup
silent !mkdir -p ~/.vim/temp
silent !mkdir -p ~/.vim/undo

" to keep backups out of file's dir
set backup
set backupdir=$HOME/.vim/backup
set directory=$HOME/.vim/temp

" to be able to undo after closing the file (persistent undo)
set undofile                " Save undo's after file closes
set undodir=$HOME/.vim/undo " where to save undo histories
set undolevels=1000         " How many undos
set undoreload=10000        " number of lines to save for undo

" solid vertical separator
set fillchars=vert:\│

" relative + current line number
set relativenumber
highlight LineNr ctermfg=grey

" Invisible character colors
highlight NonText ctermfg=Black
highlight SpecialKey ctermfg=Black


" Filetype settings
augroup filetypedetect
  au! BufRead,BufNewFile *.m, set filetype=matlab
augroup END

