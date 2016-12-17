" =============================================================================
" Plugin Manager Setup
" =============================================================================
"
if empty(glob('~/.vim/autoload/plug.vim'))
 silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnTer * PlugInstall 40 | source ~/.vim.plug
endif
call plug#begin("~/.vim/bundle")

" == General editor plugins ==
Plug 'tpope/vim-sensible'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-commentary'
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }

Plug 'scrooloose/nerdtree', { 'on':  'NERDTreeToggle' } "{{{
  " NerdTree on CMD-1 as in IntelliJ
  map <F2> :NERDTreeToggle<CR>
  let NERDChristmasTree = 1
  let NERDTreeHighlightCursorline = 1
"}}}

Plug 'jiangmiao/auto-pairs'
Plug 'airblade/vim-gitgutter' "{{{
  set updatetime=250
  let g:gitgutter_sign_added = '░'
  let g:gitgutter_sign_modified = '░'
  let g:gitgutter_sign_removed = '░'
  let g:gitgutter_sign_removed_first_line = '░'
  let g:gitgutter_sign_modified_removed = '░'
"}}}
Plug 'nathanaelkane/vim-indent-guides'

Plug 'AndrewRadev/switch.vim' "{{{
  " For switch.vim hotkey for toggle boolean options
  nnoremap <C-t> :Switch<cr>
  inoremap <C-t> <ESC>:Switch<CR>gi
"}}}

Plug 'hallison/vim-markdown'
Plug 'editorconfig/editorconfig-vim'

Plug 'dracula/vim' "{{{
  syntax on
  set t_Co=256
  set background=dark
  silent! colorscheme dracula
  let g:airline_theme='dracula'
"}}}

Plug 'vim-airline/vim-airline' "{{{
  let g:airline_powerline_fonts = 1
  let g:airline#extensions#tabline#enabled = 1
  let g:airline_section_error = '%{ALEGetStatusLine()}'
"}}}

" Automatic indenting style
Plug 'tpope/vim-sleuth'

" == JavaScript syntax highlighting ==
Plug 'othree/yajs.vim', { 'for': ['javascript', 'javascript.jsx'] }
Plug 'othree/es.next.syntax.vim', { 'for': ['javascript', 'javascript.jsx'] }
Plug 'pangloss/vim-javascript', { 'for': ['javascript', 'javascript.jsx'] }
Plug 'mxw/vim-jsx', { 'for': ['javascript', 'javascript.jsx'] }
Plug 'othree/javascript-libraries-syntax.vim', { 'for': ['javascript', 'javascript.jsx'] }

" == Linter ==
Plug 'w0rp/ale' "{{{
  let g:ale_linters = {
     \ 'javascript': ['eslint'],
  \ }
  let g:ale_statusline_format = ['⨉ %d', '⚠ %d', '⬥ ok']
  let g:ale_sign_error = '⨉'
  let g:ale_sign_warning = '⚠'
  nmap <silent> <C-k> <Plug>(ale_previous_wrap)
  nmap <silent> <C-j> <Plug>(ale_next_wrap)
"}}}
" == Octave plugins ==
Plug 'vim-scripts/octave.vim'

call plug#end()
