function! nox#config#roots() abort
  return extend([g:nox_union_root], g:nox_roots)
endfunction
