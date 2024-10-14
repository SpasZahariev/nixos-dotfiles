local M = {
	"nvim-treesitter/nvim-treesitter",
	build = function()
		require("nvim-treesitter.install").update({ with_sync = true })()
	end,
	config = function()
		local configs = require("nvim-treesitter.configs")

		-- important for correct coloring, after I add an lsp in Mason
		configs.setup({
			ensure_installed = {
				"lua",
				"vim",
				"vimdoc",
				"javascript",
				"html",
				"rust",
				"go",
				"java",
				"terraform",
				"templ",
			},
			sync_install = false,
			highlight = { enable = true },
			indent = { enable = true },
		})
	end,
}

return { M }
