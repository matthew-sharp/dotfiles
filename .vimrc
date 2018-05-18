execute pathogen#infect()
syntax on
filetype plugin indent on

" show existing tab with 4 spaces width
set tabstop=4
" when indenting with '>', use 4 spaces width
set shiftwidth=4
" On pressing tab, insert 4 spaces
set expandtab

set autoindent
set backspace=indent,eol,start
set display=lastline,uhex
set fillchars=vert:│,fold:·
set formatoptions=tcqj
set hlsearch
set incsearch
set laststatus=2
set listchars=tab:>\ ,trail:-,nbsp:+
set nocompatible
set nrformats=bin,hex
set ruler
set showcmd
set sidescroll=1
set smarttab
set wildmode=longest,list,full
set wildmenu

imap <C-space> <Esc>
