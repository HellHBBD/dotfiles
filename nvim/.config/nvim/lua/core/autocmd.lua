-- local function augroup(name)
-- 	return vim.api.nvim_create_augroup('lazyvim_' .. name, { clear = true })
-- end

-- Highlight on yank
local highlight_group = vim.api.nvim_create_augroup('HighlightYank', { clear = true })

vim.api.nvim_create_autocmd('TextYankPost', {
	group = highlight_group,
	callback = function()
		(vim.hl or vim.highlight).on_yank({ higroup = 'IncSearch', timeout = 150 })
	end,
})

vim.api.nvim_create_user_command('HtmlPreview', function()
	local file = vim.fn.expand('%:p')
	vim.fn.jobstart({ 'live-server', file }, { detach = true })
end, {})
