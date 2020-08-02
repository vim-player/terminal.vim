" <space>' 打开 terminal
let s:tabTermInfo = {
  \ 'top': {},
  \ 'bottom': {},
  \ 'left': {},
  \ 'right': {}
  \ }
let s:tabLastWinId = {
  \ 'top': {},
  \ 'bottom': {},
  \ 'left': {},
  \ 'right': {}
  \ }
let s:watchChanel = {}
let s:vimBufs = []

" 获取当前 tab 下面的所有 windows
function! termvim#getTabWins() abort
  let l:tabnr = tabpagenr()
  let l:winlist = getwininfo()
  let l:wins = []
  for l:win in l:winlist
    if l:win['tabnr'] ==# l:tabnr
      call add(l:wins, l:win)
    endif
  endfor
  return l:wins
endfunction

" 获取当前 tab 所有最上边的 windows
function! termvim#getTabTopWins() abort
  let l:wins = termvim#getTabWins()
  let l:topRow = -1
  for l:win in l:wins
    let l:row = win_screenpos(l:win['winnr'])[0]
    if l:topRow ==# -1
      let l:topRow = l:row
    endif
    if l:row < l:topRow
      let l:topRow = l:row
    endif
  endfor
  let l:res = []
  for l:win in l:wins
    if win_screenpos(l:win['winnr'])[0] ==# l:topRow
      call add(l:res, l:win)
    endif
  endfor
  return l:res
endfunction

" 获取当前 tab 所有最下边的 windows
function! termvim#getTabBottomWins() abort
  let l:wins = termvim#getTabWins()
  let l:bottomRow = -1
  for l:win in l:wins
    let l:row = win_screenpos(l:win['winnr'])[0]
    if l:bottomRow ==# -1
      let l:bottomRow = l:row
    endif
    if l:row > l:bottomRow
      let l:bottomRow = l:row
    endif
  endfor
  let l:res = []
  for l:win in l:wins
    if win_screenpos(l:win['winnr'])[0] ==# l:bottomRow
      call add(l:res, l:win)
    endif
  endfor
  return l:res
endfunction

" 获取当前 tab 所有最左边的 windows
function! termvim#getTabLeftWins() abort
  let l:wins = termvim#getTabWins()
  let l:leftCol = -1
  for l:win in l:wins
    let l:col = win_screenpos(l:win['winnr'])[1]
    if l:leftCol ==# -1
      let l:leftCol = l:col
    endif
    if l:col < l:leftCol
      let l:leftCol = l:col
    endif
  endfor
  let l:res = []
  for l:win in l:wins
    if win_screenpos(l:win['winnr'])[1] ==# l:leftCol
      call add(l:res, l:win)
    endif
  endfor
  return l:res
endfunction

" 获取当前 tab 所有最右边的 windows
function! termvim#getTabRightWins() abort
  let l:wins = termvim#getTabWins()
  let l:rightCol = -1
  for l:win in l:wins
    let l:col = win_screenpos(l:win['winnr'])[1]
    if l:rightCol ==# -1
      let l:rightCol = l:col
    endif
    if l:col > l:rightCol
      let l:rightCol = l:col
    endif
  endfor
  let l:res = []
  for l:win in l:wins
    if win_screenpos(l:win['winnr'])[1] ==# l:rightCol
      call add(l:res, l:win)
    endif
  endfor
  return l:res
endfunction

" 过滤非 terminal windows
function! termvim#filterTermWins(wins) abort
  let l:res = []
  for l:win in a:wins
    if l:win['terminal']
      call add(l:res, l:win)
    endif
  endfor
  return l:res
endfunction

function! termvim#openTerm(side) abort
  let l:sideWins = []
  if a:side ==# 'top'
    let l:sideWins = termvim#getTabTopWins()
  elseif a:side ==# 'bottom'
    let l:sideWins = termvim#getTabBottomWins()
  elseif a:side ==# 'left'
    let l:sideWins = termvim#getTabLeftWins()
  elseif a:side ==# 'right'
    let l:sideWins = termvim#getTabRightWins()
  endif
  let l:sideTermWins = termvim#filterTermWins(l:sideWins)
  if len(l:sideTermWins) > 0 && len(l:sideTermWins) ==# len(l:sideWins)
    return
  endif
  let l:termWins = []
  let l:wins = get(s:tabTermInfo[a:side], tabpagenr(), [])
  for l:win in l:wins
    if bufexists(l:win['bufnr'])
      call add(l:termWins, l:win)
    endif
  endfor
  let l:firstWinid = 0
  let l:lastWinId = 0
  if len(l:termWins) > 0
    if a:side ==# 'top'
      topleft split
    elseif a:side ==# 'bottom'
      botright split
    elseif a:side ==# 'left'
      topleft vsplit
    elseif a:side ==# 'right'
      botright vsplit
    endif
    execute 'b' . l:termWins[0]['bufnr']
    if get(s:tabLastWinId[a:side], tabpagenr(), 0) ==# l:termWins[0]['winid']
      let l:lastWinId = win_getid()
    endif
    let l:firstWinid = win_getid()
    if a:side ==# 'top' || a:side ==# 'bottom'
      let l:splitRight = &splitright
      set splitright
    endif
    for l:win in l:termWins[1:]
      vsplit
      execute 'b' . l:win['bufnr']
      if get(s:tabLastWinId[a:side], tabpagenr(), 0) ==# l:win['winid']
        let l:lastWinId = win_getid()
      endif
    endfor
    if a:side ==# 'top' || a:side ==# 'bottom'
      let &splitright = l:splitRight
    endif
  else
    if has('nvim')
      if a:side ==# 'top'
        topleft split term://zsh
      elseif a:side ==# 'bottom'
        botright split term://zsh
      elseif a:side ==# 'left'
        topleft vsplit term://zsh
      elseif a:side ==# 'right'
        botright vsplit term://zsh
      endif
    else
      if a:side ==# 'top'
        topleft terminal
      elseif a:side ==# 'bottom'
        botright terminal
      elseif a:side ==# 'left'
        topleft vsplit
        terminal ++curwin
      elseif a:side ==# 'right'
        botright vsplit
        terminal ++curwin
      endif
    endif
  endif
  if a:side ==# 'top' || a:side ==# 'bottom'
    resize 10
  endif
  if l:lastWinId
    let l:firstWinid = l:lastWinId
  endif
  if l:firstWinid
    call win_gotoid(l:firstWinid)
    if has('nvim')
      startinsert
    else
      normal a
    endif
  endif
