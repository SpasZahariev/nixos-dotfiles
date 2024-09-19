return {
    -- operations on surrounding {} "" ''
    -- ysiw" to surround inside word with ""
    -- ys$" to surround until the end of the line with ""
    -- ystX" to surround until the X character with ""
    -- ds" to delete the surrounding ""
    -- cs"[ to change the surrounding "" with []

    "kylechui/nvim-surround",
    event = { "BufReadPre", "BufNewFile" },
    version = "*", -- Use for stability; omit to use `main` branch for the latest features
    config = true, -- this is the same as writing the below code
    -- config = function()
    --     require("nvim-surround").setup({
    --         -- Configuration here, or leave empty to use defaults
    --     })
    -- end
}
