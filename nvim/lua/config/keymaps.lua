-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

vim.keymap.set("n", "<leader>pr", "<cmd>!python %<CR>", { desc = "[p]ython [R]un Current File" })
vim.keymap.set("n", "<leader>pv", "<cmd>VenvSelect<CR>", { desc = "[P]ython [V]env Select" })
