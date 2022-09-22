" Plugins will be downloaded under the specified directory.
call plug#begin('~/.vim/plugged')
" Declare the list of plugins.
" Plug 'c0r73x/neotags.nvim'
" Plug 'chriskempson/base16-vim'
" Plug 'jgdavey/tslime.vim'
" Plug 'junegunn/fzf.vim'
" Plug 'rizzatti/dash.vim'
" Plug 'skywind3000/gutentags_plus'
" Plug 'thoughtbot/vim-rspec'
Plug 'airblade/vim-gitgutter'
Plug 'christoomey/vim-tmux-navigator'
Plug 'danishprakash/vim-githubinator'
Plug 'dense-analysis/ale'
Plug 'dracula/vim'
Plug 'google/vim-jsonnet'
Plug 'https://gitlab.com/code-stats/code-stats-vim.git'
Plug 'jparise/vim-graphql'        " GraphQL syntax
" Plug 'jremmen/vim-ripgrep', { 'commit': '0df3ac2c3e51d27637251a5849f892c3a0f0bce0' }
Plug 'jremmen/vim-ripgrep'
Plug 'leafgarland/typescript-vim' " TypeScript syntax
Plug 'ludovicchabant/vim-gutentags'
Plug 'maxmellon/vim-jsx-pretty'   " JS and JSX syntax
" Plug 'mrjones2014/dash.nvim', { 'do': 'make install' }
Plug 'mxw/vim-jsx'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope-fzf-native.nvim', { 'do': 'make' }
Plug 'nvim-telescope/telescope.nvim'
Plug 'pangloss/vim-javascript'    " JavaScript support
Plug 'pean/tslime.vim'
Plug 'pean/vim-rspec'
Plug 'scrooloose/nerdtree'
Plug 'skanehira/preview-markdown.vim'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-rails'
Plug 'tpope/vim-rhubarb'
Plug 'tpope/vim-surround'
Plug 'vim-ruby/vim-ruby'
Plug 'vim-test/vim-test'
Plug 'ruifm/gitlinker.nvim'
Plug 'dewyze/vim-ruby-block-helpers'
Plug 'github/copilot.vim'
Plug 'chrisbra/Colorizer'
" List ends here. Plugins become visible to Vim after this call.

call plug#end()

packadd dracula_pro

let g:dracula_colorterm = 0
colorscheme dracula_pro

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
set colorcolumn=80,100,120
hi! link ColorColumn StatusLine
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

map <leader>n :noh<CR>
map <leader>cn :cnext<CR>
map <leader>bd :%bd!<CR>
map <leader>bn :bnext<CR>
map <leader>bp :bprev<CR>

" ALE
map <leader>an :ALENext<CR>

" NERDTree
let NERDTreeShowHidden=1
map <leader>d :execute 'NERDTreeToggle ' . getcwd()<CR>
map <leader>df :execute 'NERDTreeFind '<CR>

" fzf
" set rtp+=/usr/local/opt/fzf
" map <leader>f :GFiles<CR>
" map <leader>h :Rg<CR>
" map <leader>b :Buffers<CR>
" map <leader>tt :Tags<CR>
" " nnoremap <leader>tw :call fzf#vim#tags("<C-R><C-W>")<CR>
" map <leader>r :BTags<CR>

" " Ripgrep
map <leader>gg :Rg 
map <leader>gw :Rg <C-R><C-W><CR>
"  g:rg_hightlight=1
" let g:rg_binary='/usr/local/bin/rg'

" Telscope (to replace fzf and rg
nnoremap <leader>ff <cmd>Telescope find_files<cr>
nnoremap <leader>fg <cmd>Telescope live_grep<cr>
nnoremap <leader>fc <cmd>Telescope grep_string theme=get_cursor initial_mode=normal previewer=false<cr>
nnoremap <leader>fw <cmd>Telescope grep_string<cr>
nnoremap <leader>fb <cmd>Telescope buffers initial_mode=normal<cr>
nnoremap <leader>fh <cmd>Telescope help_tags<cr>
nnoremap <leader>fd <cmd>Telescope git_status initial_mode=normal<cr>
nnoremap <leader>ft <cmd>Telescope tags<cr>