endfunction

function! termvim#hideTerms(side) abort
  let l:winid = win_getid()
  let l:sideWins = []
  if a:side ==# 'top'
    let l:sideWins = termvim#getTabTopWins()
  elseif a:side ==# 'bottom'
    let l:sideWins = termvim#getTabBottomWins()
  elseif a:side ==# 'left'
    let l:sideWins = termvim#getTabLeftWins()
  elseif a:side ==# 'right'
    let l:sideWins = termvim#getTabRightWins()
  endif
  let l:sideTermWins = termvim#filterTermWins(l:sideWins)
  if len(l:sideTermWins) > 0 && len(l:sideTermWins) ==# len(l:sideWins)
    if !exists('s:tabTermInfo.' . a:side)
      let s:tabTermInfo[a:side] = {}
    endif
    if !exists('s:tabLastWinId.' . a:side)
      let s:tabLastWinId[a:side] = {}
    endif
    let s:tabTermInfo[a:side][tabpagenr()] = l:sideTermWins
    let s:tabLastWinId[a:side][tabpagenr()] = l:winid
    for l:win in l:sideTermWins
      call win_gotoid(l:win['winid'])
      execute 'silent! close!'
    endfor
  endif
endfunction

function s:termOut(...) abort
  let l:ch = a:1
  if !has('nvim')
    let l:ch = split(a:1, ' ')[1]
  endif
  let l:bufnr = get(s:watchChanel, l:ch, 0)
  if !l:bufnr
    if !has('nvim') && s:vimBufs[-1]
      let l:bufnr = s:vimBufs[-1]
      let s:watchChanel[l:ch] = l:bufnr
      let s:vimBufs = s:vimBufs[0:-2]
    else
      return
    endif
  endif
  let l:wins = getwininfo()
  let l:isShow = v:false
  for l:win in l:wins
    if l:win['bufnr'] ==# l:bufnr
      let l:isShow = v:true
    endif
  endfor
  if !l:isShow
    tabnew
    execute 'b' . l:bufnr
    if has('nvim')
      normal G
      nnoremap <buffer> q :silent! tabclose<CR>:tabprevious<CR>
      nnoremap <buffer> <ESC> :silent! tabclose<CR>:tabprevious<CR>
    else
      normal a
      nnoremap <buffer> q :silent! close!<CR>:tabprevious<CR>
      nnoremap <buffer> <ESC> :silent! close!<CR>:tabprevious<CR>
    endif
  endif
endfunction

function! termvim#watchTerm(cmd) abort
  if has('nvim')
    let l:ch = termopen(a:cmd, {
      \  'on_stdout': function('s:termOut'),
      \  'on_stderr': function('s:termOut')
      \ })
    let s:watchChanel[l:ch] = bufnr()
  else
    let l:isWin = has('win32') && fnamemodify(&shell, ':t') ==? 'cmd.exe'
    let l:bufnr = term_start(!l:isWin ? ['/bin/sh', '-c', a:cmd] : ['cmd.exe', '/c', a:cmd],
          \ {
          \   "out_cb": function('s:termOut'),
          \   "err_cb": function('s:termOut'),
          \   "curwin": v:true
          \ }
          \)
    call add(s:vimBufs, l:bufnr)
  endif
endfunction

function! termvim#toggle(side) abort
  let l:sideWins = []
  if a:side ==# 'top'
    let l:sideWins = termvim#getTabTopWins()
  elseif a:side ==# 'bottom'
    let l:sideWins = termvim#getTabBottomWins()
  elseif a:side ==# 'left'
    let l:sideWins = termvim#getTabLeftWins()
  elseif a:side ==# 'right'
    let l:sideWins = termvim#getTabRightWins()
  endif
  let l:sideTermWins = termvim#filterTermWins(l:sideWins)
  if len(l:sideTermWins) > 0 && len(l:sideTermWins) ==# len(l:sideWins)
    call termvim#hideTerms(a:side)
  else
    call termvim#openTerm(a:side)
  endif
endfunction
