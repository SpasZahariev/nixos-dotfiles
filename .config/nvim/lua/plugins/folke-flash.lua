-- disable these jump plugins inside lazyvim
return {
  {
    "folke/flash.nvim", -- or whichever jump plugin provides S
    enabled = false,
    opts = {
      -- disable default mappings
      modes = { search = false },
    },
  },
}
