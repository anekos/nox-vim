function! nox#id#extract(fp) abort
  for l:root in nox#config#roots()
    if stridx(a:fp, l:root) == 0
      return a:fp[len(l:root)+1:-5]
    endif
  endfor
  return ''
endfunction


function! nox#id#from_url(url) abort
  if a:url !~# '^nox://'
    echoerr 'Invalid nox url: ' . a:url
  endif

  return a:url[6:]
endfunction


function! nox#id#to_url(id) abort
  return 'nox://' . a:id
endfunction
