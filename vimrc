set nocompatible

" Enable filetype detection and plugins for proper indentation
filetype plugin indent on

syntax on

" Leader key
let mapleader = ","

" Key mappings
nnoremap <leader>n :noh<CR>
nnoremap <leader>cn :cnext<CR>
nnoremap <leader>bd :%bd!<CR>

" Clipboard integration
set clipboard=unnamed

" Color columns
set colorcolumn=80,100,120

" Indentation settings
set expandtab
set tabstop=2
set softtabstop=2
set shiftwidth=2
set autoindent
set shiftround

" Display whitespace and special characters
set list
set listchars=tab:>-,trail:-,extends:>
set number
set whichwrap+=<,>,h,l,[,]
set nowrap

" Search settings
set ignorecase
set smartcase
set incsearch
set showmatch
set hlsearch

" General settings
set hidden
set nobackup
set noswapfile
set splitbelow
set splitright
set showmode
