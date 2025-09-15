local keymap = vim.keymap.set
vim.g.mapleader = ' '

-- reload init.lua
keymap('n', '<F5>', function()
	vim.cmd 'source $MYVIMRC'
	print 'reload nvim config'
end, { desc = 'Reload nvim config' })

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
keymap('x', '<Leader>p', [["_dP]], { desc = 'Paste without overwrite' })

-- yank to clipboard
keymap({ 'n', 'v' }, '<Leader>y', [["+y]], { desc = 'Yank to clipboard' })
keymap({ 'n', 'v' }, '<Leader>d', [["+d]], { desc = 'Delete to clipboard' })
keymap('n', '<Leader>Y', [["+Y]], { desc = 'Yank entire line to clipboard' })

-- Replace current word throughout file
keymap(
	'n',
	'<Leader>s',
	[[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]],
	{ desc = 'Search and replace current word (interactive)' }
)

-- Make current file executable
keymap(
	'n',
	'<Leader>x',
	'<cmd>!chmod +x %<CR>',
	{ desc = 'Make current file executable', silent = true }
)

-- neovim native plugins manager
keymap('n', '<leader>u', function()
	vim.pack.update()
end, { desc = 'Native update plugins' })

-- Lazy nvim
keymap('n', '<leader>l', function()
	vim.cmd 'Lazy sync'
end, { desc = 'Lazy sync' })

-- Clear highlights on search when pressing <Esc> in normal mode
keymap('n', '<Esc>', '<cmd>nohlsearch<CR>', { desc = 'Cancel search highlights' })

-- Quickfix list
keymap('n', '<c-n>', '<cmd>cnext<CR>', { desc = 'Next Quickfix' })

-- Diagnostic keymaps
keymap('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

keymap('n', '<leader>tp', '<cmd>TypstPreview<CR>')
