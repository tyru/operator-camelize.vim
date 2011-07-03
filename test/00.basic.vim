" vim:foldmethod=marker:fen:
scriptencoding utf-8

" Saving 'cpoptions' {{{
let s:save_cpo = &cpo
set cpo&vim
" }}}


function! s:get_sid_of(script_pattern) "{{{
    redir => output
    silent scriptnames
    redir END

    for _ in split(output, '\n')
        let m = matchlist(_, '^\s*\(\d\+\):\s\+\(.\+\)$')
        if !empty(m)
            let [sid, script] = m[1:2]
            if script =~# a:script_pattern
                return sid + 0
            endif
        endif
    endfor

    return -1
endfunction "}}}

function! s:call_local(sid, name, args) "{{{
    let name = '<SNR>' . a:sid . '_' . a:name
    return call(name, a:args)
endfunction "}}}

function! s:run() "{{{
    call operator#camelize#load()
    let sid = s:get_sid_of('autoload/operator/camelize\.vim')
    if sid <= 0
        Skip "can't get SID of autoload/operator/camelize.vim"
    endif


    " Camelize
    let r = s:call_local(sid, 'camelize_text', ['snake_case other_text'])
    Is
    \   r,
    \   'SnakeCase OtherText',
    \   'snake_case other_text => SnakeCase OtherText'

    let r = s:call_local(sid, 'camelize_word', [{'match': 'snake_case'}])
    Is
    \   r,
    \   'SnakeCase',
    \   'snake_case => SnakeCase'

    let r = s:call_local(sid, 'camelize_atom', [{'match': 'snake'}])
    Is
    \   r,
    \   'Snake',
    \   'snake => Snake'


    " Decamelize (PascalCase)
    let r = s:call_local(sid, 'decamelize_text', ['CamelCase OtherText'])
    Is
    \   r,
    \   'camel_case other_text',
    \   'CamelCase OtherText => camel_case other_text'

    let r = s:call_local(sid, 'decamelize_word', [{'match': 'CamelCase'}])
    Is
    \   r,
    \   'camel_case',
    \   'CamelCase => camel_case'

    let r = s:call_local(sid, 'decamelize_atom', [{'match': 'Snake', 'converted': ''}])
    Is
    \   r,
    \   'snake',
    \   'Snake(...) => snake(...)'

    let r = s:call_local(sid, 'decamelize_atom', [{'match': 'Snake', 'converted': 'hoge'}])
    Is
    \   r,
    \   '_snake',
    \   '(Hoge)Snake => (hoge)_snake'


    " Decamelize (CamelCase)
    let r = s:call_local(sid, 'decamelize_text', ['camelCase otherText'])
    Is
    \   r,
    \   'camel_case other_text',
    \   'camelCase otherText => camel_case other_text'

    let r = s:call_local(sid, 'decamelize_word', [{'match': 'camelCase'}])
    Is
    \   r,
    \   'camel_case',
    \   'camelCase => camel_case'

    let r = s:call_local(sid, 'decamelize_atom', [{'match': 'snake', 'converted': ''}])
    Is
    \   r,
    \   'snake',
    \   'snake(...) => snake(...)'

    let r = s:call_local(sid, 'decamelize_atom', [{'match': 'Snake', 'converted': 'hoge'}])
    Is
    \   r,
    \   '_snake',
    \   '(hoge)Snake => (hoge)_snake'


    for t in ['CamelCase', 'camelCase']
        let r = s:call_local(sid, 'is_camelized', [t])
        OK r, 's:is_camelized('.string(t).') => true'
    endfor
    for t in ['snake_case', 'camelCase_', 'CamelCase_', 'vim']
        let r = s:call_local(sid, 'is_camelized', [t])
        OK !r, 's:is_camelized('.string(t).') => false'
    endfor
endfunction "}}}

call s:run()
Done


" Restore 'cpoptions' {{{
let &cpo = s:save_cpo
" }}}
