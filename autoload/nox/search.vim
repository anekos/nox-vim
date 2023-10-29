" Init {{{
if exists('g:loaded_nox_search_autoload') && g:loaded_nox_search_autoload
  finish
endif

let g:loaded_nox_search_autoload = 1
let s:save_cpo = &cpo
set cpo&vim
" }}}

let s:Http = vital#nox#import('Web.HTTP')

function! nox#search#execute(query) abort
  let l:window_nr = winnr()

  silent belowright new
  setlocal buftype=nofile bufhidden=unload noswapfile nobuflisted filetype=nox-search-result

  if a:query == ''
    let l:query = '!recent'
  else
    let l:query = a:query
  endif

  let l:res = nox#api#search(l:query)

  let l:qf_entries = []

  for l:hit in l:res['hits']
    let l:id_link = l:hit['id']
    let l:id = substitute(l:hit['id'], '#[0-9]*$', '', '')
    if match(l:id_link, '#[0-9]\+$') < 0
      let l:id_link .= '#'
    endif

    call appendbufline('%', '$', l:id_link . ' - ' . l:hit['source']['title'])

    let l:filename = g:nox_union_root . '/' . l:id . '.nox'
    let l:qf = {'filename': l:filename, 'lnum': 0, 'col': 0, 'type': 'W'}
    call add(l:qf_entries, l:qf)

    " Hightlights
    if has_key(l:hit, 'highlights') && type(l:hit['highlights']) == v:t_dict
      let l:all_hls = []
      for [l:key, l:hls] in items(l:hit['highlights'])
        for l:hl in l:hls
          let l:hl = substitute(l:hl, '\s\+', ' ', 'g')
          call add(l:all_hls, trim(l:hl))
        endfor
      endfor
      for l:hl in uniq(sort(l:all_hls))
        call appendbufline('%', '$', '  ' . substitute(l:hl, '</\?em>', ' ', 'g'))
      endfor
    endif
  endfor

  call setloclist(l:window_nr, l:qf_entries)
  call deletebufline('%', '1')
endfunction

function! nox#search#open_search_result(target)
  for l:ln in range(line('.'), line('.') - 10, -1)
    let l:line = getline(l:ln)
    if l:line[0] != ' '
      let l:id = matchstr(l:line, '^[^#]\+#[0-9]*')
      if a:target != 'tab'
        bdelete
      endif
      call nox#document#open(l:id, v:false, a:target)
      return
    endif
  endfor
endfunction

" Finalize {{{
let &cpo = s:save_cpo
unlet s:save_cpo
" }}}
