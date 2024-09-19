return {
	"mbbill/undotree",
	config = function()
		vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle, {})
	end,
	enabled = false, -- Disable this plugin for now. Going to try telescope undo instead
}
