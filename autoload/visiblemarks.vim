if exists('s:save_cpo')| finish| endif
let s:save_cpo = &cpo| set cpo&vim
scriptencoding utf-8
"=============================================================================
let s:DEFAULT_PRIORITY = 8
let s:PREJUMP_PRIORITY = 6
let s:LASTCHANGE_PRIORITY = 4
"Misc:
function! s:delete_matches() "{{{
  for id in values(w:visiblemarks_ids)
    try
      call matchdelete(id)
    catch /E803/
      call s:_show_refresh_err(id)
    endtry
  endfor
endfunction
"}}}
function! s:_show_refresh_err(id) "{{{
  echoh ErrorMsg
  echom 'winnr: '. winnr(). ' '. v:throwpoint
  echom v:exception
  echom 'mark: '. get(filter(items(w:visiblemarks_ids), 'v:val[1]==a:id'), 0, [''])[0]. ' id: '. a:id
  echoh NONE
endfunction
"}}}
function! s:add_lowermatches() "{{{
  for chr in ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z']
    let w:visiblemarks_ids[chr] = matchadd('VisibleMarksLower', '\%'''. chr, s:DEFAULT_PRIORITY, w:visiblemarks_ids[chr])
  endfor
endfunction
"}}}
function! s:add_capitalmatches() "{{{
  for chr in ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z']
    let w:visiblemarks_ids[chr] = matchadd('VisibleMarksCapital', '\%'''. chr, s:DEFAULT_PRIORITY, w:visiblemarks_ids[chr])
  endfor
endfunction
"}}}
function! s:add_lastchangematch() "{{{
  if g:visiblemarks_hl_lastchanged
    let w:visiblemarks_ids.lastchanged = matchadd('VisibleMarksLastChanged', '\%''.', s:LASTCHANGE_PRIORITY, get(w:visiblemarks_ids, 'lastchanged', -1))
  end
endfunction
"}}}

function! visiblemarks#refresh() "{{{
  let winnr = winnr()
  let bufnr = bufnr('%')
  keepj windo call s:_refresh_crrwin(bufnr)
  exe winnr. 'wincmd w'
  if g:visiblemarks_hl_prejump
    call s:_refresh_prejump()
  end
endfunction
"}}}
function! s:_refresh_crrwin(bufnr) "{{{
  if bufnr('%')!=a:bufnr
    return
  end
  call s:delete_matches()
  call s:add_lowermatches()
  call s:add_capitalmatches()
  call s:add_lastchangematch()
endfunction
"}}}
function! s:_refresh_prejump() "{{{
  let id = w:visiblemarks.prejump_id
  call matchdelete(id)
  let w:visiblemarks.prejump_id = matchadd('VisibleMarksPrejump', '\%''''', s:PREJUMP_PRIORITY, id)
endfunction
"}}}
function! s:refresh_specified(marks) "{{{
  let winnr = winnr()
  let bufnr = bufnr('%')
  keepj windo call s:_refresh_specified_crrwin(a:marks, bufnr)
  exe winnr. 'wincmd w'
endfunction
"}}}
function! s:_refresh_specified_crrwin(marks, bufnr) "{{{
  if bufnr('%')!=a:bufnr
    return
  end
  for m in a:marks
    if !has_key(w:visiblemarks_ids, m)
      continue
    end
    let id = w:visiblemarks_ids[m]
    call matchdelete(id)
    let w:visiblemarks_ids[m] = matchadd((m=~'\u' ? 'VisibleMarksCapital' : 'VisibleMarksLower'), '\%'''. m, s:DEFAULT_PRIORITY, id)
  endfor
endfunction
"}}}

function! visiblemarks#_disable_prejump_match() "{{{
  if !(exists('w:visiblemarks') && has_key(w:visiblemarks, 'prejump_id'))
    return
  end
  try
    call matchdelete(w:visiblemarks.prejump_id)
  catch /E803/
  endtry
