-- adds overrides on top of the defaults that Lazyvim comes with
return {
  "nvim-telescope/telescope.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  opts = function(_, opts)
    return opts
  end,
}
-- return {
--   opts = {
--     defaults = {
--       -- Default path where Telescope starts searching
--       cwd = function()
--         -- Try to use Git root if available, else use current working dir
--         local git_root = vim.fn.systemlist("git rev-parse --show-toplevel")[1]
--         if vim.v.shell_error == 0 and git_root ~= "" then
--           return git_root
--         else
--           return vim.fn.getcwd()
--         end
--       end,
--
--       -- Layout settings
--       layout_strategy = "horizontal", -- horizontal split
--       layout_config = {
--         prompt_position = "top", -- search prompt at top
--         width = 0.9, -- 90% of screen width
--         height = 0.85, -- 85% of screen height
--       },
--
--       -- Ignore some common files/folders
--       file_ignore_patterns = { "node_modules", ".git/", "dist" },
--
--       -- Sort files and results
--       sorting_strategy = "ascending",
--       prompt_prefix = "🔍 ", -- fancy search icon
--
--     },
--   },
--
--   -- Optional keymaps for project search
--   keys = {},
-- }
