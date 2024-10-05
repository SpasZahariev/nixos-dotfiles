local opt = vim.opt -- shorthand for conciseness

-- line numbers
opt.relativenumber = true
opt.number = true

-- tabs & indentation
opt.tabstop = 2
opt.softtabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.autoindent = true

opt.smartindent = true

-- line wrapping inst always nice
opt.wrap = false

-- search settings
opt.ignorecase = true
opt.smartcase = true
--opt.hlsearch = false
--opt.incsearch = true

-- appearance
opt.termguicolors = true
opt.background = "dark"
opt.signcolumn = "yes"

-- make backspace work properly
opt.backspace = "indent,eol,start"

-- use system clipboard
opt.clipboard:append("unnamedplus")

vim.g.clipboard = {
	name = "myClipboard",
	copy = {
		["+"] = "copyq add -",
		["*"] = "copyq add -",
	},
	paste = {
		["+"] = "copyq read 0",
		["*"] = "copyq read 0",
	},
	cache_enabled = true,
}

-- split windows
opt.splitright = true -- split vertical window to the right
opt.splitbelow = true -- split horizontal window to the bottom

-- will make - not to be a word separator
opt.iskeyword:append("-")

-- all important schrolloff near the top and bottom
opt.scrolloff = 8

-- converts tabs to spaces
opt.smarttab = true

-- we don't need to see -- INSERT -- anymore. I see it in the lualine statusbar
opt.showmode = false

-- more space for seeing messages
-- opt.cmdheight = 2

-- try formatting on save
-- vim.cmd [autocmd BufWritePre *.go lua vim.lsp.buf.formatting()]

-- faster updates
opt.updatetime = 50

-- column after 80 chars
--opt.colorcolumn = "80"
