if exists("loaded_global_vim")
	finish
endif

let s:old_cpo = &cpo
set cpo&vim

let s:global_command = 'global'

function! GtagsUpdateHandler(job, status)
	if a:status == 0
		echo "Gtags Update!"
	endif
endfunction

function! GtagsShowHandler(job, msg)
	let words = split(a:msg, ':')
	call popup_atcursor(words[-1], {})	
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

	silent exe "cs add " . gtagsroot . "/GTAGS"
endfunction

function! s:GtagsReSetCscope()
    let cmd = "cd ". fnamemodify(expand('%'), ":p:h").";".s:global_command . " -pq"
    let cmd_output = system(cmd)
    if v:shell_error != 0
        return
    endif

    let gtagsroot = strpart(cmd_output, 0, strlen(cmd_output) - 1)
	if gtagsroot == ''
		return
	endif

	silent exe "cs kill 0"
	call chdir(gtagsroot)
	silent exe "cs add GTAGS"
endfunction

autocmd! BufWritePost * call s:GtagsAutoUpdate()
autocmd! CursorHold * call s:GtagsShowName()
autocmd! VimEnter * call s:GtagsCscope()

nmap <C-\>s :cs find s <C-R>=expand("<cword>")<CR><CR>
nmap <C-\>g :cs find g <C-R>=expand("<cword>")<CR><CR>
nmap <C-\>c :cs find c <C-R>=expand("<cword>")<CR><CR>
nmap <C-\>t :cs find t <C-R>=expand("<cword>")<CR><CR>
nmap <C-\>e :cs find e <C-R>=expand("<cword>")<CR><CR>
nmap <C-\>f :cs find f <C-R>=expand("<cfile>")<CR><CR>
nmap <C-\>i :cs find i <C-R>=expand("<cfile>")<CR><CR>
nmap <C-\>a :cs find a <C-R>=expand("<cword>")<CR><CR>
nmap <silent> <C-\>r :call <SID>GtagsReSetCscope()<CR>

let &cpo = s:old_cpo
let loaded_global_vim = 1
