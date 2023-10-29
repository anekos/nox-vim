let s:save_cpo = &cpo
set cpo&vim

if exists("b:current_syntax")
  unlet! b:current_syntax
endif

syntax match NoxTitle /^[^ ][^#]\+/ oneline
syntax match NoxHighlight /^  .\+/ oneline

highlight link NoxHighlight Comment
highlight link NoxTitle Identifier

let b:current_syntax = 'nox-search-result'

let &cpo = s:save_cpo
unlet s:save_cpo
