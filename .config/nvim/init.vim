scriptencoding utf-8

let s:nvim_home_dir=expand('$HOME/.config/nvim')
let g:python_host_prog=expand('$HOME/.virtualenvs/neovim2/bin/python')
let g:python3_host_prog=expand('$HOME/.virtualenvs/neovim3/bin/python')

let g:mapleader=' '

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

" file_mru for denite
call dein#add('Shougo/neomru.vim')

" denite module for faster fuzzy search
call dein#add('nixprime/cpsm', { 'build': 'PY3=ON ./install.sh'})

" INSTALL: brew install ripgrep
" hard to explain what denite is :)
function s:denite_config()
  call denite#custom#option('default', 'prompt', '❯')

  call denite#custom#var('file_rec', 'command', [
    \ 'rg',
    \ '--files',
    \ '--glob', '!.git',
    \ '--glob', '!*.ttf',
    \ '--glob', '!*.jpg',
    \ '--glob', '!*.gif',
    \ '--glob', '!*.png',
    \ '--glob', '!*.jpeg',
    \ '--glob', '!*.min.js',
    \ '--glob', '!*.tiff',
    \ ])

  call denite#custom#var('grep', 'command', ['rg'])
	call denite#custom#var('grep', 'default_opts', ['--vimgrep', '--no-heading'])
	call denite#custom#var('grep', 'recursive_opts', [])
	call denite#custom#var('grep', 'pattern_opt', ['--regexp'])
	call denite#custom#var('grep', 'separator', ['--'])
	call denite#custom#var('grep', 'final_opts', [])


	call denite#custom#source(
	\ 'file_mru', 'matchers', ['matcher_fuzzy', 'matcher_project_files'])

  call denite#custom#source(
	\ 'file_rec', 'matchers', ['matcher_cpsm'])

  call denite#custom#source('file_rec', 'sorters', ['sorter_sublime'])

  nnoremap <silent> <c-p> :Denite file_rec<CR>
  nnoremap <silent> <c-f> :Denite grep<CR>
  hi deniteMatched guibg=None
  hi deniteMatchedChar guibg=None

  " search in help
  nnoremap <silent> <leader>h :Denite  help<CR>

  " colorscheme picker
  nnoremap <silent> <leader>c :Denite colorscheme<CR>

  nnoremap <silent> <leader>e :Denite file_mru<CR>

  call denite#custom#map(
        \ 'insert',
        \ '<C-j>',
        \ '<denite:move_to_next_line>',
        \ 'noremap'
        \)
  call denite#custom#map(
        \ 'insert',
        \ '<C-k>',
        \ '<denite:move_to_previous_line>',
        \ 'noremap'
        \)

  call denite#custom#filter('matcher_ignore_globs', 'ignore_globs',
        \ [ '.git/', '.ropeproject/', '__pycache__/',
        \   'venv/', 'images/', '*.min.*', 'img/', 'fonts/'])

  let s:menus = {} " Useful when building interfaces at appropriate places

  " == Denite Fugitive(Git) Menu
  let s:menus.git = {
    \ 'description' : 'Fugitive interface',
    \}

  let s:menus.git.command_candidates = [
    \[' git status', 'Gstatus'],
    \[' git diff', 'Gvdiff'],
    \[' git commit', 'Gcommit'],
    \[' git stage/add', 'Gwrite'],
    \[' git checkout', 'Gread'],
    \[' git rm', 'Gremove'],
    \[' git cd', 'Gcd'],
    \[' git push', 'exe "Git! push " input("remote/branch: ")'],
    \[' git pull', 'exe "Git! pull " input("remote/branch: ")'],
    \[' git pull rebase', 'exe "Git! pull --rebase " input("branch: ")'],
    \[' git checkout branch', 'exe "Git! checkout " input("branch: ")'],
    \[' git fetch', 'Gfetch'],
    \[' git merge', 'Gmerge'],
    \[' git browse', 'Gbrowse'],
    \[' git head', 'Gedit HEAD^'],
    \[' git parent', 'edit %:h'],
    \[' git log commit buffers', 'Glog --'],
    \[' git log current file', 'Glog -- %'],
    \[' git log last n commits', 'exe "Glog -" input("num: ")'],
    \[' git log first n commits', 'exe "Glog --reverse -" input("num: ")'],
    \[' git log until date', 'exe "Glog --until=" input("day: ")'],
    \[' git log grep commits',  'exe "Glog --grep= " input("string: ")'],
    \[' git log pickaxe',  'exe "Glog -S" input("string: ")'],
    \[' git index', 'exe "Gedit " input("branchname\:filename: ")'],
    \[' git mv', 'exe "Gmove " input("destination: ")'],
    \[' git grep',  'exe "Ggrep " input("string: ")'],
    \[' git prompt', 'exe "Git! " input("command: ")'],
    \] " Append ' --' after log to get commit info commit buffers
  call denite#custom#var('menu', 'menus', s:menus)
  nnoremap <silent> <Leader>G :Denite menu:git <CR>
