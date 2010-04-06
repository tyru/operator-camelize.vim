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


call operator#user#define('camel', 'operator#camel#do')


" Restore 'cpoptions' {{{
let &cpo = s:save_cpo
" }}}
