return {
	-- Language server and Mason LSP package manager setup
	"VonHeikemen/lsp-zero.nvim",
	branch = "v3.x",
	dependencies = {
		"neovim/nvim-lspconfig",
		"hrsh7th/cmp-nvim-lsp",
		"hrsh7th/nvim-cmp",
		"L3MON4D3/LuaSnip",
		"williamboman/mason.nvim",
		"williamboman/mason-lspconfig.nvim",
		"WhoIsSethDaniel/mason-tool-installer.nvim",
	},
	config = function()
		local lsp_zero = require("lsp-zero")

		lsp_zero.on_attach(function(client, bufnr)
			-- see :help lsp-zero-keybindings
			-- to learn the available actions
			local opts = { buffer = bufnr, remap = false }

			vim.keymap.set("n", "gd", function()
				vim.lsp.buf.definition()
			end, opts)
			vim.keymap.set("n", "K", function()
				vim.lsp.buf.hover()
			end, opts)
			vim.keymap.set("n", "<leader>vd", function()
				vim.diagnostic.open_float()
			end, opts)
			vim.keymap.set("n", "[d", function()
				vim.diagnostic.goto_next()
			end, opts)
			vim.keymap.set("n", "]d", function()
				vim.diagnostic.goto_prev()
			end, opts)
			vim.keymap.set("n", "<leader>vrn", function()
				vim.lsp.buf.rename()
			end, opts)
			-- this is Ctrl + Alt + o
			vim.keymap.set("n", "<C-M-o>", function()
				vim.lsp.buf.organize_imports()
			end, opts)
			vim.keymap.set("i", "<C-h>", function()
				vim.lsp.buf.signature_help()
			end, opts)

			local telescope_builtin = require("telescope.builtin")
			vim.keymap.set("n", "<leader>fr", telescope_builtin.lsp_references, opts)
			vim.keymap.set("n", "<leader>fs", telescope_builtin.lsp_workspace_symbols, opts)
			vim.keymap.set("n", "<leader>fd", telescope_builtin.lsp_document_symbols, opts)
			vim.keymap.set("n", "<leader>fa", vim.lsp.buf.code_action, opts)
			vim.keymap.set("n", "<leader>fi", telescope_builtin.lsp_implementations, opts)
			vim.keymap.set("n", "<leader>fd", telescope_builtin.lsp_definitions, opts)
		end)

		-- Language servers!
		require("mason").setup({})
		require("mason-lspconfig").setup({
			handlers = {
				function(server_name)
					if server_name == "jdtls" then -- I don't want to start up the default jdtls here
						return
					end
					require("lspconfig")[server_name].setup({})
				end,
			},
		})
		local mason_tool_installer = require("mason-tool-installer")
		mason_tool_installer.setup({
			ensure_installed = {
				"prettier", -- prettier formatter
				"black", -- python formatter
				"isort", -- python formatter
				"stylua", -- lua formatter
				"google-java-format", -- java formatter
				"pylint", -- python linter
				"eslint_d", -- javascript linter
			},
		})
	end,
}
