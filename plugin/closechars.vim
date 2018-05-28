" closechars: automatically close paired characters in insert mode
" Author: Ivan Greene <https://ivan.sh/>
" License: MIT
" Version: v0.1.1
" Last Modified: 2018 May 28

let g:closechars_semicolon_endchars = get(g:, 'closechars_semicolon_endchars', ["'", '"', ']', '}', '>', ')'])
let g:closechars_comma_endchars = get(g:, 'closechars_comma_endchars', ["'", '"'])
let g:closechars_comma_afterchars = get(g:, 'closechars_comma_afterchars', [']', ')'])
let g:closechars_lefts = get(g:, 'closechars_lefts', ["'", '"', '[', '{', '<', '('])
let g:closechars_rights = get(g:, 'closechars_rights', ["'", '"', ']', '}', '>', ')'])
let g:closechars_pair_delete = get(g:, 'closechars_pair_delete', 1)

function! closechars#Map()
  let c = 0
  while c < len(g:closechars_lefts)
    let l = g:closechars_lefts[c]
    let r = g:closechars_rights[c]
    exec 'inoremap ' . l . '<CR> ' . l . '<CR>' . r . '<Esc>O'
    exec 'inoremap ' . l . l . ' ' . l
    if l == r
      exec 'inoremap <expr> ' . r . " strpart(getline('.'), col('.')-1, 1) == " . closechars#SafeQuote(r)
            \ . ' ? "\<Right>" : ' . closechars#SafeQuote(l . r) . ' . "\<Left>"'
    else
      exec 'inoremap ' . l . r . ' ' . l . r
      exec 'inoremap <expr> ' . r . " strpart(getline('.'), col('.')-1, 1) == " . closechars#SafeQuote(r)
            \ . ' ? "\<Right>" : ' . closechars#SafeQuote(r)
      exec 'inoremap ' . l . ' ' . l . r . '<Left>'
    endif
    let c += 1
  endwhile

  if len(g:closechars_semicolon_endchars)
    inoremap <expr> ; index(g:closechars_semicolon_endchars,
          \ strpart(getline('.'), col('.')-1, 1)) == -1 ? ";" : "\<Right>;"
    inoremap ;; ;
  endif

  if len(g:closechars_comma_endchars)
    inoremap <expr> , closechars#SmartComma()
    inoremap ,, ,
  endif

  if g:closechars_pair_delete
    inoremap <expr> <BS> closechars#PairDelete() ? "\<Right>\<BS>\<BS>" : "\<BS>"
  endif
endfunction

function! closechars#SafeQuote(char)
  if a:char == '"' || a:char == '""'
    return "'" . a:char . "'"
  else
    return '"' . a:char . '"'
  endif
endfunction

function! closechars#SmartComma()
  let l:ch = strpart(getline('.'), col('.')-1, 1)
  let l:after = strpart(getline('.'), col('.'), 1)
  let l:ok = index(g:closechars_comma_endchars, l:ch) != -1
  if l:ok && index(g:closechars_comma_afterchars, l:after) != -1
        \ || !len(g:closechars_comma_afterchars)
    return "\<Right>, " . l:ch . l:ch . "\<Left>"
  elseif l:ok
    return "\<Right>,"
  else
    return ","
  endif
endfunction

function! closechars#PairDelete()
  let l:before = strpart(getline('.'), col('.')-2, 1)
  let l:after = strpart(getline('.'), col('.')-1, 1)
  return closechars#PairMatch(l:before, l:after)
endfunction

function! closechars#PairMatch(l, r)
  let l:l = index(g:closechars_lefts, a:l)
  let l:r = index(g:closechars_rights, a:r)
  return l:l != -1 && l:l == l:r
endfunction

function! closechars#UnMap()
  let c = 0
  while c < len(g:closechars_lefts)
    let l = g:closechars_lefts[c]
    let r = g:closechars_rights[c]
    exec 'iunmap ' . l . '<CR>'
    exec 'iunmap ' . l . l
    exec 'iunmap ' . l
    if l != r
      exec 'iunmap ' . l . r
      exec 'iunmap ' . r
    endif
    let c += 1
  endwhile
  if len(g:closechars_semicolon_endchars)
    iunmap ;
    iunmap ;;
  endif

  if len(g:closechars_comma_endchars)
    iunmap ,
    iunmap ,,
  endif

  if g:closechars_pair_delete
    iunmap <BS>
  endif
endfunction

call closechars#Map()
