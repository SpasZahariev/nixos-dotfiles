local M = {
	"hrsh7th/nvim-cmp",
	event = "InsertEnter",
	dependencies = {
		"hrsh7th/cmp-nvim-lsp",
		"hrsh7th/cmp-nvim-lua",
		"hrsh7th/cmp-buffer",
		"hrsh7th/cmp-path",
		"hrsh7th/cmp-cmdline",
		"saadparwaiz1/cmp_luasnip",
		"L3MON4D3/LuaSnip",
		"rafamadriz/friendly-snippets", -- useful snippets for many languages
		"onsails/lspkind.nvim", -- pictograms like in vscode
	},
}

M.config = function()
	-- code completion and suggestions
	local cmp = require("cmp")

	local luasnip = require("luasnip")

	local lspkind = require("lspkind")
	-- loads vscode style snippets from installed plugins
	require("luasnip.loaders.from_vscode").lazy_load()

	cmp.setup({
		completion = {
			-- completeopt = "menu,menuone,preview,noselect",
			completeopt = "menu,menuone,preview",
			-- autocomplete = true, -- enables autocompletion as I type
		},
		preselect = cmp.PreselectMode.Item, -- automatically select first item
		snippet = {
			expand = function(args)
				luasnip.lsp_expand(args.body) -- For `luasnip` users.
			end,
		},
		experimental = {
			ghost_text = true,
		},
		window = {
			-- completion = cmp.config.window.bordered(),
			-- documentation = cmp.config.window.bordered(),
		},
		mapping = cmp.mapping.preset.insert({
			["<C-k>"] = cmp.mapping.select_prev_item(),
			["<C-j>"] = cmp.mapping.select_next_item(),
			["<C-b>"] = cmp.mapping.scroll_docs(-4),
			["<C-f>"] = cmp.mapping.scroll_docs(4),
			-- ["<C-Space>"] = cmp.mapping.complete(),
			["<A-CR>"] = cmp.mapping.complete(),
			["<C-e>"] = cmp.mapping.abort(),
			["<CR>"] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
		}),
		-- sources for autocompletion
		sources = cmp.config.sources({
			{ name = "codeium" }, -- set it first let's see
			{ name = "nvim_lsp" },
			{ name = "nvim_lua" },
			{ name = "luasnip" }, -- For luasnip users.
			{ name = "buffer" }, --text iwthin current buffer
			{ name = "path" }, -- file system paths
			-- { name = "orgmode" },
		}),
		-- configures lspkind for vs-code like pictograms in completion menu
		formatting = {
			format = lspkind.cmp_format({
				maxwidth = 50,
				ellipsis_char = "...",
			}),
		},
	})
end

return M
