" vim:foldmethod=marker:fen:
scriptencoding utf-8

" Load Once {{{
if exists('g:loaded_camel') && g:loaded_camel
    finish
endif
let g:loaded_camel = 1
" }}}
" Saving 'cpoptions' {{{
let s:save_cpo = &cpo
set cpo&vim
" }}}

" nop       : Do nothing
" lowercase : Do lower-case
" decamelize: Do decamelize
if !exists('g:operator_decamelize_all_uppercase_action')
    let g:operator_decamelize_all_uppercase_action = 'nop'
endif

call operator#user#define('camelize', 'operator#camelize#camelize')
call operator#user#define('decamelize', 'operator#camelize#decamelize')


" Restore 'cpoptions' {{{
let &cpo = s:save_cpo
" }}}
