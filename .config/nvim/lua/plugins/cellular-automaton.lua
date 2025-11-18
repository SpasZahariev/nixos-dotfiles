-- some fun animations
return {
  "Eandrju/cellular-automaton.nvim",
  event = "VeryLazy", -- load the pluggin after neovim ui and other normal events
  keys = {
    {
      "<leader>fung",
      "<cmd>CellularAutomaton game_of_life<CR>",
      desc = "Game of Life",
    },
    {
      "<leader>funm",
      "<cmd>CellularAutomaton make_it_rain<CR>",
      desc = "Make It Rain",
    },
  },
}
