" <space>' 打开 terminal
let s:tabTermInfo = {
  \ 'top': {},
  \ 'bottom': {},
  \ 'left': {},
  \ 'right': {},
  \ 'tabBufnr': -1
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
      let l:bottomRow = l:row + l:win['height']
    endif
    if l:row + l:win['height'] > l:bottomRow
      let l:bottomRow = l:row + l:win['height']
    endif
  endfor
  let l:res = []
  for l:win in l:wins
    if win_screenpos(l:win['winnr'])[0] + l:win['height'] ==# l:bottomRow
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
      let l:rightCol = l:col + l:win['width']
    endif
    if l:col + l:win['width'] > l:rightCol
      let l:rightCol = l:col + l:win['width']
    endif
  endfor
  let l:res = []
  for l:win in l:wins
    if win_screenpos(l:win['winnr'])[1] + l:win['width'] ==# l:rightCol
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

function! termvim#openTerm(side, extra, bufnr) abort
  let l:isWatch = v:false
  let l:params = split(a:extra, ' ')
  for l:param in l:params
    if l:param ==# 'watch'
      let l:isWatch = v:true
    endif
    if l:param =~# '\v^\d+$'
      let l:size = l:param
    endif
  endfor
  if a:side ==# 'top'
    let l:size = get(l:, 'size', g:termvim_top_size)
  elseif a:side ==# 'bottom'
    let l:size = get(l:, 'size', g:termvim_bottom_size)
  elseif a:side ==# 'left'
    let l:size = get(l:, 'size', g:termvim_left_size)
  elseif a:side ==# 'right'
    let l:size = get(l:, 'size', g:termvim_right_size)
  endif
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
  let l:targetWinId = 0
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
    if l:termWins[0]['bufnr'] ==# a:bufnr
      let l:targetWinId = win_getid()
    endif
    let l:firstWinid = win_getid()
    if a:side ==# 'top' || a:side ==# 'bottom'
      let l:splitRight = &splitright
      set splitright
    else
      let l:splitBelow = &splitright
      set splitbelow
    endif
    for l:win in l:termWins[1:]
      if a:side ==# 'top' || a:side ==# 'bottom'
        vsplit
      else
        split
      endif
      execute 'b' . l:win['bufnr']
      if get(s:tabLastWinId[a:side], tabpagenr(), 0) ==# l:win['winid']
        let l:lastWinId = win_getid()
      endif
      if l:win['bufnr'] ==# a:bufnr
        let l:targetWinId = win_getid()
      endif
    endfor
    if a:side ==# 'top' || a:side ==# 'bottom'
      let &splitright = l:splitRight
    else
      let &splitbelow = l:splitBelow
    endif
  else
    if has('nvim')
      if a:side ==# 'top'
        if l:isWatch
          topleft split
          call termvim#watchTerm()
        else
          execute 'topleft split term://' . &shell
        endif
      elseif a:side ==# 'bottom'
        if l:isWatch
          botright split
          call termvim#watchTerm()
        else
          execute 'botright split term://' . &shell
        endif
      elseif a:side ==# 'left'
        if l:isWatch
          topleft vsplit
          call termvim#watchTerm()
        else
          execute 'topleft vsplit term://' . &shell
        endif
      elseif a:side ==# 'right'
        if l:isWatch
          botright vsplit
          call termvim#watchTerm()
        else
          execute 'botright vsplit term://' . &shell
        endif
      endif
    else
      if a:side ==# 'top'
        if l:isWatch
          topleft split
          call termvim#watchTerm()
        else
          topleft terminal
        endif
      elseif a:side ==# 'bottom'
        if l:isWatch
          botright split
          call termvim#watchTerm()
        else
          botright terminal
        endif
      elseif a:side ==# 'left'
        topleft vsplit
        if l:isWatch
          call termvim#watchTerm()
        else
          terminal ++curwin
        endif
      elseif a:side ==# 'right'
        botright vsplit
        if l:isWatch
          call termvim#watchTerm()
        else
          terminal ++curwin
        endif
      endif
    endif
  endif
  if a:side ==# 'top' || a:side ==# 'bottom'
    execute 'resize ' . l:size
  else
    execute 'vertical resize ' . l:size
  endif
  if l:lastWinId
    let l:firstWinid = l:lastWinId
  endif
  if l:targetWinId
    call win_gotoid(l:targetWinId)
    if has('nvim')
      normal G
    else
      normal a
    endif
  elseif l:firstWinid
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
  let l:showTab = -1
  for l:win in l:wins
    if l:win['bufnr'] ==# l:bufnr
      let l:showTab = l:win['bufnr']
      let l:isShow = v:true
    endif
  endfor
  if !l:isShow
    for l:side in ['top', 'bottom', 'left', 'right']
      let l:tabsTerms = s:tabTermInfo[l:side]
      let l:tabs = gettabinfo()
      for l:tab in l:tabs
        let l:wins = get(l:tabsTerms, l:tab['tabnr'], [])
        for l:win in l:wins
          if l:win['bufnr'] ==# l:bufnr
            let l:done = v:true
            execute 'normal ' . l:tab['tabnr'] . 'gt'
            call termvim#toggle(l:side, '', l:bufnr)
          endif
        endfor
      endfor
    endfor

    if !get(l:, 'done', v:false)
      tabnew
      execute 'b' . l:bufnr
      if has('nvim')
        normal G
      else
        normal a
      endif
      nnoremap <buffer> q :silent! close!<CR>:tabprevious<CR>
      nnoremap <buffer> <ESC> :silent! close!<CR>:tabprevious<CR>
    endif
  elseif l:showTab !=# tabpagenr()
    execute 'normal ' . l:showTab . 'gt'
    if has('nvim')
      normal G
    else
      normal a
    endif
  endif
endfunction

function! termvim#watchTerm(...) abort
  if has('nvim')
    e new
    let l:ch = termopen(&shell, {
      \  'on_stdout': function('s:termOut'),
      \  'on_stderr': function('s:termOut')
      \ })
    let s:watchChanel[l:ch] = bufnr()
  else
    let l:bufnr = term_start(&shell,
          \ {
          \   "out_cb": function('s:termOut'),
          \   "err_cb": function('s:termOut'),
          \   "curwin": v:true
          \ }
          \)
    call add(s:vimBufs, l:bufnr)
  endif
endfunction

function! termvim#toggle(side, extra, bufnr) abort
  if a:side !=# 'tab'
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
      call termvim#openTerm(a:side, a:extra, a:bufnr)
    endif
  else
    if s:tabTermInfo.tabBufnr !=# -1 && bufexists(s:tabTermInfo.tabBufnr)
      let l:wins = getwininfo()
      for l:win in l:wins
        if l:win['bufnr'] ==# s:tabTermInfo.tabBufnr
          let l:showWin = l:win
        endif
      endfor
      if exists('l:showWin')
        execute 'silent! tabclose!' . l:showWin['tabnr']
      else
        tabnew
        execute 'b' . s:tabTermInfo.tabBufnr
        normal G
      endif
    else
      let l:sideWins = termvim#getTabWins()
      let l:sideTermWins = termvim#filterTermWins(l:sideWins)
      if len(l:sideTermWins) ==# 1 && len(l:sideTermWins) ==# len(l:sideWins)
        let s:tabTermInfo.tabBufnr = l:sideTermWins[0]['bufnr']
        silent! tabclose!
      else
        tabnew
        call termvim#watchTerm()
      endif
    endif
  endif
endfunction
