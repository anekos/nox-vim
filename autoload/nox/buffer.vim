let s:Buffer = vital#nox#import('Vim.Buffer')
let s:Http = vital#nox#import('Web.HTTP')


function! nox#buffer#add_tag(tag) abort
  let l:to = -1

  let l:tag = join(split(a:tag, '/'), ' -> ')

  for l:ln in range(1, line('$'))
    let l:line = getline(l:ln)
    if match(l:line, '\v(title|tag):') == 0
      let l:to = l:ln
    endif
  endfor

  call append(l:to, 'tag: ' . l:tag)
endfunction


function! nox#buffer#document_id() abort
   return nox#id#from_url(expand('%'))
endfunction


function nox#buffer#get_attribute(name)
  let l:lines = nox#buffer#headers()[2]

  for l:line in l:lines
    let l:at = stridx(l:line, ':')
    let l:name = strpart(l:line, 0, l:at)
    if l:name == a:name
      return strpart(l:line, l:at + 2)
    endif
  endfor

  return v:null
endfunction


function! nox#buffer#headers() abort
  " Returns [start lnum, end lnum, header lines]

  let l:position = 'before_header'
  let l:lnum = -1
  let l:append_to = -1
  let l:source = getline(1, '$')
  let l:result = []
  let l:start_at = 0
  let l:end_at = len(l:source) - 1

  for line in l:source
    let l:lnum += 1

    if l:position == 'before_header'
      if line != ''
        let l:position = 'header'
        let l:start_at = l:lnum
      endif
    endif

    if l:position == 'header'
      if l:line == ''
        let l:end_at = l:lnum - 1
        break
      endif

      call add(l:result, l:line)
    endif
  endfor

  return [l:start_at, l:end_at, l:result]
endfunction


function! nox#buffer#is_nox() abort
  return 'nox://' == expand('%')[0:5]
endfunction


function! nox#buffer#tags() abort
  let [l:start, l:end, l:lines] = nox#buffer#headers()
  let l:result = []

  for l:line in l:lines
    let l:pt = stridx(l:line, ':')
    if l:pt != -1
      let l:key = strpart(l:line, 0, l:pt)
      let l:val = trim(strpart(l:line, l:pt + 1))
      let l:val = substitute(l:val, ' -> ', '/', 'g')
      if l:key == 'tag'
        call add(l:result, l:val)
      endif
    endif
  endfor

  return l:result
endfunction