lua << EOF
require('telescope').setup{
  defaults = {
    layout_strategy = "vertical",
    layout_config = {
      width = 0.95,
      height = 0.95,
    },
  },
  pickers = {
    buffers = {
      previewer = false,
      sort_lastused = true,
      theme = "dropdown",
    },
    grep_string = {
      word_match = "-w",
    },
  },
}

require('telescope').load_extension('fzf')
require"gitlinker".setup()
EOF


" GitGutter
set signcolumn=yes

set nocompatible
filetype off
" let &runtimepath.=',~/.vim/plugged/ale'
filetype plugin on

" gutentags
" let g:gutentags_ctags_exclude = ['tmp', 'node_modules']
" let g:gutentags_modules = ['ctags']
au FileType diff,gitcommit,gitrebase let g:gutentags_enabled=0
" let g:gutentags_cache_dir = expand('~/.cache/tags')
" let g:gutentags_plus_nomap = 1
" let g:gutentags_exclude_filetypes = ['gitcommit', 'gitconfig', 'gitrebase', 'gitsendemail', 'git']

" tmux nav
" nnoremap <silent> <bs> :tmuxnavigateleft<cr>
let g:tmux_navigator_disable_when_zoomed = 1

" rspec.vim mappings
map <leader>sa :Tmux <CR> <bar> :call RunCurrentSpecFile()<CR>
map <leader>ss :Tmux <CR> <bar> :call RunNearestSpec()<CR>
map <leader>sl :Tmux <CR> <bar> :call RunLastSpec()<CR>
map <leader>sf :Tmux <CR> <bar> :call RunFailedSpecs()<CR>
map <leader>sn :Tmux <CR> <bar> :call RunNextFailedSpec()<CR>
map <leader>se :unlet g:tslime <CR> <bar> :call RunNearestSpec()<CR>

" vin-test mappings, replaces rspec above
" map <leader>sa :Tmux <CR> <bar> :call :TestFile<CR>
" map <leader>ss :Tmux <CR> <bar> :TestNearest<CR>
" map <leader>sl :Tmux <CR> <bar> :TestLast<CR>
" map <leader>sf :Tmux <CR> <bar> :call RunFailedSpecs()<CR>
" map <leader>sn :Tmux <CR> <bar> :call RunNextFailedSpec()<CR>
" map <leader>se :unlet g:tslime <CR> <bar> :call RunNearestSpec()<CR>

cmap FormatJSON %!python -m json.tool

" tslime
let g:rspec_command = 'call Send_to_Tmux("bin/rspec {spec}\n")'
let g:tslime_always_current_session = 1
let g:tslime_always_current_window = 1
let g:tslime_always_current_pane = 1
let g:tslime_autoset_pane = 1

map <leader>a :only<CR>:sp<CR>:A<CR>

let ruby_fold = 1
set nofoldenable

" markdown preview
let g:preview_markdown_parser = 'mdcat'
let g:preview_markdown_auto_update = 1

" CodeStats
source ~/.codestats.vim


set nocursorline

function! OnWinEnter()
  set cursorline
endfunction

function! OnWinLeave()
  set nocursorline
endfunction

augroup HighlightPane
  autocmd!
  autocmd WinEnter * call OnWinEnter()
  autocmd WinLeave * call OnWinLeave()
augroup END

" Copilot
imap <silent><script><expr> <C-e> copilot#Next()
imap <silent><script><expr> <C-w> copilot#Previous()

" Colorizer
" let g:colorizer_auto_color = 1
let g:colorizer_auto_filetype='css,html,scss'
let g:colorizer_skip_comments = 1