endfunction

call dein#add('Shougo/denite.nvim', { 'depends': ['cpsm','neomru.vim'], 'hook_add': function('s:denite_config')})

" faster autocomplete alternative
function s:deoplete_plugin_config()
  let g:deoplete#enable_at_startup=1
  let g:deoplete#omni#functions={}
  let g:deoplete#sources={}
  let g:deoplete#omni_patterns={}
  let g:deoplete#auto_refresh_delay=0
  let g:deoplete#auto_complete_delay=0

  call deoplete#custom#set('ultisnips', 'matchers', ['matcher_fuzzy'])

  inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
  inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
  inoremap <expr> <cr> pumvisible() ? "\<C-y>\<cr>" : "\<cr>"
endfunction

call dein#add('Shougo/deoplete.nvim', { 'hook_add': function('s:deoplete_plugin_config')})

" snippet manager
function s:ultisnips_plugin_config()
  augroup ultisnips
    " Preload snippets for js files
    autocmd!
    autocmd BufNewFile,BufRead *.js,*.jsx UltiSnipsAddFiletypes javascript-mocha
    autocmd BufNewFile,BufRead *.js,*.jsx UltiSnipsAddFiletypes javascript.es6.react
    autocmd BufNewFile,BufRead *.js,*.jsx UltiSnipsAddFiletypes javascript/javascript.es6
  augroup END
endfunction

call dein#add('SirVer/ultisnips', { 'hook_add': function('s:ultisnips_plugin_config') })
call dein#add('honza/vim-snippets', { 'depends': 'ultisnips' })

" == General editor plugins ==
" git interface
call dein#add('tpope/vim-fugitive')

" shows function signature at the bottom while you are filling in the params
function s:echodoc_config()
  set noshowmode " Otherwise -- INSERT -- will overwrite the help line
  let g:echodoc_enable_at_startup=1
endfunction

call dein#add('Shougo/echodoc.vim', { 'hook_add': function('s:echodoc_config')})

" defines a new text object representing lines of code at the same indent level
call dein#add('michaeljsmith/vim-indent-object')

" region exchange operator
call dein#add('tommcdo/vim-exchange')


function s:incsearch_config()
  " :h g:incsearch#auto_nohlsearch
  set hlsearch
  let g:incsearch#auto_nohlsearch = 1

  map /  <Plug>(incsearch-forward)
  map ?  <Plug>(incsearch-backward)
  map g/ <Plug>(incsearch-stay)
  map n  <Plug>(incsearch-nohl-n)
  map N  <Plug>(incsearch-nohl-N)
  map *  <Plug>(incsearch-nohl-*)
  map #  <Plug>(incsearch-nohl-#)
  map g* <Plug>(incsearch-nohl-g*)
  map g# <Plug>(incsearch-nohl-g#)
endfunction

" smart incremental search with automatic nohlsearch
" TODO: Broken on neovim-head
" call dein#add('haya14busa/incsearch.vim', { 'hook_add': function('s:incsearch_config')})

" advanced sorting, for ex by line width in range
call dein#add('vim-scripts/ingo-library')
call dein#add('vim-scripts/AdvancedSorters', { 'depends': 'ingo-library' })

" completion/highlighting within the context. for example script tag in html
call dein#add('Shougo/context_filetype.vim')

" show indentation guides/lines
function s:indentLine_config()
  let g:indentLine_char = '│'
  let g:indentLine_conceallevel = 2
endfunction

call dein#add('Yggdroot/indentLine', { 'hook_add': function('s:indentLine_config')})

" align with cursor motions by a given character
function s:vim_easy_align_config()
  " Start interactive EasyAlign in visual mode (e.g. vipga)
  xmap ga <Plug>(EasyAlign)

  " Start interactive EasyAlign for a motion/text object (e.g. gaip)
  nmap ga <Plug>(EasyAlign)
endfunction

call dein#add('junegunn/vim-easy-align', { 'hook_add': function('s:vim_easy_align_config')})

" managing surrounding tags & quotes
call dein#add('tpope/vim-surround')

" language specific commenting
call dein#add('tpope/vim-commentary')

