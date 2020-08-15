command! -nargs=* TermvimTopOpen call termvim#openTerm('top', '<args>', '')
command! -nargs=* TermvimTopToggle call termvim#toggle('top', '<args>', '')
command! TermvimTopHide call termvim#hideTerms('top')

command! -nargs=* TermvimBottomOpen call termvim#openTerm('bottom', '<args>', '')
command! -nargs=* TermvimBottomToggle call termvim#toggle('bottom', '<args>', '')
command! TermvimBottomHide call termvim#hideTerms('bottom')

command! -nargs=* TermvimLeftOpen call termvim#openTerm('left', '<args>', '')
command! -nargs=* TermvimLeftToggle call termvim#toggle('left', '<args>', '')
command! TermvimLeftHide call termvim#hideTerms('left')

command! -nargs=* TermvimRightOpen call termvim#openTerm('right', '<args>', '')
command! -nargs=* TermvimRightToggle call termvim#toggle('right', '<args>', '')
command! TermvimRightHide call termvim#hideTerms('right')

command! -nargs=* TermvimTabToggle call termvim#toggle('tab', '<args>', '')

if !exists('g:termvim_left_size')
  let g:termvim_left_size = 50
endif

if !exists('g:termvim_right_size')
  let g:termvim_right_size = 50
endif

if !exists('g:termvim_top_size')
  let g:termvim_top_size = 10
endif

if !exists('g:termvim_bottom_size')
  let g:termvim_bottom_size = 10
endif

function! s:termvim_hide() abort
  let l:winid = win_getid()
  let l:sideWins = termvim#getTabTopWins()
  let l:sideTermWins = termvim#filterTermWins(l:sideWins)
  if len(l:sideTermWins) > 0 && len(l:sideTermWins) ==# len(l:sideWins)
    for l:win in l:sideWins
      if l:winid ==# l:win['winid']
        TermvimTopHide
        return
      endif
    endfor
  endif
  let l:sideWins = termvim#getTabBottomWins()
  let l:sideTermWins = termvim#filterTermWins(l:sideWins)
  if len(l:sideTermWins) > 0 && len(l:sideTermWins) ==# len(l:sideWins)
    for l:win in l:sideWins
      if l:winid ==# l:win['winid']
        TermvimBottomHide
        return
      endif
    endfor
  endif
  let l:sideWins = termvim#getTabLeftWins()
  let l:sideTermWins = termvim#filterTermWins(l:sideWins)
  if len(l:sideTermWins) > 0 && len(l:sideTermWins) ==# len(l:sideWins)
    for l:win in l:sideWins
      if l:winid ==# l:win['winid']
        TermvimLeftHide
        return
      endif
    endfor
  endif
  let l:sideWins = termvim#getTabRightWins()
  let l:sideTermWins = termvim#filterTermWins(l:sideWins)
  if len(l:sideTermWins) > 0 && len(l:sideTermWins) ==# len(l:sideWins)
    for l:win in l:sideWins
      if l:winid ==# l:win['winid']
        TermvimRightHide
        return
      endif
    endfor
  endif
endfunction

augroup TermvimAug
  autocmd!
  if has('nvim')
    autocmd TermOpen * nnoremap q :call <SID>termvim_hide()<CR> | nnoremap <CR> :call <SID>termvim_hide()<CR>
  else
    autocmd TerminalOpen * nnoremap q :call <SID>termvim_hide()<CR> | nnoremap <CR> :call <SID>termvim_hide()<CR>
  endif
augroup END
