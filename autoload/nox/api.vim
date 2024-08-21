function! nox#api#attach_file(id, filepath) abort
  let l:filename = fnamemodify(a:filepath, ':t')
  let l:data = readfile(a:filepath, 'b')
  return nox#web#request('PUT', '/api/document/file', {'id': a:id, 'filename': l:filename}, ['application/octet-stream', l:data])
endfunction


function! nox#api#delete_document(id) abort
  return nox#web#request('DELETE', '/api/document', {'id': a:id}, v:null)
endfunction


function! nox#api#ids(prefix) abort
  let l:params = {}
  if type(a:prefix) == v:t_string
    let l:params['prefix'] = a:prefix
  endif
  return nox#web#request('GET', '/api/ids', l:params, v:null)
endfunction


function! nox#api#get_document(id) abort
  return nox#web#request('GET', '/api/document', {'id': a:id}, v:null)
endfunction


function! nox#api#get_source(id) abort
  let l:result = nox#web#request('GET', '/api/source', {'id': a:id}, v:null)
  if l:result != v:null
    return split(l:result, "\n")
  endif
  return v:null
endfunction


function! nox#api#get_source_with_meta(id) abort
  let l:result = nox#web#request('GET', '/api/source_with_meta', {'id': a:id}, v:null)
  if type(l:result) == type(v:null)
    return v:null
  endif
  let l:result.source = split(l:result.source, "\n")
  return l:result
endfunction


function! nox#api#new_document_from_source(id, content) abort
  return nox#web#request('POST', '/api/source', {'id': a:id}, json_encode(a:content))
endfunction


function! nox#api#update_document_from_source(id, content, created_at, updated_at) abort
  let l:data = {'id': a:id, 'created_at': a:created_at, 'updated_at': a:updated_at}
  return nox#web#request('PUT', '/api/source', l:data, json_encode(a:content))
endfunction


function! nox#api#index_document(id) abort
  return nox#web#request('PUT', '/api/index', {'id': a:id, 'update': 1}, v:null)
endfunction


function! nox#api#move_document(source_id, destination_id) abort
  return nox#web#request('GET', '/api/move_document', {'source_id': a:source_id, 'destination_id': a:destination_id}, v:null)
endfunction


function! nox#api#ogp_formats() abort
  return nox#web#request('GET', '/api/ogp/formats', {}, v:null)
endfunction


function! nox#api#ogp_text(format, url) abort
  return nox#web#request('GET', '/api/ogp/text', {'url': a:url, 'format': a:format}, v:null)
endfunction


function! nox#api#search(query) abort
  return nox#web#request('GET', '/api/search', {'query': a:query}, v:null)
endfunction


function! nox#api#tags() abort
  return nox#web#request('GET', '/api/tags', {}, v:null)
endfunction


function! nox#api#pre(source, as_source) abort
  return nox#web#request('POST', '/api/document/pre', {'as_source': a:as_source}, json_encode(a:source))
endfunction
