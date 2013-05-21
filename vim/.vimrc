set nocompatible
set filetype=on
set autoindent
set autowrite
set history=50
set ruler
set showcmd
set incsearch
set ignorecase smartcase
set scrolloff=2
set showmatch
call pathogen#infect()
syntax on
filetype plugin on
set hlsearch
set wildmenu
set wildmode=full
set hidden
set expandtab
set tabstop=8
set shiftwidth=4
set softtabstop=4
set shiftround
set smartindent
set background=dark

" Ctrl-style scrolling (stationary cursor)
noremap <C-Down> <C-E>
noremap <C-Up> <C-Y>
noremap <C-J> <C-E>
noremap <C-K> <C-Y>

" Arrow keys to screen lines, not physical lines.
" [jk default behavior preserved.]
noremap <up> gk
noremap <down> gj

" Don't use Ex mode, use Q for formatting
map Q gq

" ----  F-Keys  -----
" FOr the upper-left-cramped IBM thinkpad keyboard... no more F1 -> help!!!
map <F1> <Esc>
imap <F1> <Esc>
vmap <F1> <Esc>

" Compiler integration -- past F12 inteded for left side on a Sun keyboard
map <F13> :make<CR>
" These work with :grep matches, too
map <F12> :cn<CR>
map <F14> :cc<CR>
map <F17> :colder<CR>
map <F18> :cnewer<CR>

"Buffer moving
map <F8> :bp<CR>
map <F9> :bn<CR>

map ,# :s/^/# /<CR>:nohlsearch<CR>
map ,/ :s/^/\/\/ /<CR>:nohlsearch<CR>
map ,> :s/^/> /<CR>:nohlsearch<CR>
map ," :s/^/\" /<CR>:nohlsearch<CR>
map ,% :s/^/% /<CR>:nohlsearch<CR>
map ,! :s/^/! /<CR>:nohlsearch<CR>
map ,; :s/^/; /<CR>:nohlsearch<CR>
map ,- :s/^/-- /<CR>:nohlsearch<CR>
map ,c :s/^\/\/\\|^--\\|^> \\|^[#"%!;]//<CR>:nohlsearch<CR>
" wrapping comments
map ,* :s/^\(.*\)$/\/\* \1 \*\//<CR>:nohlsearch<CR>
map ,( :s/^\(.*\)$/\(\* \1 \*\)/<CR>:nohlsearch<CR>
map ,< :s/^\(.*\)$/<!-- \1 -->/<CR>:nohlsearch<CR>
map ,d :s/^\([/(]\*\\|<!--\) \(.*\) \(\*[/)]\\|-->\)$/\2/<CR>:nohlsearch<CR>

" UN-commenting -- just kill first token on line, works only for lhs comments
map ,, :s/\s*\S*\s\(.*\)/\1/<CR>:nohlsearch<CR>

" map quick list navigation next and prev in list
map } :cn<CR>
map { :cp<CR>

" Paste Mode On/Off
map <F11> :call Paste_on_off()<CR>
set pastetoggle=<F11>

let paste_mode = 0 " 0 = normal, 1 = paste
func! Paste_on_off()
   if g:paste_mode == 0
       set paste
       let g:paste_mode = 1
   else
       set nopaste
       let g:paste_mode = 0
   endif
   return
endfunc

"set path+=$PWD/**

if !exists("autocommands_loaded")
  let autocommands_loaded = 1
  autocmd BufRead,BufNewFile,FileReadPost *.py source ~/.vim/python
endif

" This beauty remembers where you were the last time you edited the file, and returns to the same position.
au BufReadPost * if line("'\"") > 0|if line("'\"") <= line("$")|exe("norm '\"")|else|exe "norm $"|endif|endif

let g:miniBufExplMapWindowNavVim = 1
let g:miniBufExplMapWindowNavArrows = 1
let g:miniBufExplMapCTabSwitchBufs = 1
let g:miniBufExplModSelTarget = 1
set number

let g:xml_syntax_folding=1
au FileType xml setlocal foldmethod=syntax
au FileType python setlocal foldmethod=indent
"set noendofline binary (use this to remove last eof on a file
let g:erlang_folding=1
:let g:erlang_highlight_bif=1

map <F2> :NERDTree<CR>

autocmd BufWritePre * :%s/\s\+$//e
set mouse=a
