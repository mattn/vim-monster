scriptencoding utf-8
let s:save_cpo = &cpo
set cpo&vim


function! monster#completion#rcodetools#rct_complete#command(context, file)
	return printf(g:monster#completion#rcodetools#complete_command . " --completion-class-info --dev --fork --line=%d --column=%d %s", a:context.line, a:context.complete_pos, a:file)
endfunction


function! monster#completion#rcodetools#rct_complete#check()
	return executable("rct-complete")
endfunction


function! monster#completion#rcodetools#rct_complete#complete(context)
	if !executable(g:monster#completion#rcodetools#complete_command)
		call monster#errmsg("No executable 'rct-complete' command.")
		call monster#errmsg("Please install 'gem install rcodetools'.")
		return
	endif
	try
" 		echo "monster.vim - start rct-complete"
		let file = monster#make_tempfile(a:context.bufnr, "rb")
		let command = monster#completion#rcodetools#rct_complete#command(a:context, file)
		let result = system(command)
	finally
		call delete(file)
	endtry
	call monster#debug_log(
\		"[rct_complete.vim] rct-complete command : " . command . "\n"
\	  . "[rct_complete.vim] rct-complete result : \n" . result
\	)
	if v:shell_error != 0
" 		call monster#errmsg(command)
" 		call monster#errmsg(result)
" 		echo "monster.vim - failed rct-complete"
		return []
	endif
	echo "monster.vim - finish rct-complete"
	return monster#completion#rcodetools#parse(result)
endfunction


function! monster#completion#rcodetools#rct_complete#test()
	let start_time = reltime()
	let context = monster#context#get_current()
	let old_debug = g:monster#debug#enable
	let g:monster#debug#enable = 1
	call monster#debug#clear_log()
	
	try
		let result = monster#completion#rcodetools#rct_complete#complete(context)
		return { "context" : context, "result" : result, "log" : monster#debug#log() }
	finally
		let g:monster#debug#enable = old_debug
		echom "Complete time " . reltimestr(reltime(start_time))
	endtry
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
