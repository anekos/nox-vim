if exists('g:loaded_nox_search_clap')
  finish
endif
let g:loaded_nox_search_clap = 1
let s:save_cpo = &cpo
set cpo&vim

function! nox#clap#search(query) abort
  call clap#provider#nox_search#run(a:query)
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
