set nocompatible

filetype on
filetype plugin indent on
filetype plugin on

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

if has("gui_running")
    :source ~/.gvimrc
endif


