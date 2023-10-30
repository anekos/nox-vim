function! nox#id#from_url(url) abort
  if a:url !~# '^nox://'
    echoerr 'Invalid nox url: ' . a:url
  endif

  return a:url[6:]
endfunction


function! nox#id#to_url(id) abort
  return 'nox://' . a:id
endfunction
