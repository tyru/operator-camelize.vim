" vim:foldmethod=marker:fen:
scriptencoding utf-8

" Saving 'cpoptions' {{{
let s:save_cpo = &cpo
set cpo&vim
" }}}


function! s:get_selected_text(motion_wiseness, begin_pos, end_pos) "{{{
    if a:motion_wiseness ==# 'char'
        let firstline = [getline(a:begin_pos[1])[a:begin_pos[2] - 1:]]
        if a:begin_pos[1] == a:end_pos[1]
            let lastline = []
        else
            let lastline = [getline(a:end_pos[1])[:a:end_pos[2] - 1]]
        endif
    else
        let firstline = [getline(a:begin_pos[1])]
        if a:begin_pos[1] == a:end_pos[1]
            let lastline = []
        else
            let lastline  = [getline(a:end_pos[1])]
        endif
    endif

    return
    \   firstline
    \   + getline(a:begin_pos[1] + 1, a:end_pos[1] - 1)
    \   + lastline
endfunction "}}}
function! s:zip(list, list2) "{{{
    let ret = []
    let i = 0
    while s:has_idx(a:list, i) || s:has_idx(a:list2, i)
        call add(ret,
        \   (s:has_idx(a:list, i) ? [a:list[i]] : [])
        \   + (s:has_idx(a:list2, i) ? [a:list2[i]] : []))

        let i += 1
    endwhile
    return ret
endfunction "}}}
function! s:has_idx(list, idx) "{{{
    let idx = a:idx
    " Support negative index?
    " let idx = a:idx >= 0 ? a:idx : len(a:list) + a:idx
    return 0 <= idx && idx < len(a:list)
endfunction "}}}


" snake_case -> SnakeCase
function! s:camelize_word(word) "{{{
    " NOTE: Nested sub-replace-expression is not recognized...omg
    " (:help sub-replace-expression)
    "
    " return substitute(tolower(a:word), '^[a-z]\|_\zs[a-z]'.'\C', '\=toupper(submatch(0))', 'g')

    let word = a:word
    let regex = '^[a-z]\|_[a-z]'.'\C'

    while 1
        let offset = match(word, regex)
        let len    = strlen(matchstr(word, regex))
        if offset ==# -1
            break
        endif
        let left = offset == 0 ? '' : word[: offset - 1]
        let middle = word[offset : offset + len - 1]
        let right  = word[offset + len :]
        let word = left . toupper(middle[0] == '_' ? middle[1:] : middle) . right
    endwhile
    return word
endfunction "}}}

function! operator#camelize#camelize(motion_wiseness) "{{{
    '[,']substitute/\w\+/\=s:camelize(submatch(0))/g
endfunction "}}}


" CamelCase -> camel_case
function! s:decamelize_word(word) "{{{
    " NOTE: Nested sub-replace-expression is not recognized...omg
    " (:help sub-replace-expression)
    "
    " return substitute(a:word, '^[A-Z]\|[a-z]\zs[A-Z]'.'\C', '\='_' . tolower(submatch(0))', 'g')

    let word = a:word
    let action = g:operator_decamelize_all_uppercase_action
    let regex = '^[A-Z]\|[a-z]\zs[A-Z]'.'\C'

    if word =~# '^[A-Z]\+$' && action ==# 'nop'
        return word
    elseif word =~# '^[A-Z]\+$' && action ==# 'lowercase'
        return tolower(word)
    endif

    while 1
        let offset = match(word, regex)
        let len    = strlen(matchstr(word, regex))
        if offset ==# -1
            break
        endif
        let left = offset == 0 ? '' : word[: offset - 1]
        let middle = word[offset : offset + len - 1]
        let right  = word[offset + len :]
        let word = left . (offset ==# 0 ? '' : '_') . tolower(middle) . right
    endwhile
    return word
endfunction "}}}

function! operator#camelize#decamelize(motion_wiseness) "{{{
    '[,']substitute/\w\+/\=s:decamelize_word(submatch(0))/g
endfunction "}}}


" Restore 'cpoptions' {{{
let &cpo = s:save_cpo
" }}}
