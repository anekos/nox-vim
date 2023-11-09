function! nox#autocmd#on_buf_read_cmd(url)
  let l:id = nox#id#from_url(a:url)
  let l:source = nox#api#get_source(l:id)
  set filetype=nox

  if type(l:source) == type(v:null)
    call nox#buffer#new(l:id)
    let b:nox_new_buffer = v:true
    return
  endif

  let b:nox_new_buffer = v:false
  call setline(1, l:source)
endfunction


function! nox#autocmd#on_buf_write_cmd(url)
  let l:id = nox#id#from_url(a:url)

  let l:updated_at = nox#util#datetime_to_api_format(nox#buffer#get_attribute('updated-at'))

  call nox#buffer#pre()

  let l:buffer_content = join(getline(1, '$'), "\n")
  if b:nox_new_buffer
    call nox#api#new_document_from_source(l:id, l:buffer_content)
    let b:nox_new_buffer = v:false
  else
    echomsg l:updated_at
    call nox#api#update_document_from_source(l:id, l:buffer_content, l:updated_at)
  endif

  setlocal nomodified
endfunction
