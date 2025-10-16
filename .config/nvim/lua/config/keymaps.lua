-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Horizontal and vertical splits
vim.api.nvim_set_keymap("n", "<leader>_", ":split<CR>", { noremap = true, silent = true, desc = "Horizontal Split" })
vim.api.nvim_set_keymap("n", "<leader>\\", ":vsplit<CR>", { noremap = true, silent = true, desc = "Vertical Split" })
