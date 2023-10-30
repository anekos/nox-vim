function! nox#autocmd#on_buf_write_pre(filepath)
  call nox#buffer#pre()
endfunction


function! nox#autocmd#on_buf_write_post(filepath)
  call nox#document#index(a:filepath)
endfunction


" XXX A workaround for an issue where the file is not actually written to.
function! nox#autocmd#on_buf_write_cmd_old(filepath)
  call nox#buffer#pre()
  let l:dir = fnamemodify(a:filepath, ':h')
  call mkdir(l:dir, 'p')
  call writefile(getline(0, '$'), a:filepath)
  call nox#document#index(a:filepath)
endfunction


function! nox#autocmd#on_buf_read_cmd(url)
  let l:id = nox#id#from_url(a:url)
  let l:source = nox#api#get_source(l:id)
  set filetype=nox

  if type(l:source) == type(v:null)
    call nox#buffer#new_with_id(l:id)
    let b:nox_new_buffer = v:true
    return
  endif

  let b:nox_new_buffer = v:false
  call setline(1, l:source)
endfunction


function! nox#autocmd#on_buf_write_cmd(url)
  let l:id = nox#id#from_url(a:url)
  call nox#buffer#pre()
  let l:buffer_content = join(getline(1, '$'), "\n")
  if b:nox_new_buffer
    call nox#api#new_document_from_source(l:id, l:buffer_content)
    let b:nox_new_buffer = v:false
  else
    call nox#api#update_document_from_source(l:id, l:buffer_content)
  endif
endfunction
