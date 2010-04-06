" vim:foldmethod=marker:fen:
scriptencoding utf-8

" Saving 'cpoptions' {{{
let s:save_cpo = &cpo
set cpo&vim
" }}}


" snake_case -> SnakeCase
function! s:camelize(str) "{{{
    " NOTE: Nested sub-replace-expression is not recognized...omg
    " (:help sub-replace-expression)
    "
    " return substitute(tolower(a:str), '^[a-z]\|_\zs[a-z]'.'\C', '\=toupper(submatch(0))', 'g')

    let str = a:str
    let regex = '^[a-z]\|_[a-z]'.'\C'

    while 1
        let offset = match(str, regex)
        let len    = strlen(matchstr(str, regex))
        if offset ==# -1
            break
        endif
        let left = offset == 0 ? '' : str[: offset - 1]
        let middle = str[offset : offset + len - 1]
        let right  = str[offset + len :]
        let str = left . toupper(middle[0] == '_' ? middle[1:] : middle) . right
    endwhile
    return str
endfunction "}}}

function! operator#camelize#camelize(motion_wiseness) "{{{
    '[,']substitute/\w\+/\=s:camelize(submatch(0))/g
endfunction "}}}


" CamelCase -> camel_case
function! s:uncamelize(str) "{{{
    " NOTE: Nested sub-replace-expression is not recognized...omg
    " (:help sub-replace-expression)
    "
    " return substitute(a:str, '^[A-Z]\|[a-z]\zs[A-Z]'.'\C', '\='_' . tolower(submatch(0))', 'g')

    let str = a:str
    let action = g:operator_uncamelize_all_uppercase_action
    let regex = '^[A-Z]\|[a-z]\zs[A-Z]'.'\C'

    if str =~# '^[A-Z]\+$' && action ==# 'nop'
        return str
    elseif str =~# '^[A-Z]\+$' && action ==# 'lowercase'
        return tolower(str)
    endif

    while 1
        let offset = match(str, regex)
        let len    = strlen(matchstr(str, regex))
        if offset ==# -1
            break
        endif
        let left = offset == 0 ? '' : str[: offset - 1]
        let middle = str[offset : offset + len - 1]
        let right  = str[offset + len :]
        let str = left . (offset ==# 0 ? '' : '_') . tolower(middle) . right
    endwhile
    return str
endfunction "}}}

function! operator#camelize#uncamelize(motion_wiseness) "{{{
    '[,']substitute/\w\+/\=s:uncamelize(submatch(0))/g
endfunction "}}}


" Restore 'cpoptions' {{{
let &cpo = s:save_cpo
" }}}
