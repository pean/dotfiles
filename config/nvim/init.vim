" Plugins will be downloaded under the specified directory.
call plug#begin('~/.vim/plugged')
" Declare the list of plugins.
" Plug 'c0r73x/neotags.nvim'
" Plug 'chriskempson/base16-vim'
" Plug 'jgdavey/tslime.vim'
" Plug 'thoughtbot/vim-rspec'
Plug 'airblade/vim-gitgutter'
Plug 'christoomey/vim-tmux-navigator'
Plug 'danishprakash/vim-githubinator'
Plug 'dracula/vim'
Plug 'https://gitlab.com/code-stats/code-stats-vim.git'
Plug 'jremmen/vim-ripgrep', { 'commit': '0df3ac2c3e51d27637251a5849f892c3a0f0bce0' }
Plug 'junegunn/fzf.vim'
Plug 'ludovicchabant/vim-gutentags'
Plug 'mxw/vim-jsx'
Plug 'pangloss/vim-javascript'
Plug 'pean/tslime.vim'
Plug 'pean/vim-rspec'
Plug 'scrooloose/nerdtree'
Plug 'skywind3000/gutentags_plus'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-rails'
Plug 'tpope/vim-rhubarb'
Plug 'w0rp/ale'
" List ends here. Plugins become visible to Vim after this call.

call plug#end()

colorscheme dracula
hi Normal ctermbg=none

" dracula + ale settings
hi ErrorMsg ctermfg=203 ctermbg=NONE
hi WarningMsg ctermfg=212 ctermbg=NONE
hi ALEErrorSign ctermfg=203 ctermbg=NONE
hi ALEError ctermfg=203 ctermbg=NONE
hi ALEWarningSign ctermfg=212 ctermbg=NONE
hi ALEWarning ctermfg=212 ctermbg=NONE

set hidden

set number
set cursorline
set colorcolumn=120
set clipboard=unnamed
set shiftwidth=2
set tabstop=2
set expandtab
set nowrap
set list
set listchars=tab:>-,trail:-,extends:>
set splitbelow
set splitright

set whichwrap+=<,>,h,l,[,]

let mapleader = ","

map <Leader>n :noh<CR>
map <Leader>bd :%bd!<CR>
map <Leader>bp :bprevious<CR>
map <Leader>bn :bnext<CR>

" ALE
map <Leader>an :ALENext<CR>

" NERDTree
let NERDTreeShowHidden=1
map <Leader>d :execute 'NERDTreeToggle ' . getcwd()<CR>
map <Leader>df :execute 'NERDTreeFind '<CR>

" fzf
set rtp+=/usr/local/opt/fzf
map <Leader>f :GFiles<CR>
map <Leader>b :Buffers<CR>
map <Leader>tt :Tags<CR>
nnoremap <Leader>tw :call fzf#vim#tags("<C-R><C-W>")<CR>
map <Leader>r :BTags<CR>

" Ripgrep
map <Leader>gg :Rg 
map <Leader>gw :Rg <C-R><C-W><CR>
" let g:rg_hightlight=1
" let g:rg_binary='/usr/local/bin/rg'


" GitGutter
set signcolumn=yes

set nocompatible
filetype off
" let &runtimepath.=',~/.vim/plugged/ale'
filetype plugin on

" gutentags
let g:gutentags_ctags_exclude = ['tmp', 'node_modules']
let g:gutentags_modules = ['ctags']
au FileType diff,gitcommit,gitrebase let g:gutentags_enabled=0
let g:gutentags_cache_dir = expand('~/.cache/tags')
let g:gutentags_plus_nomap = 1

" tmux nav
" nnoremap <silent> <bs> :tmuxnavigateleft<cr>
let g:tmux_navigator_disable_when_zoomed = 1

" rspec.vim mappings
map <leader>sa :Tmux <CR> <bar> :call RunCurrentSpecFile()<CR>
map <leader>ss :Tmux <CR> <bar> :call RunNearestSpec()<CR>
map <leader>sl :Tmux <CR> <bar> :call RunLastSpec()<CR>
map <leader>sf :Tmux <CR> <bar> :call RunFailedSpecs()<CR>
map <leader>se :unlet g:tslime <CR> <bar> :call RunNearestSpec()<CR>

cmap FormatJSON %!python -m json.tool

" tslime
let g:rspec_command = 'call Send_to_Tmux("bin/rspec {spec}\n")'
let g:tslime_always_current_session = 1
let g:tslime_always_current_window = 1
let g:tslime_always_current_pane = 1


map <leader>a :only<CR>:sp<CR>:A<CR>

" CodeStats
source ~/.codestats.vim
