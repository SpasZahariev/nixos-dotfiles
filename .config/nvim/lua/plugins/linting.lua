return {
	-- linting for my files. I love seeing red <3
	"mfussenegger/nvim-lint",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		local lint = require("lint")

		lint.linters_by_ft = {
			javascript = { "eslint_d" },
			typescript = { "eslint_d" },
			javascriptreact = { "eslint_d" },
			typescriptreact = { "eslint_d" },
			python = { "pylint" },
			-- java = { "sonarlint-language-server" },
		}

		local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })

		-- we are creating an auto command and it gets executed every time we enter File or write to it
		vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
			group = lint_augroup,
			callback = function()
				lint.try_lint()
			end,
		})

		-- TRIGGERS linting manually
		-- vim.keymap.set("n", "<leader>l", function()
		-- 	lint.try_lint()
		-- end, { desc = "Trigger linting for current file" })
	end,
	enabled = false, --disable for now to see if my java linter handles itself nicely
}