endfunction
"}}}
function! visiblemarks#_enable_prejump_match() "{{{
  if !g:visiblemarks_hl_prejump
    return
  end
  let w:visiblemarks.prejump_id = matchadd('VisibleMarksPrejump', '\%''''', s:PREJUMP_PRIORITY, get(w:visiblemarks, 'prejump_id', -1))
endfunction
"}}}
function! visiblemarks#_disable_lastchange_match() "{{{
  if !(exists('w:visiblemarks_ids') && has_key(w:visiblemarks_ids, 'lastchanged'))
    return
  end
  try
    call matchdelete(w:visiblemarks_ids.lastchanged)
  catch /E803/
  endtry
endfunction
"}}}
function! visiblemarks#_enable_lastchange_match() "{{{
  if !(exists('w:visiblemarks_ids') && g:visiblemarks_hl_lastchanged)
    return
  end
  let w:visiblemarks_ids.lastchanged = matchadd('VisibleMarksLastChanged', '\%''.', s:LASTCHANGE_PRIORITY, get(w:visiblemarks_ids, 'lastchanged', -1))
endfunction
"}}}

function! s:get_localmrks() "{{{
  let bufnr = bufnr('%')
  let ret = []
  for chr in ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z']
    let ret += [[chr, bufnr, line("'".chr), col("'".chr)]]
  endfor
  return ret
endfunction
"}}}
function! s:get_globalmrks() "{{{
  let ret = []
  for chr in ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z']
    let ret += [[chr] + getpos("'".chr)]
  endfor
  return ret
endfunction
"}}}

function! s:cmp(mrkA, mrkB) "{{{
  let ret = a:mrkA[2] - a:mrkB[2]
  return ret!=0 ? ret : a:mrkA[3] - a:mrkB[3]
endfunction
"}}}


"======================================
"Main:
function! visiblemarks#toggle_highlight() "{{{
  if !exists('w:visiblemarks')
    return
  elseif w:visiblemarks.enable_hl
    call s:disable_hl()
  else
    call s:enable_hl()
  end
endfunction
"}}}
function! s:disable_hl() "{{{
  call s:delete_matches()
  if has_key(w:visiblemarks, 'prejump_id')
    try
      call matchdelete(w:visiblemarks.prejump_id)
    catch /E803/
      call s:_show_refresh_err(w:visiblemarks.prejump_id)
    endtry
  end
  let w:visiblemarks.enable_hl = 0
endfunction
"}}}
function! s:enable_hl() "{{{
  call s:add_lowermatches()
  call s:add_capitalmatches()
  call s:add_lastchangematch()
  call visiblemarks#_enable_prejump_match()
  let w:visiblemarks.enable_hl = 1
endfunction
"}}}
function! visiblemarks#setmark(...) "{{{
  let chr = a:0 ? a:1 : nr2char(getchar())
  if chr!~#'[[:alpha:]''`]'
    return
  end
  exe 'norm! m'. chr
  call s:refresh_specified([chr])
  echo 'set mark "'
  echoh Exception
  echon chr
  echoh NONE
  echon '" at line '. line('.'). ', column '. col('.')
endfunction
"}}}
function! visiblemarks#setavailablemark() "{{{
  for chr in ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z']
    if !line("'". chr)
      call visiblemarks#setmark(chr)
      return
    end
  endfor
  echoh ErrorMsg
  echo 'No available marks.'
  echoh NONE
endfunction
"}}}
function! visiblemarks#togglemark() "{{{
  let crrrow = line('.')
  let mrks = filter(s:get_localmrks(), 'v:val[2]==crrrow')
  if mrks==[]
    call visiblemarks#setavailablemark()
  else
    call visiblemarks#delmark(mrks[-1][0])
  end
endfunction
"}}}
function! visiblemarks#delmark(...) "{{{
  let chr = a:0 ? a:1 : nr2char(getchar())
  if chr=='%'
    call s:del_allmarks()
  elseif chr=='.'
    call s:del_crrrowmarks()
  elseif chr=~#'[[:alnum:]`[\]^]'
    call s:del_mark(chr)
  end
endfunction
"}}}
function! s:del_allmarks() abort "{{{
  delmarks!
  call visiblemarks#refresh()
  echo 'deleted all marks for the current buffer.'
  if g:visiblemarks_refresh_viminfo
    wviminfo!
  end
endfunction
"}}}
function! s:del_crrrowmarks() "{{{
  let crrrow = line('.')
  let mrks = filter(s:get_localmrks(), 'v:val[2]==crrrow')
  if mrks==[]
    echo 'no marks in current line.'
    return
  end
  let line = join(map(sort(mrks, 's:cmp'), 'v:val[0]'))
  exe 'delmarks' line
  call s:refresh_specified(mrks)
  echo 'deleted mark'. (len(mrks)>1 ? 's ': ' ')
  echoh Exception
  echon line
  echoh NONE
endfunction
"}}}
function! s:del_mark(chr) abort "{{{
  if !line("'". a:chr)
    echo 'mark "'. a:chr. '" is not set.'
    return
  end
  let [row, col] = [line("'". a:chr), col("'". a:chr)]
  exe 'delmarks' a:chr
  call s:refresh_specified([a:chr])
  echo 'deleted mark "'
  echoh Exception
  echon a:chr
  echoh NONE
  echon '" from line '. row. ', column '. col
  if g:visiblemarks_refresh_viminfo && a:chr=~'\u'
    wviminfo!
  end
endfunction
"}}}
function! visiblemarks#ljump(...) "{{{
  call s:jump("'", a:0 ? a:1 : nr2char(getchar()))
endfunction
"}}}
function! visiblemarks#cjump(...) "{{{
  call s:jump("`", a:0 ? a:1 : nr2char(getchar()))
endfunction
"}}}
function! s:jump(jmpkey, mark) "{{{
  if a:mark !~# '[[:alnum:][\]<>''`"^.(){}]'
    return
  end
  try
    exe "norm! ". a:jmpkey. a:mark
  catch /E19:/
    echoh ErrorMsg
    echom v:exception
    echoh NONE
  endtry
  call visiblemarks#refresh()
endfunction
"}}}
function! visiblemarks#info_line() "{{{
  let crrrow = line('.')
  let bufnr = bufnr('%')
  let mrks = filter(s:get_localmrks(), 'v:val[2]==crrrow') + filter(s:get_globalmrks(), 'v:val[1]==bufnr && v:val[2]==crrrow')
  if mrks==[]
    echo 'no marks in current line.'
    return
  end
  call s:show_info(mrks)
endfunction
"}}}
function! visiblemarks#info_win() "{{{
  let wtrow = line('w0')
  let wbrow = line('w$')
  let bufnr = bufnr('%')
  let mrks = filter(s:get_localmrks(), 'v:val[2] >= wtrow && v:val[2] <= wbrow') + filter(s:get_globalmrks(), 'v:val[1]==bufnr && v:val[2]>=wtrow && v:val[2]<=wbrow')
  if mrks==[]
    echo 'no marks in current view.'
    return
  end
  call s:show_info(mrks)
endfunction
"}}}
function! visiblemarks#info_buf() "{{{
  let bufnr = bufnr('%')
  let mrks = filter(s:get_localmrks(), 'v:val[2]!=0') + filter(s:get_globalmrks(), 'v:val[1]==bufnr && v:val[2]!=0')
  if mrks==[]
    echo 'no marks in current buffer.'
    return
  end
  call s:show_info(mrks)
endfunction
"}}}
function! s:show_info(mrks) "{{{
  let row = 0
  let save_row = 0
  let pad = 0
  echoh Exception
  for mrk in sort(a:mrks, 's:cmp')
    if row!=mrk[2]
      echoh NONE
      echon !g:visiblemarks_show_linemsg || pad==0 ? '' : repeat(' ', pad<0 ? 1 : pad). ': '. getline(save_row)
      let pad = 11
      let row = mrk[2]
      let save_row = row
      echo printf('line %3d:', row)
      echoh Exception
    end
    echon ' '. mrk[0]
    let pad -= 2
  endfor
  echoh NONE
  echon !g:visiblemarks_show_linemsg || pad==0 ? '' : repeat(' ', pad<0 ? 1 : pad). ': '. getline(save_row)
endfunction
"}}}

"=============================================================================
"END "{{{1
let &cpo = s:save_cpo| unlet s:save_cpo
