function! nox#autocmd#on_buf_read_cmd(url)
  let l:id = nox#id#from_url(a:url)
  let l:result = nox#api#get_source_with_meta(l:id)
  set filetype=nox

  if type(l:result) == type(v:null)
    call nox#buffer#new(l:id)
    let b:nox_new_buffer = v:true
    return
  endif

  let b:nox_new_buffer = v:false
  call setline(1, l:result.source)

  let b:nox_created_at = l:result.meta.created_at
  let b:nox_updated_at = l:result.meta.updated_at
endfunction
