function! nox#id#extract(fp) abort
  for l:root in nox#config#roots()
    if stridx(a:fp, l:root) == 0
      return a:fp[len(l:root)+1:-5]
    endif
  endfor
  return ''
endfunction
