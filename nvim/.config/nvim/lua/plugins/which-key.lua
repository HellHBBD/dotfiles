return {
	'folke/which-key.nvim',
	event = 'VeryLazy',
	opts = {
		-- Enable which-key presets for non-<Leader> prefixes
		plugins = {
			presets = {
				operators = true, -- d, y, c, etc.
				motions = true, -- w, b, f, t, etc.
				text_objects = true, -- aw, iw, etc.
				windows = true, -- <C-w> navigation
				nav = true, -- g, z, [ and ] navigation
			},
		},
		-- Replace labels (key_labels is deprecated)
		replace = {
			['<space>'] = 'SPC',
			['<cr>'] = 'RET',
			['<tab>'] = 'TAB',
		},
		-- Triggers configuration (triggers_blacklist is deprecated)
		-- Leave empty to use defaults or specify modes/prefixes
		-- triggers = { '<leader>', 'g', 'z', '<C-w>' },
	},
	keys = {
		{
			'<leader>?',
			function()
				-- Show buffer-local mappings
				require('which-key').show({ mode = 'n', buffer = 0 })
			end,
			desc = 'Buffer Local Keymaps (which-key)',
		},
	},
}
