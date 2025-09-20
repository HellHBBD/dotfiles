return {
	'ibhagwan/fzf-lua',
	dependencies = { 'nvim-tree/nvim-web-devicons' },
	config = function()
		local fzf = require('fzf-lua')

		fzf.setup({
			winopts = {
				height = 0.85,
				width = 0.80,
				row = 0.35,
				col = 0.50,
			},
		})

		local keymap = vim.keymap.set
		keymap('n', '<Leader>ff', fzf.files, { desc = 'FzfLua: find files' })
		keymap('n', '<Leader>fg', fzf.live_grep, { desc = 'FzfLua: live grep' })
		keymap('n', '<Leader>fb', fzf.buffers, { desc = 'FzfLua: list buffers' })
		keymap('n', '<Leader>fh', fzf.help_tags, { desc = 'FzfLua: help tags' })
	end,
}
