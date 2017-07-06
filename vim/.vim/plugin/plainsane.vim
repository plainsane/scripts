" Vim color file
" Maintainer:	Bram Moolenaar <Bram@vim.org>
" Last Change:	2001 May 21

" This color scheme uses a dark grey background.

" First remove all existing highlighting.
set background=dark
hi clear
if exists("syntax_on")
  syntax reset
endif

let colors_name = "DaPlain"

hi Normal ctermbg=Black ctermfg=White guifg=White guibg=Black

" Groups used in the 'highlight' and 'guicursor' options default value.
hi ErrorMsg term=standout ctermbg=Red ctermfg=White guibg=Red guifg=White
hi IncSearch term=reverse cterm=reverse gui=reverse
hi ModeMsg term=bold cterm=bold gui=bold
hi StatusLine term=reverse,bold cterm=reverse,bold gui=reverse,bold
hi StatusLineNC term=reverse cterm=reverse gui=reverse
hi VertSplit term=reverse cterm=reverse gui=reverse
hi Visual term=reverse cterm=reverse gui=reverse guifg=White guibg=bg
hi VisualNOS term=underline,bold cterm=underline,bold gui=underline,bold
hi DiffText term=reverse cterm=bold ctermbg=Red gui=bold guibg=Red
hi Cursor ctermfg=Black ctermbg=Green guibg=Green guifg=Black
hi lCursor ctermfg=Black ctermbg=Cyan guibg=Cyan guifg=Black
hi Directory term=bold ctermfg=Yellow guifg=Yellow
hi PreProc  term=underline  ctermfg=Yellow guifg=Yellow
hi Operator term=underline  ctermfg=Yellow guifg=Yellow gui=bold
hi cOperator term=underline  ctermfg=Yellow guifg=Yellow gui=bold
hi cppOperator term=underline  ctermfg=Yellow guifg=Yellow gui=bold
hi cppCast term=underline  ctermfg=Yellow guifg=Yellow gui=bold
hi cStatement term=underline  ctermfg=Yellow guifg=Yellow gui=bold
hi cppStatement term=underline  ctermfg=Yellow guifg=Yellow gui=bold
hi Special term=underline  ctermfg=Yellow guifg=Yellow
hi Type term=underline      ctermfg=Yellow  guifg=Yellow gui=bold
hi Function term=bold       ctermfg=Red  guifg=Red
hi Number term=bold       ctermfg=Blue  guifg=#3c00ff
hi LineNr term=underline ctermfg=Yellow guifg=Yellow
hi MoreMsg term=bold ctermfg=Yellow gui=bold guifg=Yellow
hi NonText term=bold ctermfg=LightBlue gui=bold guifg=LightBlue guibg=Black
hi Question term=standout ctermfg=LightGreen gui=bold guifg=Green
hi Search term=reverse ctermbg=Yellow ctermfg=Black guibg=Yellow guifg=Black
hi Comment term=reverse ctermbg=Black ctermfg=Green guifg=#22ff00
hi SpecialKey term=bold ctermfg=LightBlue guifg=Cyan
hi Title term=bold ctermfg=Yellow gui=bold guifg=Yellow
hi WarningMsg term=standout ctermfg=Red guifg=Red
hi WildMenu term=standout ctermbg=Yellow ctermfg=Black guibg=Yellow guifg=Black
hi Folded term=standout ctermbg=LightGrey ctermfg=DarkBlue guibg=Black guifg=DarkBlue
hi FoldColumn term=standout ctermbg=LightGrey ctermfg=DarkBlue guibg=black guifg=DarkBlue
hi DiffAdd term=bold ctermbg=DarkBlue guibg=DarkBlue
hi DiffChange term=bold ctermbg=DarkMagenta guibg=DarkMagenta
hi DiffDelete term=bold ctermfg=Blue ctermbg=DarkCyan gui=bold guifg=Blue guibg=DarkCyan
hi LineNr term=bold cterm=NONE ctermfg=Black ctermbg=White gui=NONE guifg=DarkGrey guibg=NONE


" Groups for syntax highlighting
hi Constant term=underline ctermfg=Red guifg=Red guibg=Black
hi Special term=bold ctermfg=Red guifg=Orange guibg=Black
if &t_Co > 8
  hi Statement term=bold cterm=bold ctermfg=Yellow guifg=Yellow gui=bold
endif
hi Ignore ctermfg=DarkGrey guifg=Black

hi link String  Constant
hi link Character   Constant
hi link Number  Constant
hi link Boolean Constant
hi link Float       Number
hi link Conditional Repeat
hi link Label       Statement
hi link Keyword Statement
hi link Exception   Statement
hi link Include PreProc
hi link Define  PreProc
hi link Macro       PreProc
hi link PreCondit   PreProc
hi link StorageClass    Type
hi link Structure   Type
hi link Typedef Type
hi link Tag     Special
hi link SpecialChar Special
hi link Delimiter   Special
hi link SpecialComment Special
hi link Debug       Special
" vim: sw=2
