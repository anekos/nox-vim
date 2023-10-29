function! s:update_attribute(source, name, value, insert_after, overwrite)
  let l:position = 'before_header'
  let l:lnum = -1
  let l:append_to = -1
  let l:result = copy(a:source)

  for line in a:source
    let l:lnum += 1

    if l:position == 'before_header'
      if line != ''
        let l:position = 'header'
      endif
    endif

    if l:position == 'header'
      if l:line == ''
        break
      elseif l:line =~# ('^' . a:insert_after .': ')
        let l:append_to = l:lnum
      elseif line =~# ('^' . a:name . ': ')
        if a:overwrite
          let l:result[l:lnum] = a:name . ': ' . a:value
        endif
        return l:result
      endif
    endif
  endfor

  let l:line = a:name . ': ' . a:value

  if 0 <= l:append_to
    call insert(l:result, l:line, l:append_to + 1)
  else
    call insert(l:result, l:line, l:lnum)
  endif

  return l:result
endfunction

function! nox#edit#pre(source)
  let l:at = strftime('%a, %d %b %Y %H:%M:%S %z')
  let l:result = a:source
  let l:result = s:update_attribute(l:result, 'created-at', l:at, 'title', v:false)
  let l:result = s:update_attribute(l:result, 'updated-at', l:at, 'created-at', v:true)
  let l:ulid = ulid#generate()
  let l:result = s:update_attribute(l:result, 'ulid', l:ulid, 'title', v:false)
  return l:result
endfunction
