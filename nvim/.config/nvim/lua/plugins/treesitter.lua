return {
	'nvim-treesitter/nvim-treesitter',
	build = ':TSUpdate',
	main = 'nvim-treesitter.configs',

	opts = {
		ensure_installed = {
			'bash',
			'c',
			'diff',
			'html',
			'lua',
			'luadoc',
			'markdown',
			'markdown_inline',
			'query',
			'vim',
			'vimdoc',
			'rust',
			'python',
		},
		auto_install = true,
		highlight = {
			enable = true,
			additional_vim_regex_highlighting = {
				'bash',
				'c',
				'diff',
				'html',
				'lua',
				'luadoc',
				'markdown',
				'markdown_inline',
				'query',
				'vim',
				'vimdoc',
				'rust',
				'python',
			},
		},
	},

	config = function(_, opts)
		local parser_config = require('nvim-treesitter.parsers').get_parser_configs()
		local install = require('nvim-treesitter.install')

		install.compilers = { 'gcc', 'clang' }

		install.prefer_git = true

		install.parser_install_dir = vim.fn.stdpath('data') .. '/parsers'

		vim.opt.runtimepath:append(vim.fn.stdpath('data') .. '/parsers')

		require('nvim-treesitter.configs').setup(opts)
	end,
}
