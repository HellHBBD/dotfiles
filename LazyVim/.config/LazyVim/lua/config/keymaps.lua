-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- indent shorcut
vim.keymap.set("n", "<tab>", ">>")
vim.keymap.set("n", "<bs>", "<<")

-- noremal enter
vim.keymap.set("n", "<enter>", "o<esc>")
-- vim.keymap.set("n", "<S-<enter>>", "O<esc>")

-- hover code
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- remain cursor position
vim.keymap.set("n", "J", "mzJ`z")
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- paste without replace register
-- vim.keymap.set("x", "<A-y>", [["_dP]])
