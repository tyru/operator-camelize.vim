" vim:foldmethod=marker:fen:
scriptencoding utf-8

" Saving 'cpoptions' {{{
let s:save_cpo = &cpo
set cpo&vim
" }}}


function! s:select(motion_wiseness) "{{{
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
            let ex = '`[v`]'
        elseif a:motion_wiseness == 'line'
            let ex = '`[V`]'
        elseif a:motion_wiseness == 'block'
            let ex = "`[\<C-v>`]"
        else
            " silent execute 'normal! `<' . a:motion_wiseness . '`>'
            echoerr 'internal error, sorry: this block never be reached'
        endif
    finally
        let &l:selection = sel_save
        call setreg('z', reg_save, regtype_save)
    endtry

    execute 'silent normal!' ex
endfunction "}}}
function! s:operate_on_word(funcname, motion_wiseness) "{{{
    " Select previously-selected range in visual mode.
    call s:select(a:motion_wiseness)

    let reg_z_save     = getreg('z', 1)
    let regtype_z_save = getregtype('z')

    try
        " Filter selected range with `{a:funcname}(selected_text)`.
        let cut_with_reg_z = '"zc'
        execute printf("normal! %s\<C-r>=%s(@z)\<CR>", cut_with_reg_z, a:funcname)
    finally
        call setreg('z', reg_z_save, regtype_z_save)
    endtry
endfunction "}}}


" s:camelize_word('snake_case') " => 'SnakeCase'
function! s:camelize_word(word) "{{{
    " NOTE: Nested sub-replace-expression can't work...omg
    " (:help sub-replace-expression)
    "
    " return substitute(tolower(a:word), '^[a-z]\|_\zs[a-z]'.'\C', '\=toupper(submatch(0))', 'g')

    let word = a:word
    let action = g:operator_camelize_all_uppercase_action
    let regex = '^[a-z]\|_[a-z]'.'\C'

    if word =~# '^[A-Z]\+$'
        if action ==# 'nop'
            return word
        elseif action ==# 'lowercase'
            return tolower(word)
        elseif action ==# 'camelize'
            return toupper(word[0]) . tolower(word[1:])
        else
            echohl WarningMsg
            echomsg "g:operator_camelize_all_uppercase_action is invalid value '"
            \       . g:operator_camelize_all_uppercase_action . "'."
            echohl None
        endif
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
        let word = left . toupper(middle[0] == '_' ? middle[1:] : middle) . right
    endwhile
    return word
endfunction "}}}

function! operator#camelize#camelize(motion_wiseness) "{{{
    call s:operate_on_word('s:camelize_word', a:motion_wiseness)
endfunction "}}}


" s:decamelize_word('CamelCase') " => 'camel_case'
function! s:decamelize_word(word) "{{{
    " NOTE: Nested sub-replace-expression can't work...omg
    " (:help sub-replace-expression)
    "
    " return substitute(a:word, '^[A-Z]\|[a-z]\zs[A-Z]'.'\C', '\='_' . tolower(submatch(0))', 'g')

    let word = a:word
    let action = g:operator_decamelize_all_uppercase_action
    let regex = '^[A-Z]\|[a-z]\zs[A-Z]'.'\C'

    if word =~# '^[A-Z]\+$'
        if action ==# 'nop'
            return word
        elseif action ==# 'lowercase'
            return tolower(word)
        elseif action ==# 'decamelize'
            " Fall through
        else
            echohl WarningMsg
            echomsg "g:operator_decamelize_all_uppercase_action is invalid value '"
            \       . g:operator_decamelize_all_uppercase_action . "'."
            echohl None
        endif
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
    call s:operate_on_word('<SID>decamelize_word', a:motion_wiseness)
endfunction "}}}


" Restore 'cpoptions' {{{
let &cpo = s:save_cpo
" }}}
