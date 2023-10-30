" Init {{{
if exists('g:loaded_nox_search_autoload') && g:loaded_nox_search_autoload
  finish
endif

let g:loaded_nox_search_autoload = 1
let s:save_cpo = &cpo
set cpo&vim
" }}}

let s:Http = vital#nox#import('Web.HTTP')

function! nox#search#open_search_result(target)
  for l:ln in range(line('.'), line('.') - 10, -1)
    let l:line = getline(l:ln)
    if l:line[0] != ' '
      let l:id = matchstr(l:line, '^[^#]\+#[0-9]*')
      if a:target != 'tab'
        bdelete
      endif
      call nox#document#open(l:id, v:false, a:target)
      return
    endif
  endfor
endfunction

" Finalize {{{
let &cpo = s:save_cpo
unlet s:save_cpo
" }}}
