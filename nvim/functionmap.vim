"file refresh
if has('win32')
	inoremap <F5> <esc>:source ~/AppData/Local/nvim/init.vim<cr>
	nnoremap <F5> :source ~/AppData/Local/nvim/init.vim<cr>
elseif has('unix')
	inoremap <F5> <esc>:source ~/.config/nvim/init.vim<cr>
	nnoremap <F5> :source ~/.config/nvim/init.vim<cr>
endif
inoremap <c-6> <esc>:w<cr><c-6>
nnoremap <c-6> :w<cr><c-6>

"compile
if has('win32')
	au filetype c nnoremap <F6> :w<cr>:!gcc -std=c99 "%" -lm<cr>
	au filetype c inoremap <F6> <esc>:w<cr>:!gcc -std=c99 "%" -lm<cr>
	au filetype cpp nnoremap <F6> :w<cr>:!g++ "%"<cr>
	au filetype cpp nnoremap <F6> <esc>:w<cr>:!g++ "%"<cr>
	au filetype java nnoremap <F6> :w<cr>:!javac "%"<cr>
	au filetype java inoremap <F6> <esc>:w<cr>:!javac "%"<cr>
elseif has('unix')
	au filetype c nnoremap <F6> :w<cr>:!gcc -std=c99 "%" -lm<cr>
	au filetype c inoremap <F6> <esc>:w<cr>:!gcc -std=c99 "%" -lm<cr>
	au filetype cpp nnoremap <F6> :w<cr>:!g++ "%"<cr>
	au filetype cpp nnoremap <F6> <esc>:w<cr>:!g++ "%"<cr>
	au filetype java nnoremap <F6> :w<cr>:!javac "%"<cr>
	au filetype java inoremap <F6> <esc>:w<cr>:!javac "%"<cr>
endif
au filetype java nnoremap <F6> :w<cr>:!javac "%"<cr>
au filetype java inoremap <F6> <esc>:w<cr>:!javac "%"<cr>

"run
if has('win32')
	au filetype c nnoremap <F7> :w<cr>:!gcc -std=c99 "%" -lm & a<cr>
	au filetype c inoremap <F7> <esc>:w<cr>:!gcc -std=c99 "%" -lm & a<cr>
	au filetype cpp nnoremap <F7> :w<cr>:!g++ "%" & a<cr>
	au filetype cpp nnoremap <F7> <esc>:w<cr>:!g++ "%" & a<cr>
elseif has('unix')
	au filetype c nnoremap <F7> :w<cr>:!gcc -std=c99 "%" -lm ; ./a.out<cr>
	au filetype c inoremap <F7> <esc>:w<cr>:!gcc -std=c99 "%" -lm ; ./a.out<cr>
	au filetype cpp nnoremap <F7> :w<cr>:!g++ "%" ; ./a.out<cr>
	au filetype cpp nnoremap <F7> <esc>:w<cr>:!g++ "%" ; ./a.out<cr>
endif
if has('win32')
	au filetype python nnoremap <F7> :w<cr>:!python "%"<cr>
	au filetype python inoremap <F7> <esc>:w<cr>:!python "%"<cr>
elseif has('unix')
	au filetype python nnoremap <F7> :w<cr>:!python3 "%"<cr>
	au filetype python inoremap <F7> <esc>:w<cr>:!python3 "%"<cr>
endif
au filetype java nnoremap <F7> :w<cr>:!java "%"<cr>
au filetype java inoremap <F7> <esc>:w<cr>:!java "%"<cr>

"debugger
if has('win32')
	au filetype c nnoremap <F8> :w<cr>:!gcc -std=c99 -g "%" -lm<cr>
	au filetype cpp nnoremap <F8> :w<cr>:!g++ -g "%"<cr>
elseif has('unix')
	au filetype c nnoremap <F8> :w<cr>:!gcc -std=c99 -g "%" -lm<cr>
	au filetype cpp nnoremap <F8> :w<cr>:!g++ -g "%"<cr>
endif

"clang-format
nnoremap <F9> :w<cr>:!clang-format -i "%"<cr>:e!<cr>
