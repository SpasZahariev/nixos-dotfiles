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

-- Reselect after indent/dedent in visual mode
vim.keymap.set("v", "<", "<gv", opts)
vim.keymap.set("v", ">", ">gv", opts)

-- Keep cursor centered after jumps
vim.keymap.set("n", "n", "nzzzv", opts)
vim.keymap.set("n", "N", "Nzzzv", opts)
vim.keymap.set("n", "<C-d>", "<C-d>zz", opts)
vim.keymap.set("n", "<C-u>", "<C-u>zz", opts)

-- Yank to system clipboard
vim.keymap.set({ "n", "v" }, "<leader>y", '"+y', opts)
vim.keymap.set("n", "<leader>Y", '"+Y', opts)

-- Paste over selection without losing clipboard
vim.keymap.set("v", "p", '"_dP', opts)

-- Delete without yanking
vim.keymap.set({ "n", "v" }, "<leader>d", '"_d', opts)

-- Quickly reload config
vim.keymap.set("n", "<leader>sv", ":source $MYVIMRC<CR>", opts)

-- Keep visual selection after formatting
vim.keymap.set("v", "=", "=gv", opts)

vim.keymap.set("i", "<C-H>", "<C-w>", opts)     -- Ctrl+Backspace
vim.keymap.set("i", "<C-Del>", "<C-o>dw", opts) -- Ctrl+Delete

vim.keymap.set("n", "x", '"_x')                 -- when I delete with x it wont override my register

-- toggle git blame on the current line
vim.keymap.set("n", "<leader>gi", function()
  local gs = require("gitsigns")
  gs.current_line_blame = not gs.current_line_blame
  gs.toggle_current_line_blame()
end, { noremap = true, silent = true, desc = "Toggle Git Blame Inline" })

-- undo break points. For when I don't want to undo all my new text
vim.keymap.set("i", ",", ",<C-g>u", opts)
vim.keymap.set("i", ".", ".<C-g>u", opts)
vim.keymap.set("i", "!", "!<C-g>u", opts)
vim.keymap.set("i", "?", "?<C-g>u", opts)

-- deletes the visual selection and pastes from my clipboard
vim.keymap.set("v", "<leader>p", '"_dP', opts) -- the clipboard wont be overwritten with the deleted text

-- Lazyvim seems to do this by default!
-- center the screen when I am moving to next and prev (also opens folds)
-- vim.keymap.set("n", "n", "nzzzv", opts) -- center on pressing n
-- vim.keymap.set("n", "N", "Nzzzv", opts) -- center on pressing N
