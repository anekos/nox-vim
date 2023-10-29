let s:O = vital#nox#import('OptionParser')

" Diary Parser {{{

let s:diary_parser = s:O.new()
call s:diary_parser.on(
      \ '--id=VALUE',
      \ 'The prefix of document ID',
      \ { 'short': '-i', 'completion': function('nox#completion#open') }
      \ )

function! nox#document#complete_diary(arglead, cmdline, cursorpos)
  return s:diary_parser.complete(a:arglead, a:cmdline, a:cursorpos)
endfunction

" }}}


function! s:goto_nth_header(nth)
  let l:h1s = 0
  for l:ln in range(1, line('$'))
    let l:line = getline(l:ln)
    if 0 <= match(l:line, '^#[^#]\+')
      let l:h1s += 1
    endif
    if l:h1s == a:nth
      execute l:ln
      return
    endif
  endfor
endfunction


function! nox#document#attach_file(filepath) abort
  let l:id = nox#buffer#document_id()
  call nox#api#attach_file(l:id, a:filepath)
endfunction

function! nox#document#delete() abort
  let l:res = input('Delete this document? [yes/N] ')
  if l:res != 'yes'
    return
  endif

  let l:id = nox#buffer#document_id()
  call nox#api#delete_document(l:id)
  bdelete
  echomsg 'Deleted: ' . l:id
endfunction


function! nox#document#diary(title) abort
  let l:options = s:diary_parser.parse(a:title)

  if 0 < len(l:options['__unknown_args__'])
    let l:title = join(l:options['__unknown_args__'], ' ')
  else
    let l:title = input('Title: ')
  endif

  if has_key(l:options, 'id')
    let l:prefix = l:options['id'] .  strftime('%Y/%m/%d') . '-'
  else
    let l:prefix = 'diary/' .  strftime('%Y/%m/%d') . '-'
  endif

  let l:ids = nox#api#ids(l:prefix)

  if 0 < len(l:ids)
    call nox#document#open(l:ids[0], v:false, '')
    if l:title != ''
      call append('$', ['', '', '# ' . l:title, '', ''])
    endif
  else
    while l:title == ''
      let l:title = input('Title: ')
    endwhile
    let l:id = l:prefix . l:title
    call nox#document#open(l:id, v:true, '')
  endif

  execute 'normal G'
endfunction


function! nox#document#draft() abort
  let l:n = 1
  let l:ids = nox#api#ids('draft/')

  while v:true
    let l:id = 'draft/' . l:n
    if index(l:ids, l:id) == -1
      break
    endif
    let l:n += 1
  endwhile

  call nox#document#open(l:id, v:true, '')
endfunction


function nox#document#index(file) abort
  let l:file = fnamemodify(a:file, ':p')
  for l:root in nox#config#roots()
    let l:idx = stridx(l:file, l:root . '/')
    if l:idx == 0
      let l:id = l:file[len(l:root) + 1:-5]
      call nox#api#index_document(l:id)
      redraw
      echomsg 'Indexed'
      return
    endif
  endfor
endfunction


function! nox#document#move(destination_id) abort
  let l:destination_id = a:destination_id

  " If the first character is '/', it is NOT an ID
  if l:destination_id[0] ==# '/' || fnamemodify(l:destination_id, ':e') ==# 'nox'
    echoerr 'Invalid ID: ' . l:destination_id
    return
  endif

  let l:source_id = nox#buffer#document_id()
  call nox#api#move_document(l:source_id, l:destination_id)
  bdelete
  call nox#document#open(l:destination_id, v:false, '')
  echomsg 'Moved to: ' . l:destination_id
endfunction


function! nox#document#path(id) abort
  for l:root in nox#config#roots()
    let l:fp = l:root . '/' . a:id . '.nox'
    " To refresh
    let l:dir = fnamemodify(l:fp, ':h')
    silent call readdir(l:dir)
    if isdirectory(l:dir) && filereadable(l:fp)
      return l:fp
    endif
  endfor

  return v:null
endfunction

function! nox#document#open(id, create, target) abort
  let l:id = substitute(a:id, '#[0-9]*$', '', '')
  let l:nth = matchstr(a:id, '#[0-9]*$')
  if l:nth != ''
    let l:nth = str2nr(l:nth[1:])
  else
    let l:nth = -1
  endif

  let l:path = nox#document#path(l:id)
  if l:path == v:null
    if a:create
      if a:target == 'tab'
        tabnew
      endif
      execute 'edit' (g:nox_roots[0] . '/' . a:id . '.nox')
    else
      echoerr 'Not found: ' . l:id
    endif
    return
  endif

  if a:target == 'tab'
    tabnew
  endif
  execute 'edit' l:path
  if 0 <= l:nth
    call s:goto_nth_header(l:nth)
  endif
endfunction
