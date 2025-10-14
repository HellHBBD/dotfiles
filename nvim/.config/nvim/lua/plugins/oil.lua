local function toggle_oil_float()
	local ft = vim.bo.filetype
	if ft == 'oil' then
		vim.cmd('close')
	else
		vim.cmd('Oil --float')
	end
end

return {
	{
		'stevearc/oil.nvim',
		---@module 'oil'
		---@type oil.SetupOpts
		opts = {},
		dependencies = { { 'nvim-mini/mini.icons', opts = {} } },
		keys = {
			{
				'<F2>',
				toggle_oil_float,
				desc = 'Toggle Oil',
			},
		},
		config = function()
			require('oil').setup({
				float = {
					max_width = 0.3,
				},
			})
		end,
	},
}