" command line Dash.app alternative
" https://github.com/sunaku/dasht
" Requires installing a gem, see the URL ^^
function s:vim_dasht_config()
  " search related docsets
  nnoremap <Leader>k :Dasht<Space>

  " search related docsets
  nnoremap <silent> <Leader>K :call Dasht([expand('<cWORD>'), expand('<cword>')])<Return>

  " search related docsets
  vnoremap <silent> <Leader>K y:<C-U>call Dasht(getreg(0))<Return>

  let g:dasht_filetype_docsets = {}
  let g:dasht_filetype_docsets['python'] = ['Python_2', 'Python_3', 'Flask', 'SQLAlchemy', 'MySQL']
  let g:dasht_filetype_docsets['html'] = ['css', 'html']
  let g:dasht_filetype_docsets['javascript'] = ['JavaScript', 'Lo-Dash', 'React']
  let g:dasht_filetype_docsets['javascript.jsx'] = g:dasht_filetype_docsets['javascript']
endfunction

call dein#add('sunaku/vim-dasht', { 'hook_add': function('s:vim_dasht_config') })

" Project tree

function! NERDTreeToggleInCurDir()
  " If NERDTree is open in the current buffer
  if (exists('t:NERDTreeBufName') && bufwinnr(t:NERDTreeBufName) != -1)
    exe ':NERDTreeClose'
  else
    if (expand('%:t') !=# '')
      exe ':NERDTreeFind'
    else
      exe ':NERDTreeToggle'
    endif
  endif
endfunction

function s:nerdtree_config()
  map <silent><F2> :call NERDTreeToggleInCurDir()<CR>
  let g:NERDChristmasTree=1
  let g:NERDTreeHighlightCursorline=1
  let g:NERDTreeWinSize=40
endfunction

call dein#add('scrooloose/nerdtree', { 'on_func': 'NERDTreeToggleInCurDir', 'hook_add': function('s:nerdtree_config') })

" Show git gutter (added/modified/removed) lines
function s:vim_gitgutter_config()
  let &updatetime=100
  let g:gitgutter_sign_added='░'
  let g:gitgutter_sign_modified='░'
  let g:gitgutter_sign_removed='░'
  let g:gitgutter_sign_removed_first_line='░'
  let g:gitgutter_sign_modified_removed='░'
endfunction

call dein#add('airblade/vim-gitgutter', { 'hook_add': function('s:vim_gitgutter_config') })

call dein#add('nathanaelkane/vim-indent-guides')

" Toggle booleans with a hotkey
function s:switch_config()
  " For switch.vim hotkey for toggle boolean options
  nnoremap <C-t> :Switch<cr>
  inoremap <C-t> <ESC>:Switch<CR>gi
endfunction

call dein#add('AndrewRadev/switch.vim', { 'hook_add': function('s:switch_config') })

" Load code style from editorconfig files
call dein#add('editorconfig/editorconfig-vim')

" Gruvbox 256 color theme
" https://github.com/morhetz/gruvbox-contrib - iTerm2 and other's
function s:gruvbox_config()
  syntax on

  let &t_Co=256
  set background=dark
  silent! colorscheme gruvbox

  " hide end of buffer ~ signs
  highlight EndOfBuffer ctermbg=bg ctermfg=bg guibg=bg guifg=bg
endfunction

call dein#add('morhetz/gruvbox', { 'hook_add': function('s:gruvbox_config') })

" Fast alternative to powerline
function s:vim_airline_config()
  let g:airline_powerline_fonts=1
  let g:airline#extensions#tabline#enabled=1
  let g:airline#extensions#tabline#fnamemod = ':t' " Show only filename in a tab
  let g:airline_section_error='%{ALEGetStatusLine()}'
  let g:airline_theme='gruvbox'
endfunction

call dein#add('vim-airline/vim-airline', { 'depends' : ['ale', 'gruvbox'], 'hook_add': function('s:vim_airline_config') })

" Shows file icons with patched font
call dein#add('ryanoasis/vim-devicons')

" Asynchronous formatter
" INSTALL: npm install -g eslint_d stylefmt js-beautify
" yapf requires a config file which can be in homedir or project dir
function s:neoformat_config()
    " Override jsbeautify definition to supply args
    let g:neoformat_json_jsbeautify = {
    \ 'exe': 'js-beautify',
    \ 'args': ['--editorconfig', '--html'],
    \ 'stdin': 1,
    \ }

    let g:neoformat_html_htmlbeautify= {
    \ 'exe': 'js-beautify',
    \ 'args': ['--editorconfig', '--html'],
    \ 'stdin': 1
    \}

    let g:neoformat_javascript_eslintd = {
    \ 'exe': 'eslint_d',
    \ 'args': ['--fix-to-stdout', '--stdin'],
    \ 'stdin': 1
    \ }

    " read from file instead of buffer, otherwise some formatters fail to
    " resolve the config file which can be located in parent directories
    let g:neoformat_enabled_javascript=['eslintd']
    let g:neoformat_enabled_python=['yapf']
    let g:neoformat_enabled_json=['jsbeautify']
    let g:neoformat_enabled_html=['htmlbeautify']
    let g:neoformat_enabled_css=['stylefmt']

    augroup neoformatGrp
      autocmd!
      autocmd FileType javascript,python,css,json,html map <silent> <leader>l :Neoformat<CR>
    augroup END
endfunction

call dein#add('sbdchd/neoformat', { 'on_ft': ['javascript','json','html', 'python', 'css'], 'hook_add': function('s:neoformat_config') })

" Asynchronous linter
"
" INSTALL: npm install -g eslint eslint_d stylelint-config-css-modules stylelint-config-standard
" INSTALL: pip install vim-vint
" INSTALL: brew install hadolint
" Add .stylelintrc to homedir or project
function s:ale_config()
  let g:ale_linters={
  \ 'javascript': ['eslint'],
  \ 'css': ['stylelint'],
  \ 'vim': ['vint'],
  \ 'python': ['flake8'],
  \ }

  let g:ale_lint_delay=50
  let g:ale_sign_column_always=1
  let g:ale_statusline_format=['⨉ %d', '⚠ %d', '']
  let g:ale_sign_error='⨉'
  let g:ale_sign_warning='⚠'

  let g:ale_python_flake8_executable = 'python'
  let g:ale_python_flake8_args = '-m flake8'

  let g:ale_javascript_eslint_executable = 'eslint_d'

  nmap <silent> <C-k> <Plug>(ale_previous_wrap)
  nmap <silent> <C-j> <Plug>(ale_next_wrap)
endfunction

call dein#add('w0rp/ale', { 'hook_add': function('s:ale_config') })

" == Python plugins ==
" Better python indent settings
call dein#add('hynek/vim-python-pep8-indent')

" deoplete-jedi integration for python autocomplete
function s:deoplete_jedi_config()
  let g:deoplete#sources['python']=['ultisnips', 'jedi']
endfunction

call dein#add('zchee/deoplete-jedi', { 'on_ft': 'python', 'depends': ['deoplete.nvim'], 'hook_add': function('s:deoplete_jedi_config') })

" jedi-vim refactoring/goto functionality
function s:jedi_vim_config()
  let g:jedi#completions_enabled = 0
  let g:goto_assignments_command = '<leader>g'
  let g:jedi#documentation_command = 'K'
  let g:jedi#usages_command = '<leader>us'
  let g:jedi#rename_command = '<leader>re'
endfunction

call dein#add('davidhalter/jedi-vim', { 'on_ft': 'python', 'hook_add': function('s:jedi_vim_config') })

" correct python folding
call dein#add('tmhedberg/SimpylFold', {'on_ft': 'python'})

" == Javascript/CSS/HTML plugins ==
" to open require paths under cursor
call dein#add('moll/vim-node')

function s:tern_for_vim_config()
  let g:tern#command = ['tern']
  let g:tern#arguments = ['--persistent', '--verbose']
  let g:tern_show_signature_in_pum = '0'
  let g:tern_request_timeout = 1
  let g:tern#filetypes = [
  \ 'jsx',
  \ 'javascript.jsx',
  \ ]
