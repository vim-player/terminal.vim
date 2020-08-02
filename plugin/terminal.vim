command! TermvimTopOpen call termvim#openTerm('top')
command! TermvimTopToggle call termvim#toggle('top')
command! TermvimTopHide call termvim#hideTerms('top')

command! TermvimBottomOpen call termvim#openTerm('bottom')
command! TermvimBottomToggle call termvim#toggle('bottom')
command! TermvimBottomHide call termvim#hideTerms('bottom')

command! TermvimLeftOpen call termvim#openTerm('left')
command! TermvimLeftToggle call termvim#toggle('left')
command! TermvimLeftHide call termvim#hideTerms('left')

command! TermvimRightOpen call termvim#openTerm('right')
command! TermvimRightToggle call termvim#toggle('right')
command! TermvimRightHide call termvim#hideTerms('right')

command! -nargs=* TermvimWatch call termvim#watchTerm('<args>')
