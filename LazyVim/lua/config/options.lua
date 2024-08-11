-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- don't auto break line
vim.opt.wrap = false

-- smart indent
-- vim.opt.smartindent = true

-- smooth horizontal scroll
vim.opt.sidescroll = 1

-- tab = n blank
vim.opt.tabstop = 4

-- indent = n blank
vim.opt.shiftwidth = 4

-- disable temp file
vim.opt.swapfile = true
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true

-- when to show tab (0: never, 1: at least 2, 2: always)
vim.opt.showtabline = 2

-- new at below
vim.opt.splitbelow = true

-- vnew at right
vim.opt.splitright = true

vim.opt.hlsearch = false
vim.opt.incsearch = true

vim.opt.termguicolors = true

vim.opt.scrolloff = 8
