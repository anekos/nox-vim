" Init {{{
if exists('g:loaded_nox_browser_autoload') && g:loaded_nox_browser_autoload
  finish
endif

let g:loaded_nox_browser_autoload = 1
let s:save_cpo = &cpo
set cpo&vim
" }}}

function! nox#browser#open(id) abort
  if a:id == ''
    let l:id = nox#buffer#document_id()
  else
    let l:id = a:id
  endif
  call v:lua.require('nox.command').open_browser(l:id)
endfunction


" Finalize {{{
let &cpo = s:save_cpo
unlet s:save_cpo
" }}}
