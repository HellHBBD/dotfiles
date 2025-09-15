vim.pack.add({
	{ src = 'https://github.com/vim-airline/vim-airline' },
})
-- close default mode show
vim.opt.showmode = false

-- highlight tab
vim.g['airline#extensions#tabline#enabled'] = 1
