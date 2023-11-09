function! nox#util#datetime() abort
  let language = v:lc_time
  try
    execute 'silent!' 'language' 'time' 'C'
    return strftime('%a, %d %b %Y %H:%M:%S %z')
  finally
    execute ':silent! language time ' . language
  endtry
endfunction


function! nox#util#datetime_to_api_format(at)
  if type(l:updated_at) == type(v:null)
    return v:null
  endif
  let l:at = a:at
  let l:at = strptime('%a, %d %b %Y %H:%M:%S %z', l:at)
  let l:at = strftime('%Y-%m-%d %H:%M:%S%z', l:at)
  return l:at
endfunction
