-- extends the default Lazyvim config. Specifically the formatters_by_ft method inside is extended
return {
  {
    -- for formatting files with different formatters
    "stevearc/conform.nvim",
    opts = function(_, opts)
      opts.formatters_by_ft = vim.tbl_deep_extend("force", opts.formatters_by_ft or {}, {
        python = { "ruff_fix", "ruff_format" },
      })
    end,
  },
}
