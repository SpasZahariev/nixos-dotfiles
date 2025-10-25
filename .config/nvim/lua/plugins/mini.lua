return {
  {
    "nvim-mini/mini.ai", -- adds moveminets Inside and Around stuff
    version = false, -- latest unstable changes here we go!
    event = "VeryLazy", -- neovim thing. Will load the plugin after everything is ready
    config = function()
      require("mini.ai").setup({
        n_lines = 500, -- how many lines above and bellow mini.ai will search for
      })
    end,
  },

  {
    "nvim-mini/mini.surround", -- better surround than tpopes
    version = false,
    event = "VeryLazy",
    config = function()
      require("mini.surround").setup()
    end,
  },

  {
    "nvim-mini/mini.files",
    version = false,
    event = "VeryLazy",
    config = function()
      local mini_files = require("mini.files")
      mini_files.setup({
        windows = {
          preview = true, -- show file preview on the right
          width_focus = 30,
          width_preview = 60,
        },
        -- options = {
        --   use_as_default_explorer = true,
        -- },
      })

      -- Keymap to toggle MiniFiles in the current directory
      vim.keymap.set("n", "<leader>E", function()
        require("mini.files").open(vim.api.nvim_buf_get_name(0))
      end, { desc = "Open Mini Files (file explorer)" })
    end,
  },
}
