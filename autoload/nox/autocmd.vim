function! nox#autocmd#on_buf_write_pre(filepath)
  call nox#buffer#pre()
endfunction


function! nox#autocmd#on_buf_write_post(filepath)
  call nox#document#index(a:filepath)
endfunction


" XXX A workaround for an issue where the file is not actually written to.
function! nox#autocmd#on_buf_write_cmd(filepath)
  call nox#buffer#pre()
  let l:dir = fnamemodify(a:filepath, ':h')
  call mkdir(l:dir, 'p')
  call writefile(getline(0, '$'), a:filepath)
  call nox#document#index(a:filepath)
endfunction
