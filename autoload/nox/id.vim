function! nox#id#from_url(url) abort
  if a:url !~# '^nox://'
    echoerr 'Invalid nox url: ' . a:url
  endif

  return a:url[6:]
endfunction


function! nox#id#to_url(id) abort
  return 'nox://' . a:id
endfunction


function! nox#id#cleanup(path)
  if a:path =~# '^nox://'
    return  a:path[6:]
  endif
  if a:path =~# '\.nox$'
    return a:path[:-5]
  endif
  return a:path
endfunction

function! nox#id#make_title(id) abort
  let l:segs = split(a:id, '/')
  return l:segs[-1]
endfunction
