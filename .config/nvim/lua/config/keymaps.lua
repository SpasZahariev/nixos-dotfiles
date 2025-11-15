-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Horizontal and vertical splits
vim.api.nvim_set_keymap("n", "<leader>_", ":split<CR>", { noremap = true, silent = true, desc = "Horizontal Split" })
vim.api.nvim_set_keymap("n", "<leader>\\", ":vsplit<CR>", { noremap = true, silent = true, desc = "Vertical Split" })

-- disable default S behaviour (delete and replace char) so i can use mini.surround
-- disable in normal mode
vim.keymap.set("n", "s", "<Nop>")

-- disable in visual mode
vim.keymap.set("x", "s", "<Nop>")

-- Primagen Join lines
local opts = { noremap = true, silent = true }
vim.keymap.set("n", "J", "mzJ`z", opts)

-- Move lines up and down
-- Normal mode
vim.keymap.set("n", "<A-j>", ":m .+1<CR>==", opts)
vim.keymap.set("n", "<A-k>", ":m .-2<CR>==", opts)

-- Visual mode
vim.keymap.set("v", "<A-j>", ":m '>+1<CR>gv=gv", opts)
vim.keymap.set("v", "<A-k>", ":m '<-2<CR>gv=gv", opts)
