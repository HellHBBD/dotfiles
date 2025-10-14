-- Highlight on yank
local highlight_group = vim.api.nvim_create_augroup('HighlightYank', { clear = true })

vim.api.nvim_create_autocmd('TextYankPost', {
	group = highlight_group,
	callback = function()
		(vim.hl or vim.highlight).on_yank({ higroup = 'IncSearch', timeout = 150 })
	end,
})

vim.api.nvim_create_user_command('HtmlPreview', function()
	local file = vim.fn.expand('%:t')
	local dir = vim.fn.expand('%:p:h')
	vim.fn.jobstart({ 'live-server', dir, '--open=/' .. file }, { detach = true })
end, {})
