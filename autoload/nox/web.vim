let s:Http = vital#nox#import('Web.HTTP')


" If you want to post a binary, give
"   ['application/octet-stream', l:content_data]
function! nox#web#request(method, path, param, data) abort
  if exists('g:nox_password')
    let l:headers = {'x-password': g:nox_password}
  else
    let l:headers = {}
  endif
  " Workaround for neovim and bug?
  if has('nvim')
    let l:client = 'curl'
  else
    let l:client = 'python3'
  endif
  let l:content_type = 'application/json'
  if type(a:data) == v:t_list
    let [l:content_type, l:data] = a:data
  else
    let l:data = a:data
  endif
  let l:res = s:Http.request(
        \ a:method,
        \ g:nox_endpoint . a:path,
        \ {
          \ 'param': a:param,
          \ 'contentType': l:content_type,
          \ 'data': l:data,
          \ 'client': l:client,
          \ 'headers': l:headers
        \ }
      \ )
  if type(l:res) == v:t_number
    echoerr 'Failed to HTTP request'
  endif
  if !l:res.success
    echoerr 'Error: ' . l:res.statusText
  endif
  return json_decode(l:res.content)
endfunction
