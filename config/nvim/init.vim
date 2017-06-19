" Plugins will be downloaded under the specified directory.
call plug#begin('~/.vim/plugged')
" Declare the list of plugins.
Plug 'airblade/vim-gitgutter'
Plug 'c0r73x/neotags.nvim'
Plug 'christoomey/vim-tmux-navigator'
Plug 'dracula/vim'
Plug 'jgdavey/tslime.vim'
Plug 'jremmen/vim-ripgrep'
Plug 'junegunn/fzf.vim'
Plug 'ludovicchabant/vim-gutentags'
Plug 'scrooloose/nerdtree'
Plug 'thoughtbot/vim-rspec'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-rails'
Plug 'tpope/vim-rhubarb.git'
Plug 'vim-airline/vim-airline' 
Plug 'w0rp/ale'
" List ends here. Plugins become visible to Vim after this call.

call plug#end()

colorscheme dracula

set hidden

set number
set cursorline
" set cursorcolumn
set colorcolumn=100
set clipboard=unnamed
set shiftwidth=2
set tabstop=2
set expandtab
set nowrap

set splitbelow
set splitright

set whichwrap+=<,>,h,l,[,]

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
map <Leader>t :Tags<CR>
nnoremap <Leader>tt :call fzf#vim#tags("<C-R><C-W>")<CR>
map <Leader>r :BTags<CR>

" Ripgrep
map <Leader>g :Rg 
map <Leader>gw :Rg <C-R><C-W><CR>

" GitGutter
let g:gitgutter_sign_column_always = 1

" ALE
set nocompatible
filetype off
let &runtimepath.=',~/.vim/bundle/ale'
filetype plugin on

" gutentags
let g:gutentags_ctags_exclude = ['tmp', 'node_modules']

" tmux nav
" nnoremap <silent> <BS> :TmuxNavigateLeft<cr>

" RSpec.vim mappings
map <Leader>sf :call RunCurrentSpecFile()<CR>
map <Leader>ss :call RunNearestSpec()<CR>
map <Leader>sl :call RunLastSpec()<CR>


" tslime
let g:rspec_command = 'call Send_to_Tmux("bin/rspec {spec}\n")'
let g:tslime_always_current_session = 1
let g:tslime_always_current_window = 1


