return {
	'ibhagwan/fzf-lua',
	dependencies = { 'nvim-tree/nvim-web-devicons' },
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
				file_icons = 'mini', -- 全域設定使用 mini.icons
				copen = 'topleft copen', -- quickfix 視窗預設打開在上面
			},
			files = {
				fd_opts = build_fd_opts(),
			},
			grep = {
				grep_opts = build_rg_opts(),
				rg_opts = '--hidden --no-ignore -n --column',
				fzf_opts = {
					['--exact'] = '', -- 搜索时优先精确匹配
				},
			},
			keymap = {
				fzf = {
					['ctrl-q'] = 'select-all+accept',
				},
			},
		})

		local keymap = vim.keymap.set
		keymap('n', '<Leader>ff', fzf.files, { desc = 'FzfLua: find files' })
		keymap('n', '<Leader>fg', fzf.live_grep, { desc = 'FzfLua: live grep' })
		keymap('n', '<Leader>fb', fzf.buffers, { desc = 'FzfLua: list buffers' })
		keymap('n', '<Leader>fh', fzf.help_tags, { desc = 'FzfLua: help tags' })
	end,
}
