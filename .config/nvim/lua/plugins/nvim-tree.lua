-- adds overrides on top of the defaults that Lazyvim comes with
return {
  "nvim-tree/nvim-tree.lua",
  opts = function(_, opts)
    -- Merge with LazyVim defaults
    opts.filters = opts.filters or {}
    opts.filters.dotfiles = false -- show dotfiles

    opts.git = opts.git or {}
    opts.git.ignore = false -- show git-ignored files

    return opts
  end,
}
