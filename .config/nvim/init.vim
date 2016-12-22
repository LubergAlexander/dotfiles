let s:nvim_home_dir=expand("$HOME/.config/nvim")
let g:python_host_prog='/usr/local/bin/python2'
let g:python3_host_prog='/usr/local/bin/python3'

" Setup dein  ---------------------------------------------------------------{{{
if (!isdirectory(expand('$HOME/.config/nvim/repos/github.com/Shougo/dein.vim')))
  call system(expand('mkdir -p '.s:nvim_home_dir. '/repos/github.com'))
  call system(expand('git clone https://github.com/Shougo/dein.vim '.s:nvim_home_dir.'/repos/github.com/Shougo/dein.vim'))
endif

let &runtimepath.= ','.expand(s:nvim_home_dir.'/repos/github.com/Shougo/dein.vim/')

" == Plugins & Settings ==
call dein#begin(expand('~/.config/nvim'))

" Plugin manager
call dein#add('Shougo/dein.vim')

" faster autocomplete alternative
call dein#add('Shougo/deoplete.nvim') "{{{
  let g:deoplete#enable_at_startup=1
  let g:deoplete#omni#functions={}
  let g:deoplete#sources={}
"}}}

" snippet manager
call dein#add('SirVer/ultisnips')
call dein#add('honza/vim-snippets', { 'depends': 'ultisnips' })

" == General editor plugins ==

" shows function signature at the bottom while you are filling in the params
call dein#add('Shougo/echodoc.vim') "{{{
  set noshowmode " Otherwise -- INSERT -- will overwrite the help line
  let g:echodoc_enable_at_startup=1
"}}}

" align with cursor motions by a given character
call dein#add('junegunn/vim-easy-align') "{{{
  " Start interactive EasyAlign in visual mode (e.g. vipga)
  xmap ga <Plug>(EasyAlign)

  " Start interactive EasyAlign for a motion/text object (e.g. gaip)
  nmap ga <Plug>(EasyAlign)
"}}}

" managing surrounding tags & quotes
call dein#add('tpope/vim-surround')

" language specific commenting
call dein#add('tpope/vim-commentary')

if has('mac')
  " show documentation in the Dash.app
  " Dash.app is a mac only application
  call dein#add('rizzatti/dash.vim', { 'on_ft': ['javascript', 'jsx', 'python'] }) "{{{
    nmap <silent> <leader>d <Plug>DashSearch
  "}}}

endif

" Project tree
call dein#add('scrooloose/nerdtree', { 'on_func':  'NERDTreeToggle' }) "{{{
  map <F2> :NERDTreeToggle<CR>
  let g:NERDChristmasTree=1
  let g:NERDTreeHighlightCursorline=1
  let g:NERDTreeWinSize=40
"}}}

" Show git status in NERDTree
call dein#add('Xuyuanp/nerdtree-git-plugin', { 'depends': 'nerdtree' })

" Show git gutter (added/modified/removed) lines
call dein#add('airblade/vim-gitgutter') "{{{
  let &updatetime=250
  let g:gitgutter_sign_added='░'
  let g:gitgutter_sign_modified='░'
  let g:gitgutter_sign_removed='░'
  let g:gitgutter_sign_removed_first_line='░'
  let g:gitgutter_sign_modified_removed='░'
"}}}

call dein#add('nathanaelkane/vim-indent-guides')

" Toggle booleans with a hotkey
call dein#add('AndrewRadev/switch.vim') "{{{
  " For switch.vim hotkey for toggle boolean options
  nnoremap <C-t> :Switch<cr>
  inoremap <C-t> <ESC>:Switch<CR>gi
"}}}

" Load code style from editorconfig files
call dein#add('editorconfig/editorconfig-vim')

" Gruvbox 256 color theme
" https://github.com/morhetz/gruvbox-contrib - iTerm2 and other's
call dein#add('morhetz/gruvbox') "{{{
  syntax on

  let &t_Co=256
  set background=dark
  silent! colorscheme gruvbox
"}}}

" Fast alternative to powerline
call dein#add('vim-airline/vim-airline', { 'depends' : ['ale', 'gruvbox'] }) "{{{
  let g:airline_powerline_fonts=1
  let g:airline#extensions#tabline#enabled=1
  let g:airline#extensions#tabline#fnamemod = ':t' " Show only filename in a tab
  let g:airline_section_error='%{ALEGetStatusLine()}'
  let g:airline_theme='gruvbox'
"}}}

" Shows file icons with patched font
call dein#add('ryanoasis/vim-devicons')

" Automatic indenting style
call dein#add('tpope/vim-sleuth')

" Asynchronous linter
call dein#add('w0rp/ale') "{{{
  let g:ale_linters={
  \ 'javascript': ['eslint'],
  \ }

  let g:ale_sign_column_always=1
  let g:ale_statusline_format=['⨉ %d', '⚠ %d', '']
  let g:ale_sign_error='⨉'
  let g:ale_sign_warning='⚠'

  nmap <silent> <C-k> <Plug>(ale_previous_wrap)
  nmap <silent> <C-j> <Plug>(ale_next_wrap)
"}}}

" == Python plugins ==
" deoplete-jedi integration for python autocomplete
call dein#add('zchee/deoplete-jedi', { 'on_ft': ['python', 'python3'], 'depends': ['deoplete.nvim'] }) "{{{
  let g:deoplete#sources#jedi#worker_threads=2
  let g:deoplete#sources['python']=['ultisnips', 'jedi']
"}}}

" correct python folding
call dein#add('tmhedberg/SimpylFold', {'on_ft': 'python'})

