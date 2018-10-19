" Set 'background' back to the default
hi clear Normal
set bg&

" Remove all existing highlighting and set the defaults.
hi clear

" Load the syntax highlighting defaults, if it's enabled.
if exists("syntax_on")
  syntax reset
endif

let colors_name = "one-light"

hi Comment          ctermfg=101         ctermbg=none

hi Constant         ctermfg=1           ctermbg=none
hi String           ctermfg=2           ctermbg=none
hi Character        ctermfg=10          ctermbg=none
hi Number           ctermfg=1           ctermbg=none
hi Boolean          ctermfg=1           ctermbg=none
hi Float            ctermfg=1           ctermbg=none
hi Identifier       ctermfg=9           ctermbg=none
hi Function         ctermfg=4           ctermbg=none

hi Statement        ctermfg=5           ctermbg=none
hi Conditional      ctermfg=5           ctermbg=none
hi Repeat           ctermfg=5           ctermbg=none
hi Label            ctermfg=5           ctermbg=none
hi Operator         ctermfg=5           ctermbg=none
hi Keyword          ctermfg=5           ctermbg=none
hi Exception        ctermfg=5           ctermbg=none

hi PreProc          ctermfg=5           ctermbg=none
hi Include          ctermfg=4           ctermbg=none
hi Define           ctermfg=5           ctermbg=none
hi Macro            ctermfg=4           ctermbg=none
hi PreCondit        ctermfg=5           ctermbg=none

hi Type             ctermfg=3           ctermbg=none
hi StorageClass     ctermfg=3           ctermbg=none
hi Structure        ctermfg=3           ctermbg=none
hi Typedef          ctermfg=3           ctermbg=none

hi Special          ctermfg=6           ctermbg=none
hi SpecialChar      ctermfg=251         ctermbg=none
hi Tag              ctermfg=4           ctermbg=none
hi Delimiter        ctermfg=2           ctermbg=none
hi SpecialComment   ctermfg=251         ctermbg=none
hi Debug            ctermfg=9           ctermbg=none

hi Underlined       ctermfg=4           ctermbg=none
hi Ignore           ctermfg=none        ctermbg=none
hi Error            ctermfg=9           ctermbg=none
hi Todo             ctermfg=9           ctermbg=none

hi SpecialKey       ctermfg=251         ctermbg=none
hi NonText          ctermfg=251         ctermbg=none

hi LineNr           ctermfg=251         ctermbg=none
hi Visual                               ctermbg=253

" vim: sw=2
