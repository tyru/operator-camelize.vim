" vim:foldmethod=marker:fen:
scriptencoding utf-8

" Saving 'cpoptions' {{{
let s:save_cpo = &cpo
set cpo&vim
" }}}



function! s:map_text_with_regex(text, funcname, regex, ...) "{{{
    let give_context = a:0 ? a:1 : 0
    let converted_text = ''
    let text = a:text
    let whole_offset = 0
    while text != ''
        let offset = match(text, a:regex)
        if offset ==# -1
            break
        endif
        let context = {'offset': offset, 'whole_offset': whole_offset}
        let len = strlen(matchstr(text, a:regex))
        let whole_offset += len

        let left = offset == 0 ? '' : text[: offset - 1]
        let middle = text[offset : offset + len - 1]
        let right  = text[offset + len :]

        let converted_text .= left . call(
        \   a:funcname,
        \   [middle] + (give_context ? [context] : [])
        \)
        let text = right
    endwhile
    return converted_text . text
endfunction "}}}

" For operator.
function! s:yank_range(motion_wiseness) "{{{
    " Select previously-selected range in visual mode.
    " NOTE: `normal! gv` does not work
    " when user uses operator from normal mode.

    " From http://gist.github.com/356290
    " But specialized to operator-user.

    try
        " For saving &selection. See :help :map-operator
        let sel_save = &l:selection
        let &l:selection = "inclusive"
        " Save @@.
        let reg_save     = getreg('z', 1)
        let regtype_save = getregtype('z')

        if a:motion_wiseness == 'char'
            let ex = '`[v`]"zy'
        elseif a:motion_wiseness == 'line'
            let ex = '`[V`]"zy'
        elseif a:motion_wiseness == 'block'
            let ex = '`[' . "\<C-v>" . '`]"zy'
        else
            " silent execute 'normal! `<' . a:motion_wiseness . '`>'
            echoerr 'internal error, sorry: this block never be reached'
        endif
        execute 'silent normal!' ex
        return @z
    finally
        let &l:selection = sel_save
        call setreg('z', reg_save, regtype_save)
    endtry
endfunction "}}}
function! s:convert_wiseness(motion_wiseness) "{{{
    return get({
    \   'char': 'v',
    \   'line': 'V',
    \   'block': "\<C-v>",
    \}, a:motion_wiseness, '')
endfunction "}}}
function! s:paste_range(motion_wiseness, text) "{{{
    let reg_z_save     = getreg('z', 1)
    let regtype_z_save = getregtype('z')

    try
        call setreg('z', a:text, s:convert_wiseness(a:motion_wiseness))
        silent normal! gv"zp
    finally
        call setreg('z', reg_z_save, regtype_z_save)
    endtry
endfunction "}}}
function! s:replace_range(funcname, motion_wiseness) "{{{
    " Yank the range's text.
    let text = {a:funcname}(s:yank_range(a:motion_wiseness))
    " Paste the text to the range.
    call s:paste_range(a:motion_wiseness, text)
endfunction "}}}



" operator#camelize#camelize_word('snake_case')
" " => 'SnakeCase'
function! operator#camelize#camelize_word(word) "{{{
    " NOTE: Nested sub-replace-expression can't work...omg
    " (:help sub-replace-expression)
    "
    " return substitute(tolower(a:word), '^[a-z]\|_\zs[a-z]'.'\C', '\=toupper(submatch(0))', 'g')

    if a:word =~# '^[A-Z]\+$'
        let action = g:operator_camelize_all_uppercase_action
        if action ==# 'nop'
            return a:word
        elseif action ==# 'lowercase'
            return tolower(a:word)
        elseif action ==# 'camelize'
            return toupper(a:word[0]) . tolower(a:word[1:])
        else
            echohl WarningMsg
            echomsg "g:operator_camelize_all_uppercase_action is invalid value '"
            \       . g:operator_camelize_all_uppercase_action . "'."
            echohl None
        endif
    endif

    return s:map_text_with_regex(
    \   a:word,
    \   's:camelize',
    \   '\<[a-zA-Z0-9]\+\|_[a-zA-Z0-9]\+'.'\C'
    \)
endfunction "}}}
function! s:camelize(word) "{{{
    let word = a:word[0] == '_' ? a:word[1:] : a:word
    return toupper(word[0]) . tolower(word[1:])
endfunction "}}}

" operator#camelize#camelize_text('snake_case other_text')
" " => 'SnakeCase OtherText'
function! operator#camelize#camelize_text(text) "{{{
    return s:map_text_with_regex(a:text, 'operator#camelize#camelize_word', '\w\+')
endfunction "}}}

function! operator#camelize#op_camelize(motion_wiseness) "{{{
    call s:replace_range('operator#camelize#camelize_text', a:motion_wiseness)
endfunction "}}}



" operator#camelize#decamelize_word('CamelCase')
" " => 'camel_case'
function! operator#camelize#decamelize_word(word) "{{{
    " NOTE: Nested sub-replace-expression can't work...omg
    " (:help sub-replace-expression)
    "
    " return substitute(a:word, '^[A-Z]\|[a-z]\zs[A-Z]'.'\C', '\='_' . tolower(submatch(0))', 'g')

    if a:word =~# '^[A-Z]\+$'
        let action = g:operator_decamelize_all_uppercase_action
        if action ==# 'nop'
            return a:word
        elseif action ==# 'lowercase'
            return tolower(a:word)
        elseif action ==# 'decamelize'
            " Fall through
        else
            echohl WarningMsg
            echomsg "g:operator_decamelize_all_uppercase_action is invalid value '"
            \       . g:operator_decamelize_all_uppercase_action . "'."
            echohl None
        endif
    endif

    return s:map_text_with_regex(
    \   a:word,
    \   's:decamelize',
    \   '[A-Z][a-z0-9]*'.'\C',
    \   1
    \)
endfunction "}}}
function! s:decamelize(word, context) "{{{
    return
    \   (a:context.whole_offset == 0 ? '' : '_')
    \   . tolower(a:word)
endfunction "}}}

" operator#camelize#decamelize_text('CamelCase OtherText')
" " => 'camel_case other_text'
function! operator#camelize#decamelize_text(text) "{{{
    return s:map_text_with_regex(a:text, 'operator#camelize#decamelize_word', '\w\+')
endfunction "}}}

function! operator#camelize#op_decamelize(motion_wiseness) "{{{
    call s:replace_range('operator#camelize#decamelize_text', a:motion_wiseness)
endfunction "}}}



" Restore 'cpoptions' {{{
let &cpo = s:save_cpo
" }}}
