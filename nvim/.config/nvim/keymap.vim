"tab
nnoremap <tab> >>
nnoremap <bs> <<
vnoremap <tab> >
vnoremap <bs> <

";
au filetype c inoremap <c-;> <esc>A;
au filetype c nnoremap <c-;> A;<esc>
au filetype cpp inoremap <c-;> <esc>A;
au filetype cpp nnoremap <c-;> A;<esc>
au filetype java inoremap <c-;> <esc>A;
au filetype java nnoremap <c-;> A;<esc>
au filetype python inoremap <c-;> <esc>A:<ENTER>

"{}
au filetype cpp nnoremap <A-[> A {<ENTER>}<esc>O
au filetype c nnoremap <A-[> A {<ENTER>}<esc>O
au filetype java nnoremap <A-[> A {<ENTER>}<esc>O
au filetype javascript nnoremap <A-[> A {<ENTER>}<esc>O
au filetype cpp inoremap <A-[> <esc>A {<ENTER>}<esc>O
au filetype c inoremap <A-[> <esc>A {<ENTER>}<esc>O
au filetype java inoremap <A-[> <esc>A {<ENTER>}<esc>O
au filetype javascript inoremap <A-[> <esc>A {<ENTER>}<esc>O

"noremal enter
nnoremap <enter> o<esc>
