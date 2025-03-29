return {
  -- `lazydev` configures Lua LSP for Neovim config, runtime and plugins
  -- used for completion, annotations and signatures of Neovim apis
  "folke/lazydev.nvim",
  ft = "lua",
  opts = {
    library = {
      { path = "luvit-meta/library", words = { "vim%.uv" } },
    },
  },
  dependencies = {
    { "Bilal2453/luvit-meta", lazy = true },
  },
} 