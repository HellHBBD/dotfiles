return {
	'scrooloose/nerdtree',
	name = 'nerd-tree',

	init = function()
		vim.g.NERDTreeMinimalUI = 1
		vim.g.NERDTreeQuitOnOpen = 1
	end,
	-- 快捷鍵綁定
	keys = {
		{
			'<F2>',
			'<cmd>NERDTreeToggle<cr>',
			mode = 'n',
			desc = 'Toggle NERDTree',
		},
	},

	config = function() end,
}
