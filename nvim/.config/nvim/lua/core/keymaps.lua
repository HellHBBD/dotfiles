local keymap = vim.keymap.set
vim.g.mapleader = ' '

-- reload init.lua
keymap('n', '<F5>', function()
	package.loaded['core'] = nil
	package.loaded['core.keymaps'] = nil
	vim.cmd('source $MYVIMRC')
	print('reload nvim config')
end, { desc = 'Reload nvim config' })

local function open_build_popup(command, directory)
	if vim.env.TMUX == nil or vim.env.TMUX_PANE == nil then
		vim.notify('F6/F7 requires Neovim to run inside tmux', vim.log.levels.WARN)
		return false
	end

	local popup_command = "printf '%s\\n\\n' "
		.. vim.fn.shellescape('$ ' .. command)
		.. '; '
		.. command
		.. '; status=$?; printf \'\\nExit status: %d. Press Enter to close.\' "$status"; read -r _'

	vim.system({
		'tmux',
		'display-popup',
		'-E',
		'-t',
		vim.env.TMUX_PANE,
		'-d',
		directory,
		'-w',
		'80%',
		'-h',
		'80%',
		popup_command,
	})
	return true
end

local function build_current_file(run)
	local file = vim.api.nvim_buf_get_name(0)
	if file == '' then
		vim.notify('Save the current file before building', vim.log.levels.WARN)
		return
	end

	vim.cmd('update')

	local compiler = ({ c = 'gcc', cpp = 'g++' })[vim.bo.filetype]
	if compiler == nil then
		vim.notify('No C/C++ compiler for ' .. vim.bo.filetype, vim.log.levels.WARN)
		return
	end
	if vim.fn.executable(compiler) ~= 1 then
		vim.notify(compiler .. ' is not available in PATH', vim.log.levels.ERROR)
		return
	end

	local directory = vim.fs.dirname(file)
	local output = vim.fs.joinpath(directory, vim.fn.fnamemodify(file, ':t:r'))
	local command = compiler
		.. ' '
		.. vim.fn.shellescape(file)
		.. ' -o '
		.. vim.fn.shellescape(output)
	if run then
		command = command .. ' && ' .. vim.fn.shellescape(output)
	end

	open_build_popup(command, directory)
end

keymap('n', '<F6>', function()
	build_current_file(false)
end, { desc = 'Build current C/C++ file' })

keymap('n', '<F7>', function()
	build_current_file(true)
end, { desc = 'Build and run current C/C++ file' })

-- indent shorcut
keymap('n', '<tab>', '>>', { desc = 'Indent to the right' })
keymap('n', '<bs>', '<<', { desc = 'Indent to the left' })
keymap('v', '<tab>', '>', { desc = 'Indent to the right' })
keymap('v', '<bs>', '<', { desc = 'Indent to the left' })

-- normal mode enter
keymap('n', '<enter>', 'o<esc>"_cc<esc>', { desc = 'Insert line below' })
keymap('n', '<leader><enter>', 'O<esc>"_cc<esc>', { desc = 'Insert line above' })
keymap('n', 'o', 'o<esc>"_cc', { desc = 'Open line below' })
keymap('n', 'O', 'O<esc>"_cc', { desc = 'Open line above' })

-- hover code
keymap('v', 'J', ":m '>+1<CR>gv=gv", { desc = 'Hover code down' })
keymap('v', 'K', ":m '<-2<CR>gv=gv", { desc = 'Hover code up' })

-- remain cursor position
keymap('n', 'J', 'mzJ`z')
keymap('n', '<C-d>', '<C-d>zz')
keymap('n', '<C-u>', '<C-u>zz')
keymap('n', 'n', 'nzzzv')
keymap('n', 'N', 'Nzzzv')

-- Paste without overwriting register
keymap('x', '<leader>p', [["_dP]], { desc = 'Paste without overwrite' })

-- yank to clipboard
keymap({ 'n', 'v' }, '<leader>y', [["+y]], { desc = 'Yank to clipboard' })
keymap({ 'n', 'v' }, '<leader>d', [["+d]], { desc = 'Delete to clipboard' })
keymap('n', '<leader>Y', [["+Y]], { desc = 'Yank entire line to clipboard' })

-- Replace current word throughout file
keymap(
	'n',
	'<leader>s',
	[[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]],
	{ desc = 'Search and replace current word (interactive)' }
)

-- Make current file executable
keymap(
	'n',
	'<leader>x',
	'<cmd>!chmod +x %<CR>',
	{ desc = 'Make current file executable', silent = true }
)

-- neovim native plugins manager
keymap('n', '<leader>u', function()
	vim.pack.update()
end, { desc = 'Native update plugins' })

-- Lazy nvim
keymap('n', '<leader>l', function()
	vim.cmd('Lazy sync')
end, { desc = 'Lazy sync' })

-- Clear highlights on search when pressing <Esc> in normal mode
keymap('n', '<Esc>', '<cmd>nohlsearch<CR>', { desc = 'Cancel search highlights' })

-- Quickfix list
keymap('n', '<c-n>', '<cmd>cnext<CR>', { desc = 'Next Quickfix' })
keymap('n', '<c-p>', '<cmd>cprev<CR>', { desc = 'Prev Quickfix' })

-- Diagnostic keymaps
keymap('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

local opts = { noremap = true, silent = true }
opts.desc = 'Run or Preview depending on filetype'
keymap('n', '<leader>r', function()
	local ft = vim.bo.filetype -- 取得當前檔案類型
	local fname = vim.fn.expand('%') -- 取得檔案名稱
	local outname = fname:gsub('%.%w+$', '') -- 去掉副檔名做輸出檔名

	if ft == 'c' then
		vim.cmd('!gcc ' .. fname .. ' -o ' .. outname .. ' && ./' .. outname)
	elseif ft == 'cpp' then
		vim.cmd('!g++ ' .. fname .. ' -o ' .. outname .. ' && ./' .. outname)
	elseif ft == 'python' then
		vim.cmd('!python ' .. fname)
	elseif ft == 'lua' then
		vim.cmd('!lua ' .. fname)
	elseif ft == 'go' then
		vim.cmd('!go run ' .. fname)
	elseif ft == 'markdown' then
		vim.cmd(':MarkdownPreviewToggle')
	elseif ft == 'typst' then
		vim.cmd(':TypstPreview')
	elseif ft == 'html' then
		vim.cmd(':HtmlPreview')
	else
		print('No run/preview command for filetype: ' .. ft)
	end
end, opts)
