return {
	'nvim-telescope/telescope.nvim',
	event = 'VimEnter',
	dependencies = {
		'nvim-lua/plenary.nvim',
		{
			'nvim-telescope/telescope-fzf-native.nvim',

			build = 'make',

			cond = function()
				return vim.fn.executable('make') == 1
			end,
		},
	},
	keys = {
		{
			'<Leader>ff',
			function()
				require('telescope.builtin').find_files()
			end,
			desc = 'Telescope: find files',
		},
		{
			'<Leader>gf',
			function()
				require('telescope.builtin').git_files()
			end,
			desc = 'Telescope: find git files',
		},
		{
			'<Leader>fg',
			function()
				require('telescope.builtin').live_grep()
			end,
			desc = 'Telescope: live grep',
		},
		{
			'<Leader>fb',
			function()
				require('telescope.builtin').buffers()
			end,
			desc = 'Telescope: list buffers',
		},
		{
			'<Leader>fh',
			function()
				require('telescope.builtin').help_tags()
			end,
			desc = 'Telescope: help tags',
		},
	},

	config = function()
		local telescope = require('telescope')
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

		telescope.load_extension('fzf')
	end,
}