endfunction

call dein#add('ternjs/tern_for_vim', { 'on_ft': ['javascript', 'jsx'], 'hook_add': function('s:tern_for_vim_config') })

" deoplete-tern integration for javascript autocomplete
function s:deoplete_ternjs_config()
  set completeopt=longest,menuone

  let g:deoplete#sources['javascript.jsx']=['ultisnips', 'ternjs']
  let g:deoplete#sources['javascript']=['ultisnips', 'ternjs']
  let g:deoplete#omni#functions.javascript=['tern#Complete']

  imap <expr><C-j>   pumvisible() ? "\<C-n>" : "\<C-j>"
  imap <expr><C-k>   pumvisible() ? "\<C-p>" : "\<C-k>"
endfunction

" INSTALL: npm install -g ternjs
call dein#add('carlitux/deoplete-ternjs', { 'on_ft': ['javascript', 'jsx'], 'depends': ['deoplete.nvim', 'tern_for_vim'], 'hook_add': function('s:deoplete_ternjs_config') })

" html5 syntax support
call dein#add('othree/html5.vim')

" jinja2 syntax
call dein#add('Glench/Vim-Jinja2-Syntax')

" correct javascript syntax support
call dein#add('othree/yajs.vim', {'on_ft': ['javascript', 'jsx']})

