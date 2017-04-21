set nocompatible

execute pathogen#infect()

filetype on
filetype plugin indent on
filetype plugin on
colorscheme dracula

syntax on
syntax enable

set shiftwidth=2
set tabstop=2
set softtabstop=2
set expandtab 
set smarttab
set shiftround
set autoindent 
set backspace=indent,eol,start

set showmode
set number
set cursorline

set clipboard=unnamed

" Make search more sane
set ignorecase " case insensitive search
set smartcase " If there are uppercase letters, become case-sensitive.
set incsearch " live incremental searching
set showmatch " live match highlighting
set hlsearch " highlight matches
set gdefault " use the `g` flag by default.

let mapleader = ","
set hidden
set nowrap
set nobackup
set noswapfile

set whichwrap+=<,>,h,l,[,]
set backspace=indent,eol,start

set list
set listchars=tab:>.,trail:.,extends:#,nbsp:.

set colorcolumn=100

set splitbelow
set splitright

" Syntastic
"set statusline+=%#warningmsg#
"set statusline+=%{SyntasticStatuslineFlag()}
"set statusline+=%*

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 2
let g:syntastic_check_on_open = 0
let g:syntastic_check_on_wq = 0
let g:syntastic_ruby_checkers = ['rubocop']
let g:syntastic_javascript_checkers = ['eslint']
let g:syntastic_javascript_eslint_exe = '$(yarn bin)/eslint'
"autocmd FileType javascript let b:syntastic_checkers = syntastic#util#findFileInParent('.eslintrc', expand('%:p:h', 1)) !=# '' ? ['eslint'] : []
let g:syntastic_scss_checkers = ['scss_lint']
"let g:syntastic_debug = 3
"let g:syntastic_debug_file = "~/syntastic.log"
let g:syntastic_loc_list_height = 3
map <Leader>s :SyntasticCheck<CR>

"map <Leader>t :execute 'CtrlP'<CR>
let g:ctrlp_map = '<c-p>'
let g:ctrlp_cmd = 'CtrlP'

" Powerline
set rtp+=/Users/peter/Library/Python/2.7/lib/python/site-packages/powerline/bindings/vim
set laststatus=2
set t_Co=256
set guifont=Source\ Code\ Pro\ for\ Powerline
let g:Powerline_symbols = 'fancy'
set fillchars+=stl:\ ,stlnc:\   

" NERDTree
let NERDTreeShowHidden=1
map <Leader>d :execute ‘NERDTreeToggle ’ . getcwd()<CR>
map <Leader>df :execute ‘NERDTreeFind ’<CR>

" fzf
set rtp+=/usr/local/opt/fzf
map <Leader>f :GFiles<CR>
map <Leader>b :Buffers<CR>
map <Leader>e :bp<CR>
map <Leader>r :bl<CR>
map <Leader>w :bd<CR>
" Ripgrep
map <Leader>g :Rg 


if has("gui_running")
    :source ~/.gvimrc
endif


