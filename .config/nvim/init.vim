" Plugins will be downloaded under the specified directory.
call plug#begin('~/.vim/plugged')
" Declare the list of plugins.
Plug 'airblade/vim-gitgutter'
Plug 'benjie/neomake-local-eslint.vim'
Plug 'dracula/vim'
Plug 'jremmen/vim-ripgrep'
Plug 'junegunn/fzf.vim'
"Plug 'neomake/neomake'
Plug 'scrooloose/nerdtree'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-sensible'
Plug 'vim-airline/vim-airline' 
Plug 'w0rp/ale'
" List ends here. Plugins become visible to Vim after this call.

call plug#end()

colorscheme dracula

set number
set cursorline
set colorcolumn=100
set clipboard=unnamed
set shiftwidth=2
set tabstop=2
set nowrap

let mapleader = ","


" NERDTree
let NERDTreeShowHidden=1
map <Leader>d :execute 'NERDTreeToggle ' . getcwd()<CR>
map <Leader>df :execute 'NERDTreeFind '<CR>


" fzf
set rtp+=/usr/local/opt/fzf
map <Leader>f :GFiles<CR>
map <Leader>b :Buffers<CR>
map <Leader>e :bp<CR>
map <Leader>r :bl<CR>
map <Leader>w :bd<CR>
" Ripgrep
map <Leader>g :Rg 

map <Leader>s :Neomake<CR>
map <Leader>sl :lopen<CR>


" GitGutter
let g:gitgutter_sign_column_always = 1


" ALE
set nocompatible
filetype off
let &runtimepath.=',~/.vim/bundle/ale'
filetype plugin on
