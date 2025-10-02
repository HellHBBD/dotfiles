return {
	'stevearc/conform.nvim',
	event = { 'BufWritePre' },
	cmd = { 'ConformInfo' },
	opts = {
		notify_on_error = false,
		format_on_save = function(bufnr)
			-- Disable "format_on_save lsp_fallback" for languages that don't
			-- have a well standardized coding style. You can add additional
			-- languages here or re-enable it for the disabled ones.
			local disable_filetypes = {}
			if disable_filetypes[vim.bo[bufnr].filetype] then
				return nil
			else
				return {
					timeout_ms = 500,
					lsp_format = 'fallback',
				}
			end
		end,
		formatters_by_ft = {
			lua = { 'stylua' },
			python = { 'ruff' },
			go = { 'gofmt' },
			c = { 'clang_format' },
			cpp = { 'clang_format' },
			sh = { 'shfmt' },
			rust = { 'rustfmt' },
			json = { 'prettier' },
			toml = { 'taplo' },
			html = { 'prettier' },
		},
		formatters = {
			stylua = {
				enable = true,
			},
			prettier = {
				prepend_args = { '--tab-width', '4', '--use-tabs', 'false' },
			},
			shfmt = {
				prepend_args = { '-i', '4' },
			},
			taplo = {
				prepend_args = { '--option', 'indent_string=    ' },
			},
		},
	},
}
