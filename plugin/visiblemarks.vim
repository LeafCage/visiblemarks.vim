if expand('<sfile>:p')!=#expand('%:p') && exists('g:loaded_visiblemarks')| finish| endif| let g:loaded_visiblemarks = 1
let s:save_cpo = &cpo| set cpo&vim
scriptencoding utf-8
"=============================================================================
let g:visiblemarks_hl_prejump = get(g:, 'visiblemarks_hl_prejump', 0)
let g:visiblemarks_hl_lastchanged = get(g:, 'visiblemarks_hl_lastchanged', 0)
let g:visiblemarks_refresh_viminfo = get(g:, 'visiblemarks_refresh_viminfo', 1)
let g:visiblemarks_show_linemsg = get(g:, 'visiblemarks_show_linemsg', 0)

nnoremap <silent><Plug>(visiblemarks-m)    :<C-u>call visiblemarks#setmark()<CR>
nnoremap <silent><Plug>(visiblemarks-m,)    :<C-u>call visiblemarks#setavailablemark()<CR>
nnoremap <silent><Plug>(visiblemarks-m.)    :<C-u>call visiblemarks#togglemark()<CR>
nnoremap <silent><Plug>(visiblemarks-dm)    :<C-u>call visiblemarks#delmark()<CR>
nnoremap <silent><Plug>(visiblemarks-info-line)    :<C-u>call visiblemarks#info_line()<CR>
nnoremap <silent><Plug>(visiblemarks-info-win)    :<C-u>call visiblemarks#info_win()<CR>
nnoremap <silent><Plug>(visiblemarks-info-buf)    :<C-u>call visiblemarks#info_buf()<CR>
noremap <silent><Plug>(visiblemarks-')    :<C-u>call visiblemarks#ljump()<CR>
noremap <silent><Plug>(visiblemarks-'')    :<C-u>call visiblemarks#ljump("'")<CR>
noremap <silent><Plug>(visiblemarks-`)    :<C-u>call visiblemarks#cjump()<CR>
noremap <silent><Plug>(visiblemarks-``)    :<C-u>call visiblemarks#cjump('`')<CR>

command! -nargs=0   VisibleMarksShow    call visiblemarks#info_buf()
command! -nargs=0   VisibleMarksToggleHighlight    call visiblemarks#toggle_highlight()

aug visiblemarks
  autocmd!
  autocmd ColorScheme *   call s:define_hl{&bg=='dark' ? '_dark' : ''}()
  autocmd VimEnter *   call s:init_matches()
  autocmd WinEnter *   if exists('w:visiblemarks_ids') | call visiblemarks#_enable_prejump_match() | else | call s:init_matches() | endif
  autocmd WinLeave *  call visiblemarks#_disable_prejump_match()
  autocmd InsertEnter *   call visiblemarks#_disable_lastchange_match()
  autocmd InsertLeave *   call visiblemarks#_enable_lastchange_match()
aug END

let s:DEFAULT_PRIORITY = 8
let s:PREJUMP_PRIORITY = 6
let s:LASTCHANGE_PRIORITY = 4

function! s:define_hl_dark() "{{{
  highlight default VisibleMarksLower   gui=bold cterm=bold guibg=DarkRed ctermbg=DarkRed term=bold,reverse
  highlight default VisibleMarksCapital   gui=bold,underline cterm=bold,underline guibg=DarkMagenta ctermbg=DarkMagenta term=bold,reverse,underline
  highlight default VisibleMarksPrejump  guibg=DarkBlue guifg=White ctermbg=DarkBlue
  highlight default VisibleMarksLastChanged  gui=reverse cterm=reverse
endfunction
"}}}
function! s:define_hl() "{{{
  highlight default VisibleMarksLower   gui=bold cterm=bold guibg=LightRed ctermbg=LightRed term=bold,reverse
  highlight default VisibleMarksCapital   gui=bold,underline cterm=bold,underline guibg=Cyan ctermbg=Cyan term=bold,reverse,underline
  highlight default VisibleMarksPrejump  guibg=LightCyan ctermbg=LightCyan
  highlight default VisibleMarksLastChanged  gui=reverse cterm=reverse
endfunction
"}}}
function! s:init_matches() "{{{
  let w:visiblemarks_ids = {}
  for char in ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z']
    let w:visiblemarks_ids[char] = matchadd('VisibleMarksLower', '\%'''. char, s:DEFAULT_PRIORITY)
  endfor
  for char in ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z']
    let w:visiblemarks_ids[char] = matchadd('VisibleMarksCapital', '\%'''. char, s:DEFAULT_PRIORITY)
  endfor
  if g:visiblemarks_hl_lastchanged
    let w:visiblemarks_ids.lastchanged = matchadd('VisibleMarksLastChanged', '\%''.', s:LASTCHANGE_PRIORITY)
  end
  let w:visiblemarks = {}
  if g:visiblemarks_hl_prejump
    let w:visiblemarks.prejump_id = matchadd('VisibleMarksPrejump', '\%''''', s:PREJUMP_PRIORITY)
  end
  let w:visiblemarks.enable_hl = 1
endfunction
"}}}

"=============================================================================
"END "{{{1
let &cpo = s:save_cpo| unlet s:save_cpo
