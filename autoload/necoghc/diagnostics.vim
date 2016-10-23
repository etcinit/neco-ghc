function! necoghc#diagnostics#report() abort
  let l:debug_flag = get(g:, 'necoghc_debug', 0)
  if !l:debug_flag
    let g:necoghc_debug = 1
  endif

  echomsg 'Current filetype:' &l:filetype

  if executable('stack')
    if system('stack exec -- ghc-mod --help > /dev/null 2>&1; echo $?') == 0
      echomsg 'ghc-mod is executable through stack'
    else
      echomsg 'ghc-mod missing. Run stack install ghc-mod'
    endif
  else
    let l:executable = executable('ghc-mod')
    echomsg 'ghc-mod is executable:' l:executable
    if !l:executable
      echomsg '  Your $PATH:' $PATH
    endif
  endif

  echomsg 'omnifunc:' &l:omnifunc
  echomsg '> deoplete:' exists('g:loaded_deoplete')
  echomsg '> neocomplete.vim:' exists(':NeoCompleteEnable')
  echomsg '> neocomplcache.vim:' exists(':NeoComplCacheEnable')
  echomsg '> YouCompleteMe:' exists(':YcmDebugInfo')

  try
    echomsg 'vimproc.vim:' vimproc#version()
  catch /^Vim\%((\a\+)\)\=:E117/
    echomsg 'vimproc.vim: not installed'
  endtry

  echomsg 'ghc-mod:' necoghc#ghc_mod_version()

  if &l:filetype !=# 'haskell'
    call s:error('Run this command in the buffer opening a Haskell file')
    return
  endif
  call necoghc#boot()
  echomsg 'Imported modules:' join(keys(necoghc#get_modules()), ', ')

  echomsg 'Number of symbols in Prelude:' len(necoghc#browse('Prelude'))

  if !l:debug_flag
    let g:necoghc_debug = 0
  endif
endfunction

function! s:error(msg) abort
  echohl ErrorMsg
  echomsg a:msg
  echohl None
endfunction
