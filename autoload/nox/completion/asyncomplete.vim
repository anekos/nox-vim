let s:tags = v:null

function nox#completion#asyncomplete#completor(opt, ctx)
  if stridx(a:ctx['typed'], 'tag:') != 0
    return
  endif

  if s:tags == v:null
    let s:tags = nox#api#tags()
  endif

  let l:col = a:ctx['col']
  let l:typed = a:ctx['typed']

  " call system('notify-send -u low "' . l:typed .'"')

  let l:kw = matchstr(l:typed, '\v\S+$')
  let l:kwlen = len(l:kw)

  let l:startcol = l:col - l:kwlen

  let l:matches = s:tags

  call asyncomplete#complete(a:opt['name'], a:ctx, l:startcol, l:matches)
endfunction
