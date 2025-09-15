return {
	'lukas-reineke/indent-blankline.nvim',
	main = 'ibl',
	---@module "ibl"
	---@type ibl.config
	opts = {
		indent = {
			char = '▏',
		},
		scope = {
			show_start = true,
			show_end = true,
			show_exact_scope = true,
		},
		exclude = {
			filetypes = {
				'help',
				'startify',
				'dashboard',
				'packer',
				'neogitstatus',
				'NvimTree',
				'Trouble',
			},
		},
	},
}