" some autocompletions for common JS libraries
function s:javascript_libraries_syntax_config()
  let g:used_javascript_libs='underscore,react,jasmine'
endfunction

call dein#add('othree/javascript-libraries-syntax.vim', {'on_ft': ['javascript', 'jsx'], 'hook_add': function('s:javascript_libraries_syntax_config') })

" JSX syntax
call dein#add('neoclide/vim-jsx-improve', {'on_ft': ['javascript', 'jsx', 'javascript.jsx'] })

" JSON syntax support
function s:vim_json_config()
  let g:vim_json_syntax_conceal=0
endfunction

call dein#add('elzr/vim-json', {'on_ft': 'json', 'hook_add': function('s:vim_json_config') })

" shows CSS colors in the editor
call dein#add('ap/vim-css-color', {'on_ft': 'css' })

" CSS3 syntax
call dein#add('hail2u/vim-css3-syntax', {'on_ft': 'css' })

" Always highlight matching tags
call dein#add('valloric/MatchTagAlways', {'on_ft': ['html', 'jsx'] })

" Emmet for html shorthands
call dein#add('mattn/emmet-vim', { 'on_ft': ['html', 'jsx'] })

" Markdown plugins
function s:vim_markdown_config()
  let g:markdown_fenced_languages=['html', 'css', 'python', 'javascript', 'javascript.jsx', 'bash=sh']
endfunction

call dein#add('tpope/vim-markdown', {'on_ft': 'markdown', 'hook_add': function('s:vim_markdown_config') })

" VIML autocompletion
call dein#add('Shougo/neco-vim', { 'on_ft': ['vim'], 'depends': ['deoplete.nvim'] })

" Dockerfile & Docker compose syntax
call dein#add('ekalinin/Dockerfile.vim', { 'on_ft': 'Dockerfile' })

" Tmux filetype
call dein#add('tmux-plugins/vim-tmux', { 'on_path': '.tmux.conf'})

" MySQL syntax
augroup OnReadGroup
  autocmd BufRead *.sql set filetype=mysql
augroup END

" == General VIM settings ==

filetype plugin indent on

" Truecolors
if has('nvim')
  set termguicolors
endif

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

" allow hidden buffers
set hidden

" gray line numbers
highlight LineNr ctermfg=gray

" invisible character colors
highlight NonText ctermfg=Black
highlight SpecialKey ctermfg=Black

" no folding by default
set nofoldenable

" no highlighting after 120 char
set synmaxcol=120

" auto indentation mode
set autoindent

" backspacing over indentation, end-of-line
set backspace=2

" no fucking tabs, 2 spaces preferred to tabs
set expandtab tabstop=2

" make searches case-ins (unless upper-case letters)
set ignorecase smartcase

" show the `best match so far' while typing search
set incsearch

" stay in the same column while jumping
set nostartofline

" don't bell or blink
set visualbell t_vb=

" do not auto insert line breaks
" TODO: fix editorconfig/ linewrapping it inserts real line breaks
" TODO: comments auto added after o or O
" natural splits
set splitright
set splitbelow

" move blocks verticall in visual mode
vnoremap J :m '>+1<CR>gv=gv
vnoremap K :m '<-2<CR>gv=gv

map vv :vsplit<CR>
map ss :split<CR>

" remap : to ; to avoid pressing Shift
nnoremap ; :
vnoremap ; :

" Shift tab to go to next tab/buffer
nnoremap <S-Tab> :bnext<CR>

" close current buffer
nnoremap <leader>w :bdelete<CR>

" select just pasted text
nnoremap gp `[v`]

" clear search highlighting
nnoremap S :nohlsearch<CR>

" force saving files that require root permission
cmap w!! %!sudo tee > /dev/null %

" toggle background light/dark
map <Leader>bg :let &background = ( &background == "dark"? "light" : "dark" )<CR>

" automatically trim all the trailing whitespace on save
function! TrimWhitespace()
  let l:save = winsaveview()
  " vint: -ProhibitCommandWithUnintendedSideEffect -ProhibitCommandRelyOnUser
  %s/\s\+$//e
  " vint: +ProhibitCommandWithUnintendedSideEffect +ProhibitCommandRelyOnUser
  call winrestview(l:save)
endfunction

augroup prewrite
  autocmd BufWritePre * :call TrimWhitespace()
augroup END

" call ToggleVerbose() - for debugging
function! ToggleVerbose()
    if !&verbose
        set verbosefile=~/.vim_verbose.log
        set verbose=15
    else
        set verbose=0
        set verbosefile=
    endif
endfunction
