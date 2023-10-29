let s:save_cpo = &cpo
set cpo&vim


if exists("b:current_syntax")
  unlet! b:current_syntax
endif

syntax include @markdown syntax/markdown.vim

syntax region NoxContent  start=/./ skip=/./ end=/NOX/ contains=@markdown,NoxMeta
syntax match NoxMeta /^[-a-z]\+:.*$/ contained


highlight link NoxMeta Comment


let &cpo = s:save_cpo
unlet s:save_cpo
