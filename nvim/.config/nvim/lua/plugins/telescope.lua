return {
	'nvim-telescope/telescope.nvim',
	event = 'VimEnter',
	dependencies = {
		'nvim-lua/plenary.nvim',
		{
			'nvim-telescope/telescope-fzf-native.nvim',

			build = 'make',

			cond = function()
				return vim.fn.executable 'make' == 1
			end,
		},
	},

	config = function()
		local telescope = require 'telescope'
		-- local themes = require 'telescope.themes'

		telescope.setup({
			extensions = {
				fzf = {
					fuzzy = true,
					override_generic_sorter = true,
					override_file_sorter = true,
					case_mode = 'smart_case',
				},
			},
		})

		telescope.load_extension 'fzf'

		local keymap = vim.keymap.set
		local builtin = require 'telescope.builtin'
		keymap('n', '<Leader>ff', builtin.find_files, { desc = 'Telescope: find files' })
		keymap('n', '<Leader>gf', builtin.git_files, { desc = 'Telescope: find git files' })
		keymap('n', '<Leader>fg', builtin.live_grep, { desc = 'Telescope: live grep' })
		keymap('n', '<Leader>fb', builtin.buffers, { desc = 'Telescope: list buffers' })
		keymap('n', '<Leader>fh', builtin.help_tags, { desc = 'Telescope: help tags' })
	end,
}
