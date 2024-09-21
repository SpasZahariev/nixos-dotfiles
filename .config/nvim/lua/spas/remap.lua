local keymap = vim.keymap -- for conciseness

-- general keymaps

keymap.set("n", "<CR>", ":nohl<CR>") -- removes highlights when I press enter

keymap.set("n", "x", '"_x') -- when I delete with x it wont override my register

-- window management
keymap.set("n", "<leader>pv", vim.cmd.Ex) -- does the :Ex command so I can look at the dir tree

-- 3 keymaps for splitting vertically so I don't bother with shift
keymap.set("n", "<leader>sv", "<C-w>v") -- split window vertically
keymap.set("n", "<leader>|", "<C-w>v") -- split window vertically
keymap.set("n", "<leader>\\", "<C-w>v") -- split window vertically

-- 3 keymaps for splitting horizontally
keymap.set("n", "<leader>sh", "<C-w>s") -- split window horizontally
keymap.set("n", "<leader>-", "<C-w>s") -- split window horizontally
keymap.set("n", "<leader>_", "<C-w>s") -- split window horizontally

keymap.set("n", "<leader>se", "<C-w>=") -- make split windows equal width & height
keymap.set("n", "<leader>sx", ":close<CR>") -- close current split window

keymap.set("n", "<leader>to", ":tabnew<CR>") -- open new tab
keymap.set("n", "<leader>tx", ":tabclose<CR>") -- close current tab
keymap.set("n", "<leader>tn", ":tabn<CR>") --  go to next tab
keymap.set("n", "<leader>tp", ":tabp<CR>") --  go to previous tab

----------------------
-- Plugin Keybinds
----------------------

-- vim-maximizer
keymap.set("n", "<leader>sm", ":MaximizerToggle<CR>") -- toggle split window maximization

-- nvim-tree
--keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>") -- toggle file explorer

-- restart lsp server (not on youtube nvim video)
keymap.set("n", "<leader>rs", ":LspRestart<CR>") -- mapping to restart lsp if necessary

-- delete word with ctrl+backspace in insert mode. Should be super normal but vim sees this weird ^H character
-- keymap.set("i", "", "<C-w>")
-- above one didn't work on nvim + alacritty + tmux so I'm doing this again -> works as of 19.09.2024
keymap.set("i", "<c-bs>", "<C-W>", { noremap = true, silent = true })

-- keymap.set("i", "<c-backspace>", "<c-w>")
-- keymap.set("n", "<c-backspace>", "dw")

-- try formatting the document
-- 19.09.2024: I AM FORMATTING on SAVE now
-- keymap.set("n", "<leader>fd", "<cmd>lua vim.lsp.buf.format{async = true}<CR>")
-- keymap.set("n", "<leader>f", function()
-- 	vim.lsp.buf.format()
-- end)

-- vim does not recognize the Alt character -> it basically appears as ^[

-- Alt + l to format file
keymap.set("n", "^[l", "<M-l>") -- workaround set Alt + L to trigger MetaKey + l. Metakey + l will trigger the formatting
keymap.set("n", "<M-l>", "<cmd>lua vim.lsp.buf.format{async = true}<CR>")

-- it already works but just to be explicit
keymap.set("i", "<C-c>", "<Esc>")
keymap.set("v", "<C-c>", "<Esc>")

-- Primagen remaps:

-- center the screen when I am moving to next and prev (also opens folds)
keymap.set("n", "n", "nzzzv") -- center on pressing n
keymap.set("n", "N", "Nzzzv") -- center on pressing N

-- center screen when moving with C-d and C-u
keymap.set("n", "<C-d>", "<C-d>zz")
keymap.set("n", "<C-u>", "<C-u>zz")

-- will inline. Puts the next life of code at the end of my current line.
keymap.set("n", "J", "mzJ`z") -- mzj`z is to keep the cursor in the same spot. By default the cursor moves

keymap.set("n", "Y", "y$") -- make Y copy until the end of the line
keymap.set("v", "Y", "y$") -- make Y copy until the end of the line

-- move lines  up and down and tries to indent them correctly
keymap.set("n", "<C-S-Down>", ":m.+1<CR>==") -- moves the current line one line down
-- keymap.set("n", "<leader>j", ":m.+1<CR>==") -- moves the current line one line down
keymap.set("n", "<C-S-Up>", ":m.-2<CR>==") -- moves the current line one line above
-- keymap.set("n", "<leader>k", ":m.-2<CR>==") -- moves the current line one line above

-- move SELECTION up and down and reformat it
keymap.set("v", "<leader>j", ":m'>+1<CR>gv=gv") -- tries to move, reformat, reselect
keymap.set("v", "<leader>k", ":m'>-2<CR>gv=gv") -- tries to move, reformat, reselect

-- undo break points. For when I don't want to undo all my new text
keymap.set("i", ",", ",<C-g>u")
keymap.set("i", ".", ".<C-g>u")
keymap.set("i", "!", "!<C-g>u")
keymap.set("i", "?", "?<C-g>u")

-- deletes the visual selection and pastes from my clipboard
keymap.set("v", "<leader>p", '"_dP') -- the clipboard wont be overwritten with the deleted text

-- indenting in visual mode stays in visual mode
keymap.set("v", ">", ">gv")
keymap.set("v", "<", "<gv")

-- copy my selection and duplicate it underneath
keymap.set("v", "<C-p>", "y'>o<Esc>p") -- also adds one space between the duplicates

-- start replacing the current word I am on and any other occurance
keymap.set("n", "<leader>s", ":%s/\\<<C-r><C-w>\\>/<C-r><C-w>/gI<Left><Left><Left>")
