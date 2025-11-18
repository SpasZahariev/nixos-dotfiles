return {
  "ThePrimeagen/harpoon",
  branch = "harpoon2",
  opts = {
    menu = {
      width = vim.api.nvim_win_get_width(0) - 4,
    },
    settings = {
      save_on_toggle = true,
    },
  },
  keys = function()
    local keys = {
      {
        "<leader>H",
        function()
          require("harpoon"):list():add()
        end,
        desc = "Harpoon File",
      },
      -- dont need the harpoon menu since we have telescope harpoon2 integration with <leader>fh
      -- {
      --   "<leader>h",
      --   function()
      --     local harpoon = require("harpoon")
      --     harpoon.ui:toggle_quick_menu(harpoon:list())
      --   end,
      --   desc = "Harpoon Quick Menu",
      -- },
      vim.keymap.set("n", "<leader>hc", function()
        require("harpoon"):list():clear()
      end, { desc = "Harpoon: Clear all marks" }),
    }

    for i = 1, 9 do
      table.insert(keys, {
        "<leader>" .. i,
        function()
          require("harpoon"):list():select(i)
        end,
        desc = "Harpoon to File " .. i,
      })
    end
    return keys
  end,
}
