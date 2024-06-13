
function! meisaka#indent() abort
	return luaeval(printf('require"meisaka.indent".indent(%d)', v:lnum))
endfunction
