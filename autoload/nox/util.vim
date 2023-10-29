function! nox#util#datetime() abort
  let language = v:lc_time
  try
    execute 'silent!' 'language' 'time' 'C'
    return strftime('%a, %d %b %Y %H:%M:%S %z')
  finally
    execute ':silent! language time ' . language
  endtry
endfunction
