" Plugins will be downloaded under the specified directory.
call plug#begin('~/.vim/plugged')
" Declare the list of plugins.
Plug 'airblade/vim-gitgutter'
" Plug 'c0r73x/neotags.nvim'
Plug 'christoomey/vim-tmux-navigator'
Plug 'dracula/vim'
" Plug 'chriskempson/base16-vim'
Plug 'jremmen/vim-ripgrep', { 'commit': '0df3ac2c3e51d27637251a5849f892c3a0f0bce0' }
" Plug 'jgdavey/tslime.vim'
Plug 'pean/tslime.vim'
Plug 'junegunn/fzf.vim'
Plug 'ludovicchabant/vim-gutentags'
Plug 'skywind3000/gutentags_plus'
Plug 'scrooloose/nerdtree'
" Plug 'thoughtbot/vim-rspec'
Plug 'pean/vim-rspec'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-rails'
Plug 'tpope/vim-rhubarb'
Plug 'w0rp/ale'
Plug 'https://gitlab.com/code-stats/code-stats-vim.git'
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
" map <Leader>w :bd<CR>
map <Leader>w :b#<bar>bd#<CR>
map <Leader>ww :b#<CR>
map <Leader>t :Tags<CR>
nnoremap <Leader>tt :call fzf#vim#tags("<C-R><C-W>")<CR>
map <Leader>r :BTags<CR>

" Ripgrep
map <Leader>g :Rg 
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
au FileType gitcommit,gitrebase let g:gutentags_enabled=0

" tmux nav
" nnoremap <silent> <bs> :tmuxnavigateleft<cr>

" rspec.vim mappings
map <leader>sa :Tmux <CR> <bar> :call RunCurrentSpecFile()<CR>
map <leader>ss :Tmux <CR> <bar> :call RunNearestSpec()<CR>
map <leader>sl :Tmux <CR> <bar> :call RunLastSpec()<CR>
map <leader>sf :Tmux <CR> <bar> :call RunFailedSpecs()<CR>
map <leader>se :call RunNearestSpec()<CR>


" tslime
let g:rspec_command = 'call Send_to_Tmux("bin/rspec {spec}\n")'
let g:tslime_always_current_session = 1
let g:tslime_always_current_window = 1
let g:tslime_always_current_pane = 1

" powerline
" set rtp+=/usr/local/lib/python3.6/site-packages/powerline/bindings/vim
" set laststatus=2
" set t_co=256
" set guifont=source\ code\ pro\ for\ powerline
" let g:powerline_symbols = 'fancy'
" set fillchars+=stl:\ ,stlnc:\   

" airline
" let g:airline#extensions#branchenabled = 1 " because it slows nvim down

map <leader>a :only<CR>:sp<CR>:A<CR>

" CodeStats
source ~/.codestats.vim
