if exists("loaded_global_vim")
	finish
endif

let s:old_cpo = &cpo
set cpo&vim

let s:global_command = $GTAGSGLOBAL
if s:global_command == ''
	let s:global_command = 'global'
endif

function! GtagsUpdateHandler(job, status)
	if a:status == 0
		echo "Gtags Update!"
	endif
endfunction

function! GtagsShowHandler(job, msg)
	let words = split(a:msg, ':')
	echohl ModeMsg
	echo words[-1]
	echohl None
endfunction

function! s:GtagsAutoUpdate()
    call job_start(s:global_command . " -u --single-update=\"" . expand("%") . "\"", {'exit_cb': 'GtagsUpdateHandler'})
endfunction

function! s:GtagsShowName()
	let result = expand("<cword>")
	if filereadable("GPATH") == 1 && result =~# "\\<\\h\\w*\\>"
		call job_start(s:global_command . " --result=grep " . result, {'out_cb': 'GtagsShowHandler'})
	endif
endfunction

function! s:GtagsCscope_GtagsRoot()
    let cmd = s:global_command . " -pq"
    let cmd_output = system(cmd)
    if v:shell_error != 0
        return ''
    endif
    return strpart(cmd_output, 0, strlen(cmd_output) - 1)
endfunction

function! s:GtagsCscope()
	let gtagsroot = s:GtagsCscope_GtagsRoot()
	if gtagsroot == ''
		return
	endif

	set csprg=gtags-cscope
	let s:command = "cs add " . gtagsroot . "/GTAGS"
	set nocscopeverbose
	exe s:command
	set cscopeverbose

	nmap <C-\>s :cs find s <C-R>=expand("<cword>")<CR>
	nmap <C-\>t :cs find g <C-R>=expand("<cword>")<CR>
	nmap <C-\>r :cs find c <C-R>=expand("<cword>")<CR>
	nmap <C-\>g :cs find e <C-R>=expand("<cword>")<CR>
endfunction

autocmd! BufWritePost * call s:GtagsAutoUpdate()
autocmd! CursorHold * call s:GtagsShowName()
autocmd! DirChanged * call s:GtagsCscope()

let &cpo = s:old_cpo
let loaded_global_vim = 1
