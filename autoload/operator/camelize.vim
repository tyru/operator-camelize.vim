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
function! s:operate_on_word(funcname, motion_wiseness) "{{{
    let [begin, end] = [getpos("'["), getpos("']")]
    let lines = s:get_selected_text(a:motion_wiseness, begin, end)
    let [firstline_noreplace, lastline_noreplace] = [
    \   (begin[2] == 1 ? '' : getline(begin[1])[: begin[2] - 2]),
    \   (end[2] == strlen(getline(end[1])) + 1 ? '' : getline(end[1])[end[2] :])
    \]

    if len(lines) == 1
        let [first_line, last_line] = [lines[0], '']
        let middle_lines = []
    elseif len(lines) == 2
        let [first_line, last_line] = [lines[0], lines[-1]]
        let middle_lines = []
    else
        let [first_line, last_line] = [lines[0], lines[-1]]
        let middle_lines = lines[1:-2]
    endif

    let pat = '\w\+'
    let sub = '\=' . a:funcname . '(submatch(0))'
    let flags = 'g'
    " First line
    if first_line != ''
        let line = substitute(first_line, pat, sub, flags)
        call setline(begin[1], firstline_noreplace . line)
    endif
    " Middle lines
    for [line, lnum] in s:zip(middle_lines, (begin[1] + 1 <= end[1] - 1 ? range(begin[1] + 1, end[1] - 1) : []))
        let line = substitute(line, pat, sub, flags)
        call setline(lnum, line)
    endfor
    " Last line
    if last_line != ''
        let line = substitute(last_line, pat, sub, flags)
        call setline(end[1], line . lastline_noreplace)
    endif
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
    call s:operate_on_word('s:camelize_word', a:motion_wiseness)
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
    call s:operate_on_word('s:decamelize_word', a:motion_wiseness)
endfunction "}}}


" Restore 'cpoptions' {{{
let &cpo = s:save_cpo
" }}}
