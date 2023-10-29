" Init {{{
if exists('g:loaded_clap_nox_search_autoload') && g:loaded_clap_nox_search_autoload
  finish
endif

let g:loaded_clap_nox_search_autoload = 1
let s:save_cpo = &cpo
set cpo&vim
" }}}

" Setting {{{

if !exists('g:nox_search_use_location_list')
  let g:nox_search_use_location_list = 1
endif

"" }}}

" Interface {{{
let s:latest_source = []

function clap#provider#nox_search#source()
  return s:latest_source
endfunction
" }}}

" Main {{{
function s:on_move()
  let l:id = g:clap.display.getcurline()
  if l:id ==# ''
    return
  endif
  let l:path = nox#document#path(l:id)
  call clap#preview#file(l:path)
endfunction

function! s:sink(selected) abort
  if g:nox_search_use_location_list
    let l:selected_path = nox#document#path(a:selected)
    let l:nr = 0
    for l:loc in getloclist(winnr())
      let l:nr += 1
      if l:selected_path == bufname(l:loc.bufnr)
        execute 'll' l:nr
        return
      endif
    endfor
  endif

  execute 'NoxOpen' a:selected
endfunction

let s:nox_search = {}
let s:nox_search.id = 'Nox'
let s:nox_search.sink = function('s:sink')
let s:nox_search.source = function('clap#provider#nox_search#source')
let s:nox_search.on_move = function('s:on_move')
let s:nox_search.on_enter = { -> g:clap.display.setbufvar('&ft', 'clap_nox_search') }

let g:clap#provider#nox_search# = s:nox_search

function clap#provider#nox_search#run(query) abort
  if !exists('g:clap')
    call clap#init#()
  endif

  if trim(a:query) == '-'
    let l:source = s:latest_source
  else
    let l:res = nox#api#search(a:query)

    let l:source = []
    for l:hit in l:res['hits']
      let l:id = substitute(l:hit['id'], '#[0-9]*$', '', '')
      call add(l:source, l:id)
    endfor

    if g:nox_search_use_location_list
      let l:qf_entries = []
      for l:id in l:source
        let l:path = nox#document#path(l:id)
        let l:qf = {'filename': l:path, 'lnum': 1, 'col': 1, 'type': 'W'}
        call add(l:qf_entries, l:qf)
      endfor
      call setloclist(winnr(), l:qf_entries)
    endif

    let s:latest_source = l:source
  endif

  let l:opts = extend(s:nox_search, {'source': l:source})
  call clap#run(s:nox_search)
endfunction
" }}}

" Finalize {{{
let &cpo = s:save_cpo
unlet s:save_cpo
" }}}
