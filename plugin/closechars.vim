" closechars: automatically close paired characters in insert mode

let g:closechars_semicolon_endchars = get(g:, 'closechars_semicolon_endchars', ["'", '"', ']', '}', '>', ')'])
let g:closechars_comma_endchars = get(g:, 'closechars_comma_endchars', ["'", '"'])
let g:closechars_lefts = get(g:, 'closechars_lefts', ["'", '"', '[', '{', '<', '('])
let g:closechars_rights = get(g:, 'closechars_rights', ["'", '"', ']', '}', '>', ')'])
let g:closechars_pair_delete = get(g:, 'closechars_pair_delete', 1)

function! closechars#AutoMap()
  let c = 0
  while c < len(g:closechars_lefts)
    exec 'inoremap ' . g:closechars_lefts[c] . '<CR> ' . g:closechars_lefts[c] . '<CR>' . g:closechars_rights[c] . '<Esc>O'
    exec 'inoremap ' . g:closechars_lefts[c] . g:closechars_lefts[c] . ' ' . g:closechars_lefts[c]
    if g:closechars_lefts[c] == g:closechars_rights[c]
      exec 'inoremap <expr> ' . g:closechars_rights[c] . " strpart(getline('.'), col('.')-1, 1) == " . closechars#SafeQuote(g:closechars_rights[c])
            \ . ' ? "\<Right>" : "' . g:closechars_lefts[c] . g:closechars_rights[c] . '\<Left>"'
    else
      exec 'inoremap <expr> ' . g:closechars_rights[c] . " strpart(getline('.'), col('.')-1, 1) == " . closechars#SafeQuote(g:closechars_rights[c])
            \ . ' ? "\<Right>" : "' . g:closechars_rights[c] . '"'
      exec 'inoremap ' . g:closechars_lefts[c] . ' ' . g:closechars_lefts[c] . g:closechars_rights[c] . '<Left>'
    endif
    let c += 1
  endwhile
  if len(g:closechars_semicolon_endchars)
    inoremap <expr> ; index(g:closechars_semicolon_endchars,
          \ strpart(getline('.'), col('.')-1, 1)) == -1 ? ";" : "\<Right>;"
  endif

  if len(g:closechars_comma_endchars)
    inoremap <expr> , closechars#SmartComma()
  endif

  if g:closechars_pair_delete
    inoremap <expr> <BS> closechars#PairDelete() ? "\<Right>\<BS>\<BS>" : "\<BS>"
  endif
endfunction

function! closechars#SafeQuote(char)
  if a:char == '"'
    return "'\"'"
  else
    return '"' . a:char . '"'
  endif
endfunction

function! closechars#DoMap()
  " inoremap ' ''<Left>
  inoremap '<CR> '<CR>'<Esc>O
  inoremap '' '
  inoremap <expr> '
        \ strpart(getline('.'), col('.')-1, 1) == "'" ? "\<Right>" : "''<Left>"

  " inoremap " ""<Left>
  inoremap "<CR> "<CR>"<Esc>O
  inoremap "" "
  inoremap <expr> "
        \ strpart(getline('.'), col('.')-1, 1) == '"' ? "\<Right>" : '""<Left>'

  inoremap { {}<Left>
  inoremap {<CR> {<CR>}<Esc>O
  inoremap {{ {
  inoremap {} {}
  inoremap <expr> }
        \ strpart(getline('.'), col('.')-1, 1) == "}" ? "\<Right>" : "}"

  inoremap ( ()<Left>
  inoremap (<CR> (<CR>)<Esc>O
  inoremap (( (
  inoremap () ()
  inoremap <expr> )
        \ strpart(getline('.'), col('.')-1, 1) == ")" ? "\<Right>" : ")"

  inoremap < <><Left>
  inoremap << <
  inoremap <expr> >
        \ strpart(getline('.'), col('.')-1, 1) == ">" ? "\<Right>" : ">"

  inoremap [ []<Left>
  inoremap [<CR> [<CR>]<Esc>O
  inoremap [[ [
  inoremap [] []
  inoremap <expr> ]
        \ strpart(getline('.'), col('.')-1, 1) == "]" ? "\<Right>" : "]"

  inoremap /*<CR> /*<CR>*/<Esc>O

  inoremap <expr> ; index(g:closechars_semicolon_endchars,
        \ strpart(getline('.'), col('.')-1, 1)) == -1 ? ";" : "\<Right>;"

  inoremap <expr> , closechars#SmartComma()

  inoremap <expr> <BS> closechars#PairDelete() ? "\<Right>\<BS>\<BS>" : "\<BS>"
endfunction

function! closechars#SmartComma()
  let l:ch = strpart(getline('.'), col('.')-1, 1)
  if index(g:closechars_comma_endchars, l:ch) == -1
    return ","
  else
    return "\<Right>, " . l:ch . l:ch . "\<Left>"
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
  iunmap '
  iunmap '<CR>
  iunmap ''
  iunmap "
  iunmap "<CR>
  iunmap ""
  iunmap {
  iunmap {}
  iunmap {{
  iunmap {<CR>
  iunmap }
  iunmap (
  iunmap ()
  iunmap ((
  iunmap (<CR>
  iunmap )
  iunmap [
  iunmap []
  iunmap [[
  iunmap [<CR>
  iunmap ]
  iunmap <
  iunmap <<
  iunmap >
  iunmap /*<CR>
  iunmap ;
  iunmap ,
endfunction

call closechars#AutoMap()
