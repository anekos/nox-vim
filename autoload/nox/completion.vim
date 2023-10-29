function! nox#completion#ogp_format(lead, cmd_line, cursor_pos) abort
  return nox#api#ogp_formats()
endfunction

let s:ids = v:null
let s:tags = v:null


function! s:id_match(id, query)
  for l:part in a:query
    if stridx(a:id, l:part) == -1
      return v:false
    endif
  endfor
  return v:true
endfunction


function! s:ancestors() abort
  if !nox#buffer#is_nox()
    return []
  endif

  let l:id = nox#buffer#document_id()
  let l:parts = split(l:id, '/')

  let l:result = []

  for l:idx in range(len(l:parts) - 1, 0, -1)
    call add(l:result, 'id="' . join(l:parts[:l:idx], '/') . '"')
  endfor

  return l:result
endfunction


function! s:tags() abort
  let l:result = []
  for l:tag in nox#buffer#tags()
    call add(l:result, 'tag=' . l:tag)
  endfor
  return l:result
endfunction


function! nox#completion#ids(lead, cmd_line, cursor_pos) abort
  if s:ids is v:null
    let s:ids = nox#api#ids(v:null)
  endif

  let l:query = split(a:cmd_line, '\v[ \n,]+')[1:]

  let l:ids = copy(s:ids)

  try
    let l:id = nox#buffer#document_id()
    call insert(l:ids, l:id)
  catch
  endtry

  return filter(copy(l:ids), {idx, val -> s:id_match(tolower(val), l:query)})
endfunction


function! nox#completion#tags(lead, cmd_line, cursor_pos) abort
  if s:tags is v:null
    let s:tags = nox#api#tags()
  endif

  let l:query = split(a:cmd_line, '\v[ \n,]+')[1:]

  return filter(copy(s:tags), {idx, val -> s:id_match(tolower(val), l:query)})
endfunction

function! nox#completion#related(lead, cmd_line, cursor_pos) abort
  return s:tags() + s:ancestors()
endfunction
