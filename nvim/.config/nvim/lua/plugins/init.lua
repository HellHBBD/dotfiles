local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
	local out = vim.fn.system({
		'git',
		'clone',
		'--filter=blob:none',
		'--branch=stable',
		lazyrepo,
		lazypath,
	})
	if vim.v.shell_error ~= 0 then error('Error cloning lazy.nvim:\n' .. out) end
end

---@type vim.Option
local rtp = vim.opt.rtp
rtp:prepend(lazypath)

require('lazy').setup({
	{ import = 'plugins.tokyonight', lazy = false },

	{ import = 'plugins.lualine', event = 'VeryLazy' },
	{ import = 'plugins.treesitter', event = { 'BufReadPost', 'BufNewFile' } },
	{ import = 'plugins.lsp', event = { 'BufReadPre', 'BufNewFile' } },
	{ import = 'plugins.cmp', event = 'InsertEnter' },
	{ import = 'plugins.format', event = 'BufWritePre' },
	{ import = 'plugins.indent-blankline', event = 'BufReadPost' },
	{ import = 'plugins.which-key', event = 'VeryLazy' },
	{ import = 'plugins.fzf-lua', cmd = 'FzfLua' },
	{ import = 'plugins.harpoon', keys = { '<leader>a', '<leader>h' } },
	-- { import = 'plugins.render-markdown', ft = 'markdown' },
	{ import = 'plugins.colorizer', event = 'BufReadPost' },
	{ import = 'plugins.oil' },

	{ 'ThePrimeagen/vim-be-good', cmd = 'VimBeGood' },
	{ 'chomosuke/typst-preview.nvim', ft = 'typst', version = '1.*', opts = {} },
})

-- require('plugins.rose-pine')
-- require('plugins.vim-airline')
