set background=dark

hi clear
if exists("syntax_on")
    syntax reset
endif
let g:colors_name="eyecandy"

" general colors
hi Normal ctermbg=235
hi LineNr ctermfg=249 ctermbg=236
hi Cursor ctermfg=255 ctermbg=16
hi CursorLine cterm=NONE ctermbg=236
hi CursorLineNR ctermfg=255 ctermbg=240
hi Directory ctermfg=75
hi ErrorMsg ctermbg=196 ctermfg=white
hi VertSplit ctermfg=236
hi NonText ctermfg=235
hi Pmenu ctermfg=255 ctermbg=239
hi PmenuSel ctermfg=255 ctermbg=237
hi Search ctermfg=234 ctermbg=255
hi SpellBad ctermfg=196 ctermbg=NONE


" syntax highlighting groups
hi Comment ctermfg=105
hi Constant ctermfg=120
hi Identifier ctermfg=81
hi Statement ctermfg=198
hi Type ctermfg=81
hi Function ctermfg=81
hi Special ctermfg=198
hi Error ctermfg=196
hi PreProc ctermfg=105
hi String ctermfg=120



" spell check colors
hi SpellBad cterm=underline ctermfg=196
hi SpellCap cterm=underline ctermfg=196
hi SpellRare cterm=underline ctermfg=196
hi SpellLocal cterm=underline ctermfg=171 ctermbg=None
