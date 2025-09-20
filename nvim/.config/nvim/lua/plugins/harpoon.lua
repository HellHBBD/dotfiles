return {
	'ThePrimeagen/harpoon',
	name = 'harpoon',
	dependencies = {
		'nvim-lua/plenary.nvim',
	},
	config = function()
		local mark = require('harpoon.mark')
		local ui = require('harpoon.ui')
		local keymap = vim.keymap.set

		keymap('n', '<leader>a', function()
			mark.add_file()
			print('Add file to harpoon list')
		end, { desc = 'Add file to harpoon list' })

		keymap('n', '<C-e>', ui.toggle_quick_menu, { desc = 'Toggle harpoon menu' })

		keymap('n', '<C-h>', function() ui.nav_file(1) end, { desc = 'Navigate to file 1' })
		keymap('n', '<C-j>', function() ui.nav_file(2) end, { desc = 'Navigate to file 2' })
		keymap('n', '<C-k>', function() ui.nav_file(3) end, { desc = 'Navigate to file 3' })
		keymap('n', '<C-l>', function() ui.nav_file(4) end, { desc = 'Navigate to file 4' })
	end,
}
