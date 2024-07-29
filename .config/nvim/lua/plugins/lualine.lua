return {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    opts = {
			theme = "catppuccin",
			options = {
				component_separators = " ",
				section_separators = { left = "", right = "" },
			},
		},
    --[[
    config = function()
        local line = require("lualine")
        line.setup()
        line.setup({
            options = {
                theme = "catppuccin",
                flavour = "latte",
            }
        }) ]]--


--    end
}
