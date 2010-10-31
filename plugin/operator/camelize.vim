" vim:foldmethod=marker:fen:
scriptencoding utf-8

" Load Once {{{
if exists('g:loaded_operator_camelize') && g:loaded_operator_camelize
    finish
endif
let g:loaded_operator_camelize = 1
" }}}
" Saving 'cpoptions' {{{
let s:save_cpo = &cpo
set cpo&vim
" }}}

if !exists('g:operator_decamelize_all_uppercase_action')
    let g:operator_decamelize_all_uppercase_action = 'nop'
endif
if !exists('g:operator_camelize_all_uppercase_action')
    let g:operator_camelize_all_uppercase_action = 'nop'
endif

call operator#user#define('camelize', 'operator#camelize#op_camelize')
call operator#user#define('decamelize', 'operator#camelize#op_decamelize')


" Restore 'cpoptions' {{{
let &cpo = s:save_cpo
" }}}
