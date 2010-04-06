" vim:foldmethod=marker:fen:
scriptencoding utf-8

" Saving 'cpoptions' {{{
let s:save_cpo = &cpo
set cpo&vim
" }}}

function! s:camelize(str) "{{{
    return toupper(a:str[0]) . tolower(a:str[1:])
endfunction "}}}

function! s:get_by_regex(str, regex) "{{{
    let match = matchstr(a:str, '^' . a:regex)
    let rest  = a:str[strlen(match):]
    return [match, rest]
endfunction "}}}

function! s:get_selected_text(motion_wiseness, begin_pos, end_pos) "{{{
    if a:motion_wiseness ==# 'char'
        let [firstline, lastline] = [
        \   getline(a:begin_pos[1])[a:begin_pos[2] - 1:],
        \   getline(a:end_pos[1])[:a:end_pos[2] - 1],
        \]
    else
        let [firstline, lastline] = [
        \   getline(a:begin_pos[1]),
        \   getline(a:end_pos[1]),
        \]
    endif

    return
    \   [firstline]
    \   + getline(a:begin_pos[1] + 1, a:end_pos[1] - 1)
    \   + [lastline]
endfunction "}}}

function! s:has_idx(list, idx) "{{{
    let idx = a:idx
    return 0 <= idx && idx < len(a:list)
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

function! s:get_pos_each_word(motion_wiseness) "{{{
    let result = []
    let [begin, end] = [getpos("'["), getpos("']")]
    let whole_lines = s:get_selected_text(a:motion_wiseness, begin, end)

    for [line, lnum] in s:zip(whole_lines, range(begin[1], end[1]))
        let col  = 1

        while line != ''
            " skip non-word characters.
            let [_   , line] = s:get_by_regex(line, '\W\+')
            let col += strlen(_)
            let [word, line] = s:get_by_regex(line, '\w\+')

            if word != ''
                call add(result, [lnum, col, strlen(word)])
                let col += strlen(word)
            endif
        endwhile
    endfor
    return result
endfunction "}}}

" Perl's substr() like function.
function! s:substr(str, offset, length, ...) "{{{
    if a:0 == 0
        return a:str[a:offset : a:offset + a:length - 1]
    else
        let replacement = a:1
        let before = a:offset == 0 && a:length == 0 ? '' : a:str[: a:offset]
        let after  = a:str[: a:offset + a:length]
        VarDump before
        VarDump after
        return before . replacement . after
    endif
endfunction "}}}

function! s:do_camelize(pos) "{{{
    let processed = {}

    for [lnum, col, word_len] in a:pos
        if !has_key(processed, lnum)
            let processed[lnum] = getline(lnum)
        endif

        let args = [processed[lnum], col - 1, word_len]
        let processed[lnum] = call('s:substr', args + [s:camelize(call('s:substr', args))])
    endfor

    for [lnum, line] in items(processed)
        call setline(lnum, line)
    endfor
endfunction "}}}

function! operator#camel#do(motion_wiseness) "{{{
    call s:do_camelize(s:get_pos_each_word(a:motion_wiseness))
endfunction "}}}

" Restore 'cpoptions' {{{
let &cpo = s:save_cpo
" }}}