" == Javascript/CSS/HTML plugins ==
call dein#add('ternjs/tern_for_vim', { 'on_ft': ['javascript', 'jsx'] }) "{{{
  let g:tern#command=['tern']
  let g:tern#arguments=['--persistent']
"}}}

" deoplete-tern integration for javascript autocomplete
call dein#add('carlitux/deoplete-ternjs', { 'on_ft': ['javascript', 'jsx'], 'build': 'npm install', 'depends': ['deoplete.nvim', 'tern_for_vim'] }) "{{{
  set completeopt=longest,menuone

  let g:deoplete#sources['javascript.jsx']=['ultisnips', 'ternjs']
  let g:deoplete#sources['javascript']=['ultisnips', 'ternjs']
  let g:deoplete#omni#functions.javascript=['tern#Complete']

  imap <expr><C-j>   pumvisible() ? "\<C-n>" : "\<C-j>"
  imap <expr><C-k>   pumvisible() ? "\<C-p>" : "\<C-k>"
"}}}

" html5 syntax support
call dein#add('othree/html5.vim')

" correct javascript syntax support
call dein#add('othree/yajs.vim', {'on_ft': ['javascript', 'jsx']})

" extras for ECMAScript2016+ syntax
call dein#add('othree/es.next.syntax.vim', {'on_ft': ['javascript', 'jsx'], 'depends': 'yajs.vim'})

" some autocompletions for common JS libraries
call dein#add('othree/javascript-libraries-syntax.vim', {'on_ft': ['javascript', 'jsx']}) "{{{
  let g:used_javascript_libs='underscore,react,jasmine'
"}}}

" JSX syntax
call dein#add('mxw/vim-jsx', {'on_ft': 'jsx' })

" JSON syntax support
call dein#add('elzr/vim-json', {'on_ft': 'json' }) "{{{
  let g:vim_json_syntax_conceal=0
"}}}

" shows CSS colors in the editor
call dein#add('ap/vim-css-color', {'on_ft': 'css' })

" CSS3 syntax
call dein#add('hail2u/vim-css3-syntax', {'on_ft': 'css' })

" Always highlight matching tags
call dein#add('valloric/MatchTagAlways', {'on_ft': ['html', 'jsx'] })

" Emmet for html shorthands
call dein#add('mattn/emmet-vim', { 'on_ft': ['html', 'jsx'] })

" Markdown plugins
call dein#add('tpope/vim-markdown', {'on_ft': 'markdown'}) "{{{
  let g:markdown_fenced_languages=['html', 'css', 'python', 'javascript', 'javascript.jsx', 'bash=sh']
"}}}

" VIML autocompletion
call dein#add('Shougo/neco-vim', { 'on_ft': ['vim'], 'depends': ['deoplete.nvim'] })

" Octave/Matlab syntax
call dein#add('vim-scripts/octave.vim') "{{{
  augroup filetypedetect
    au! BufRead,BufNewFile *.m, set filetype=matlab
  augroup END
"}}}

" Dockerfile & Docker compose syntax
call dein#add('ekalinin/Dockerfile.vim', { 'on_ft': 'Dockerfile' })

" limelight/goyo/zenroom2 for distraction free mode
call dein#add('junegunn/limelight.vim') "{{{
  let g:limelight_conceal_ctermfg='gray'
  let g:limelight_conceal_ctermfg=240
"}}}

call dein#add('junegunn/goyo.vim', { 'depends': 'limelight.vim' })

call dein#add('amix/vim-zenroom2', { 'depends': 'goyo.vim' }) "{{{
  let g:goyo_height='100%'
  let g:goyo_width=120

  autocmd! User GoyoEnter Limelight
  autocmd! User GoyoLeave Limelight!
  nnoremap <silent> <leader>f :Goyo <CR>
"}}}

" markabe/vim-jira-open - open jira by ticket number

" mnpk/vim-jira-complete - autocomplete tickets for Git commit msg

if dein#check_install()
  call dein#install()
endif

call dein#end()

" == General VIM settings ==

" Truecolors
if has('nvim')
  set termguicolors
endif

filetype plugin indent on

silent execute '!mkdir -p '.s:nvim_home_dir.'/backup'
silent execute '!mkdir -p '.s:nvim_home_dir.'/temp'
silent execute '!mkdir -p '.s:nvim_home_dir.'/undo'

set backup
let &backupdir=s:nvim_home_dir.'/backup'
let &directory=s:nvim_home_dir.'/temp'

" to be able to undo after closing the file (persistent undo)
set undofile                           " Save undo's after file closes
let &undodir=s:nvim_home_dir.'/undo' " where to save undo histories
set undolevels=1000                    " How many undos
set undoreload=10000                   " number of lines to save for undo

" solid vertical separator
set fillchars=vert:\ ,fold:\ "

" show relative numbers for easier navigation
set relativenumber
highlight LineNr ctermfg=gray

" invisible character colors
highlight NonText ctermfg=Black
highlight SpecialKey ctermfg=Black

" highlight currentl line
set cursorline

" hide end of buffer ~ signs
highlight EndOfBuffer ctermbg=bg ctermfg=bg guibg=bg guifg=bg

" toggle background light/dark
map <Leader>bg :let &background = ( &background == "dark"? "light" : "dark" )<CR>

function! AutoFormatJavaScript()
  " Save cursor position, fix with eslint and restore cursor position
  let l:line_number=line('.')
  let l:column_number=col('.')
  let l:eslint_path='eslint_d'
  silent execute '%!' . l:eslint_path . ' --fix-to-stdout --stdin < %'
  call cursor(l:line_number, l:column_number)
endfunction

autocmd BufWritePre *.js,*.jsx :call AutoFormatJavaScript()
