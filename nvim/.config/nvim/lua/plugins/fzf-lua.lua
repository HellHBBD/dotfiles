return {
	'ibhagwan/fzf-lua',
	dependencies = { 'nvim-tree/nvim-web-devicons' },
	keys = {
		{
			'<Leader>ff',
			function()
				require('fzf-lua').files()
			end,
			desc = 'FzfLua: find files',
		},
		{
			'<Leader>fg',
			function()
				require('fzf-lua').live_grep()
			end,
			desc = 'FzfLua: live grep',
		},
		{
			'<Leader>fb',
			function()
				require('fzf-lua').buffers()
			end,
			desc = 'FzfLua: list buffers',
		},
		{
			'<Leader>fh',
			function()
				require('fzf-lua').help_tags()
			end,
			desc = 'FzfLua: help tags',
		},
	},
	config = function()
		local fzf = require('fzf-lua')

		local exclude = {
			'.git',
			'node_modules',
			'dist',
			'build',
			'*.lock',
			'mariadb',
			'.venv',
		}

		local function build_fd_opts()
			local opts = { '--color=always', '--type', 'f', '--hidden', '--follow' }
			for _, pat in ipairs(exclude) do
				table.insert(opts, '--exclude')
				table.insert(opts, pat)
			end
			return table.concat(opts, ' ')
		end

		local function build_rg_opts()
			local opts = { '--hidden' }
			for _, pat in ipairs(exclude) do
				table.insert(opts, '--igblob')
				table.insert(opts, pat)
			end
			return table.concat(opts, ' ')
		end

		fzf.setup({
			defaults = {
				file_icons = 'mini',
				copen = 'topleft copen',
			},
			files = {
				fd_opts = build_fd_opts(),
			},
			grep = {
				grep_opts = build_rg_opts(),
				rg_opts = '--hidden --no-ignore -n --column',
				fzf_opts = {
					['--exact'] = '',
				},
			},
			keymap = {
				fzf = {
					['ctrl-q'] = 'select-all+accept',
				},
			},
			preview = {
				layout = 'horizontal',
			},
		})
	end,
}
