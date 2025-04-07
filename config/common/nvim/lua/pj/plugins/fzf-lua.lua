-- Fuzzy Finder (files, lsp, etc)
return {
  "ibhagwan/fzf-lua",
  event = "VimEnter",
  dependencies = {
    "nvim-tree/nvim-web-devicons",
  },
  config = function()
    -- Setup fzf-lua
    require("fzf-lua").setup({
      -- Default options for all fzf-lua commands
      defaults = {
        -- Default options for all commands
        winopts = {
          -- Window options
          height = 0.8,
          width = 0.8,
          preview = {
            hidden = "hidden", -- Hide preview window
            vertical = "up:45%", -- Vertical split
            horizontal = "right:50%", -- Horizontal split
            layout = "vertical", -- Vertical or horizontal
            title = true, -- Show title
          },
        },
        -- Default options for all commands
        actions = {
          -- Default actions
          ["default"] = require("fzf-lua.actions").file_edit,
          ["ctrl-s"] = require("fzf-lua.actions").file_split,
          ["ctrl-v"] = require("fzf-lua.actions").file_vsplit,
          ["ctrl-t"] = require("fzf-lua.actions").file_tabedit,
          ["alt-q"] = require("fzf-lua.actions").file_sel_to_qf,
          ["alt-c"] = require("fzf-lua.actions").file_sel_to_cc,
        },
      },
      -- Global options for all commands
      global_git_icons = true,
      global_file_icons = true,
      global_color_icons = true,
      -- Global options for all commands
      global_resume = true,
      -- Global options for all commands
      global_resume_query = true,
      -- Global options for all commands
      global_working_dir_opts = {
        -- Global options for all commands
        cwd_mode = "global", -- Global or local
        cwd_path = vim.fn.expand("~"), -- Default path
      },
    })

    -- Keymaps
    local fzf = require("fzf-lua")
    
    -- Search files
    vim.keymap.set("n", "<leader>sf", function() fzf.files() end, { desc = "[S]earch [F]iles" })
    
    -- Search help tags
    vim.keymap.set("n", "<leader>sh", function() fzf.help_tags() end, { desc = "[S]earch [H]elp" })
    
    -- Search keymaps
    vim.keymap.set("n", "<leader>sk", function() fzf.keymaps() end, { desc = "[S]earch [K]eymaps" })
    
    -- Search buffers
    vim.keymap.set("n", "<leader><leader>", function() fzf.buffers() end, { desc = "[ ] Find existing buffers" })
    
    -- Search grep
    vim.keymap.set("n", "<leader>sg", function() fzf.live_grep() end, { desc = "[S]earch by [G]rep" })
    
    -- Search grep string
    vim.keymap.set("n", "<leader>sw", function() fzf.grep_cword() end, { desc = "[S]earch current [W]ord" })
    
    -- Search diagnostics
    vim.keymap.set("n", "<leader>sd", function() fzf.diagnostics_document() end, { desc = "[S]earch [D]iagnostics" })
    
    -- Search oldfiles
    vim.keymap.set("n", "<leader>s.", function() fzf.oldfiles() end, { desc = '[S]earch Recent Files ("." for repeat)' })
    
    -- Search in current buffer
    vim.keymap.set("n", "<leader>/", function() fzf.lines() end, { desc = "[/] Fuzzily search in current buffer" })
    
    -- Search in open files
    vim.keymap.set("n", "<leader>s/", function() fzf.live_grep_glob() end, { desc = "[S]earch [/] in Open Files" })
    
    -- Search Neovim files
    vim.keymap.set("n", "<leader>sn", function() 
      fzf.files({ cwd = vim.fn.stdpath("config") }) 
    end, { desc = "[S]earch [N]eovim files" })
    
    -- Search select fzf-lua
    vim.keymap.set("n", "<leader>ss", function() fzf.builtin() end, { desc = "[S]earch [S]elect fzf-lua" })
  end,
} 