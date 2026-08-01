local config_home = vim.env.XDG_CONFIG_HOME or vim.fn.expand('~/.config')
local prettier_config_names = {
	'.prettierrc',
	'.prettierrc.json',
	'.prettierrc.yml',
	'.prettierrc.yaml',
	'.prettierrc.json5',
	'.prettierrc.js',
	'.prettierrc.cjs',
	'.prettierrc.mjs',
	'.prettierrc.ts',
	'.prettierrc.cts',
	'.prettierrc.mts',
	'.prettierrc.toml',
	'prettier.config.js',
	'prettier.config.cjs',
	'prettier.config.mjs',
	'prettier.config.ts',
	'prettier.config.cts',
	'prettier.config.mts',
}

local function config_for(ctx, names, fallback)
	return vim.fs.find(names, { path = ctx.dirname, upward = true })[1] or fallback
end

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
			python = { 'ruff_format' },
			go = { 'gofmt' },
			c = { 'clang_format' },
			cpp = { 'clang_format' },
			sh = { 'shfmt' },
			rust = { 'rustfmt' },
			json = { 'prettier' },
			jsonc = { 'prettier' },
			css = { 'prettier' },
			markdown = { 'prettier' },
			toml = { 'taplo' },
			html = { 'prettier' },
			just = { 'just' },
		},
		formatters = {
			prettier = {
				append_args = function(_, ctx)
					if
						vim.fs.find(prettier_config_names, { path = ctx.dirname, upward = true })[1]
					then
						return {}
					end
					return { '--config', config_home .. '/prettier/config.json' }
				end,
			},
			taplo = {
				args = function(_, ctx)
					return {
						'format',
						'--config',
						config_for(
							ctx,
							{ '.taplo.toml', 'taplo.toml' },
							config_home .. '/taplo/taplo.toml'
						),
						'--stdin-filepath',
						'$FILENAME',
						'-',
					}
				end,
			},
			just = {
				args = { '--fmt', '-f', '$FILENAME' },
			},
		},
	},
}
