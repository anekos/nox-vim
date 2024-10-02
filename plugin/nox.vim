command! -nargs=0 NoxDelete call nox#document#delete()

command! -nargs=?
  \ NoxBrowse
  \ call nox#browser#open(<q-args>)

command! -nargs=*
  \ -complete=customlist,nox#document#complete_diary
  \ NoxDiary
  \ call nox#document#diary(<q-args>)

command! -nargs=0
  \ NoxDraft
  \ call nox#document#draft()

command! -nargs=1
  \ -complete=customlist,nox#completion#ids
  \ NoxOpen
  \ call nox#document#open(nox#id#cleanup(<q-args>), v:true, '')

command! -nargs=1
  \ -complete=customlist,nox#completion#ids
  \ NoxRename
  \ call nox#document#move(<q-args>)

command! -nargs=?
  \ -complete=customlist,nox#completion#tags
  \ NoxTag
  \ call nox#buffer#add_tag(<q-args>)


au User asyncomplete_setup call asyncomplete#register_source({
      \ 'name': 'nox',
      \ 'allowlist': ['nox'],
      \ 'completor': function('nox#completion#asyncomplete#completor'),
      \ })
