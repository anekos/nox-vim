let s:save_cpo = &cpo
set cpo&vim


if exists("b:current_syntax")
  unlet! b:current_syntax
endif

syntax include @markdown syntax/markdown.vim

syntax region NoxHeader start=/\%^/ end=/^\s*$/me=s-1 contains=NoxMeta
syntax region NoxContent start=/^\s*$/ skip=/./ end=/NOX/ contains=@markdown
syntax match NoxMeta /^[-a-z]\+:.*$/ contained containedin=NoxHeader


highlight link NoxMeta Comment


let &cpo = s:save_cpo
unlet s:save_cpo
