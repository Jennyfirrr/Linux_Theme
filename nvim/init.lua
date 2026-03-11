-- =========================
-- Neovim Starter (minimal but powerful)
-- Leader = Space, plugin manager = lazy.nvim
-- =========================

-- Leader
vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.python3_host_prog = vim.fn.expand("~/.venvs/nvim/bin/python")

-- Basics
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.termguicolors = true
vim.opt.signcolumn = "yes"
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.updatetime = 250
vim.opt.scrolloff = 8
vim.opt.clipboard = "unnamedplus"

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

local plugins = {
  {
    "folke/tokyonight.nvim",
    priority = 1000,
    opts = {
      style = "storm",
      terminal_colors = true,
      transparent = false,
      styles = {
        comments = { italic = false },
        keywords = { bold = true },
        functions = { bold = true },
      },
      on_colors = function(c)
        -- Fox ML palette
        c.bg          = "#1a1214"
        c.bg_dark     = "#150f0f"
        c.bg_float    = "#1a1214"
        c.bg_popup    = "#1a1214"
        c.bg_sidebar  = "#150f0f"
        c.bg_highlight = "#2d1f27"
        c.fg          = "#f5f5f7"
        c.fg_dark     = "#f4b58a"
        c.fg_gutter   = "#3a414b"
        c.comment     = "#5a6270"
        c.border      = "#f4b58a"
        -- Syntax mapping
        c.blue    = "#f4b58a"   -- functions → peach
        c.cyan    = "#8bd5a2"   -- types/builtins → mint
        c.green   = "#8bd5a2"   -- strings → mint
        c.magenta = "#f5a9b8"   -- keywords → pink
        c.orange  = "#f4b58a"   -- constants → peach
        c.purple  = "#f5a9b8"   -- operators → pink
        c.red     = "#ff6b6b"   -- errors → red
        c.yellow  = "#f9e2af"   -- warnings → warm yellow
        c.teal    = "#89dceb"   -- info/hints → soft cyan
      end,
      on_highlights = function(hl, c)
        hl.CursorLine    = { bg = "#2d1f27" }
        hl.Visual        = { bg = "#4d2f34", blend = 28 }
        hl.LineNr        = { fg = "#3a414b" }
        hl.CursorLineNr  = { fg = "#f4b58a", bold = true }
        hl.Search        = { fg = "#1a1214", bg = "#f4b58a" }
        hl.IncSearch     = { fg = "#1a1214", bg = "#f5a9b8" }
        hl.MatchParen    = { fg = "#f5a9b8", bold = true, underline = true }
        hl.DiagnosticInfo = { fg = "#89dceb" }
        hl.DiagnosticHint = { fg = "#8bd5a2" }
        -- Treesitter
        hl["@function"]      = { fg = "#f4b58a" }
        hl["@function.call"] = { fg = "#f4b58a" }
        hl["@keyword"]       = { fg = "#f5a9b8", bold = true }
        hl["@string"]        = { fg = "#8bd5a2" }
        hl["@number"]        = { fg = "#f9e2af" }
        hl["@type"]          = { fg = "#f4b58a" }
        hl["@variable"]      = { fg = "#f5f5f7" }
        hl["@parameter"]     = { fg = "#f5f5f7" }
        hl["@property"]      = { fg = "#f4b58a" }
        hl["@operator"]      = { fg = "#f5a9b8" }
        hl["@punctuation"]   = { fg = "#f5f5f7" }
        hl["@comment"]       = { fg = "#5a6270", italic = true }
      end,
    },
    config = function(_, opts)
      require("tokyonight").setup(opts)
      vim.cmd.colorscheme("tokyonight")
    end
  },

  { "nvim-lualine/lualine.nvim",           dependencies = { "nvim-tree/nvim-web-devicons" } },
  { "lukas-reineke/indent-blankline.nvim", main = "ibl",                                    opts = {} },
  { "karb94/neoscroll.nvim",               event = "VeryLazy",                              opts = { easing_function = "quadratic", hide_cursor = true } },

  -- Core editing
  { "numToStr/Comment.nvim",               config = true },
  { "windwp/nvim-autopairs",               config = true },
  { "folke/which-key.nvim",                event = "VeryLazy",                              opts = {} },

  -- Fuzzy finding
  {
    "nvim-telescope/telescope.nvim",
    branch = "0.1.x",
    dependencies = { "nvim-lua/plenary.nvim", "nvim-tree/nvim-web-devicons" }
  },
  -- File explorer (choose one; this is lightweight)
  { "stevearc/oil.nvim",                opts = { default_file_explorer = true } },

  -- Git
  { "lewis6991/gitsigns.nvim",          config = true },

  -- Syntax / Treesitter
  { "nvim-treesitter/nvim-treesitter",  build = ":TSUpdate" },

  -- LSP + Autocomplete
  { "neovim/nvim-lspconfig" },
  { "williamboman/mason.nvim",          build = ":MasonUpdate" },
  { "williamboman/mason-lspconfig.nvim" },
  { "hrsh7th/nvim-cmp" },
  { "hrsh7th/cmp-nvim-lsp" },
  { "hrsh7th/cmp-buffer" },
  { "hrsh7th/cmp-path" },
  { "L3MON4D3/LuaSnip",                 build = "make install_jsregexp" },
  { "saadparwaiz1/cmp_luasnip" },
  { "echasnovski/mini.icons",           version = false },

  -- Diagnostics UI (optional but great)
  { "folke/trouble.nvim",               dependencies = { "nvim-tree/nvim-web-devicons" }, opts = {} },
  -- TODO highlights
  { "folke/todo-comments.nvim",         dependencies = { "nvim-lua/plenary.nvim" },       opts = {} },

  -- === Add to your `plugins` list ===
  {
    "coffebar/project.nvim",
    pin = true,
    opts = {
      detection_methods = { "lsp", "pattern" },
      patterns = { ".git", "compile_commands.json", "CMakeLists.txt", "Makefile" },
    },
    config = function(_, opts)
      require("project_nvim").setup(opts)
      require("telescope").load_extension("projects")
    end,
  },

  { "stevearc/overseer.nvim",  opts = {} },
  { "akinsho/toggleterm.nvim", opts = {} },

  {
    "Civitasv/cmake-tools.nvim",
    dependencies = { "nvim-lua/plenary.nvim", "stevearc/overseer.nvim", "akinsho/toggleterm.nvim" },
    opts = {
      cmake_use_preset = true,
      cmake_regenerate_on_save = true,
      cmake_generate_options = { "-DCMAKE_EXPORT_COMPILE_COMMANDS=1" },
      cmake_compile_commands_options = { action = "soft_link", target = vim.loop.cwd() },
      -- preset DAP integration (we'll install codelldb via Mason)
      cmake_dap_configuration = { name = "cpp", type = "codelldb", request = "launch", runInTerminal = true },
    },
  },

  { "mfussenegger/nvim-dap" },
  { "nvim-neotest/nvim-nio" },
  {
    "rcarriga/nvim-dap-ui",
    dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },
    config = function()
      local dap, dapui = require("dap"), require("dapui")
      dapui.setup()
      dap.listeners.after.event_initialized["dapui"] = function() dapui.open() end
      dap.listeners.before.event_terminated["dapui"] = function() dapui.close() end
      dap.listeners.before.event_exited["dapui"] = function() dapui.close() end
    end,
  },
  {
    "jay-babu/mason-nvim-dap.nvim",
    opts = {
      automatic_installation = true,
      ensure_installed = { "codelldb" },
    },
  },

  {
    "stevearc/conform.nvim",
    opts = {
      format_on_save = { lsp_fallback = true, timeout_ms = 500 },
      formatters_by_ft = { c = { "clang-format" }, cpp = { "clang-format" } },
    },
  },

  {
    "mfussenegger/nvim-lint",
    config = function()
      local lint = require("lint")
      lint.linters_by_ft = { c = { "clangtidy" }, cpp = { "clangtidy" } }
      vim.api.nvim_create_autocmd({ "BufWritePost", "InsertLeave" }, {
        callback = function() require("lint").try_lint() end,
      })
    end,
  },

  -- LaTeX
  {
    "lervag/vimtex",
    lazy = false,
    init = function()
      vim.g.vimtex_view_method = "zathura"  -- change to "general" if no zathura
      vim.g.vimtex_compiler_method = "latexmk"
      vim.g.vimtex_quickfix_mode = 0  -- don't auto-open quickfix on errors
    end,
  },

  { "stevearc/aerial.nvim",                    opts = {} },
  { "nvim-treesitter/nvim-treesitter-context", opts = {} },

  -- Neotest core + C/C++ adapters (pick one adapter)
  { "nvim-neotest/neotest",                    dependencies = { "nvim-lua/plenary.nvim", "nvim-treesitter/nvim-treesitter", "nvim-neotest/nvim-nio" } },
  { "alfaix/neotest-gtest" },  -- GoogleTest
  { "orjangj/neotest-ctest" }, -- CTest (GTest/Catch2/doctest)

  -- Treesitter textobjects (daf = delete a function, vac = select a class, etc.)
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
  },

  -- Flash.nvim (jump anywhere with s + 2 chars)
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {},
    keys = {
      { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
      { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
    },
  },

  -- Surround (ysiw" to wrap word in quotes, cs"' to change, ds" to delete)
  { "kylechui/nvim-surround", version = "*", event = "VeryLazy", opts = {} },

  -- Harpoon (bookmark files, jump with Ctrl+1-4)
  {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local harpoon = require("harpoon")
      harpoon:setup()
    end,
  },

  -- Undotree (visual undo history)
  { "mbbill/undotree" },

  -- DAP virtual text (inline variable values while debugging)
  {
    "theHamsta/nvim-dap-virtual-text",
    dependencies = { "mfussenegger/nvim-dap", "nvim-treesitter/nvim-treesitter" },
    opts = {},
  },

  -- Fidget (LSP progress spinner)
  { "j-hui/fidget.nvim", opts = {} },

  -- Diffview (full git diff/merge viewer)
  { "sindrets/diffview.nvim", dependencies = { "nvim-lua/plenary.nvim" } },

  -- === AI ===

  -- Copilot (inline ghost-text completions)
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    lazy = false,
    opts = {
      suggestion = {
        enabled = true,
        auto_trigger = true,
        keymap = {
          accept = "<C-l>",       -- Ctrl+l to accept
          accept_word = "<C-;>",  -- Ctrl+; to accept word
          accept_line = "<C-'>",  -- Ctrl+' to accept line
          next = "<C-]>",
          prev = "<C-k>",
          dismiss = "<C-j>",
        },
      },
      panel = { enabled = false },
      filetypes = {
        markdown = true,
        ["."] = false,
      },
    },
  },

  -- Avante (Cursor-style AI panel, using Copilot provider)
  {
    "yetone/avante.nvim",
    event = "VeryLazy",
    version = false,
    build = "make",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "stevearc/dressing.nvim",
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "zbirenbaum/copilot.lua",
    },
    opts = {
      provider = "copilot",
      providers = {
        copilot = {
          model = "claude-sonnet-4",
        },
      },
      behaviour = {
        auto_suggestions = false,
        auto_set_keymaps = true,
      },
      windows = {
        width = 30,
        sidebar_header = {
          rounded = true,
        },
      },
    },
  },
  { "stevearc/dressing.nvim", opts = {} },
  { "MunifTanjim/nui.nvim" },

  -- === New plugins ===

  -- Noice (floating cmdline, messages, notifications)
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = { "MunifTanjim/nui.nvim" },
    opts = {
      cmdline = {
        view = "cmdline_popup",
        format = {
          cmdline = { icon = " " },
          search_down = { icon = " " },
          search_up = { icon = " " },
        },
      },
      messages = { view_search = false },
      lsp = {
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
          ["cmp.entry.get_documentation"] = true,
        },
        hover = { enabled = true },
        signature = { enabled = true },
      },
      presets = {
        bottom_search = false,
        command_palette = true,
        long_message_to_split = true,
        lsp_doc_border = true,
      },
    },
  },

  -- mini.ai (enhanced text objects)
  {
    "echasnovski/mini.ai",
    event = "VeryLazy",
    opts = { n_lines = 500 },
  },

  -- Snacks (dashboard, notifications, terminal utilities)
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    opts = {
      dashboard = {
        enabled = true,
        preset = {
          header = [[
   ____            __  __ _
  |  __| _____  _|  \/  | |
  | |__ / _ \ \/ / |\/| | |
  |  __| (_) >  <| |  | | |___
  |_|   \___/_/\_\_|  |_|_____|
          ]],
          keys = {
            { icon = " ", key = "f", desc = "Find File", action = ":Telescope find_files" },
            { icon = " ", key = "g", desc = "Find Text", action = ":Telescope live_grep" },
            { icon = " ", key = "r", desc = "Recent Files", action = ":Telescope oldfiles" },
            { icon = " ", key = "p", desc = "Projects", action = function() require("telescope").extensions.projects.projects({}) end },
            { icon = " ", key = "s", desc = "Restore Session", action = function() require("persistence").load() end },
            { icon = "󰒲 ", key = "l", desc = "Lazy", action = ":Lazy" },
            { icon = " ", key = "q", desc = "Quit", action = ":qa" },
          },
        },
      },
      notifier = {
        enabled = true,
        style = "compact",
      },
      indent = { enabled = false }, -- already using indent-blankline
    },
  },

  -- Dropbar (breadcrumb navigation)
  {
    "Bekaboo/dropbar.nvim",
    event = { "BufReadPost", "BufNewFile" },
  },

  -- Clangd extensions (inlay hints, AST, type hierarchy for C++)
  {
    "p00f/clangd_extensions.nvim",
    ft = { "c", "cpp" },
    opts = {
      inlay_hints = {
        inline = true,
        only_current_line = false,
        show_parameter_hints = true,
        parameter_hints_prefix = "← ",
        other_hints_prefix = "→ ",
        highlight = "Comment",
      },
      ast = {
        role_icons = {
          type = "",
          declaration = "",
          expression = "",
          specifier = "",
          statement = "",
          ["template argument"] = "",
        },
      },
    },
  },

  -- Friendly snippets (community snippet collection for LuaSnip)
  {
    "rafamadriz/friendly-snippets",
    config = function()
      require("luasnip.loaders.from_vscode").lazy_load()
    end,
  },

  -- Zen mode (distraction-free writing, great for LaTeX)
  {
    "folke/zen-mode.nvim",
    cmd = "ZenMode",
    opts = {
      window = {
        backdrop = 0.93,
        width = 100,
        options = { signcolumn = "no", number = false, relativenumber = false },
      },
    },
  },

  -- === Quality of Life ===

  -- Lazygit (full git TUI inside nvim)
  {
    "kdheepak/lazygit.nvim",
    cmd = { "LazyGit", "LazyGitConfig", "LazyGitCurrentFile" },
    dependencies = { "nvim-lua/plenary.nvim" },
  },

  -- Persistence (auto session save/restore)
  {
    "folke/persistence.nvim",
    event = "BufReadPre",
    opts = {},
  },

  -- Spectre (project-wide find and replace)
  {
    "nvim-pack/nvim-spectre",
    dependencies = { "nvim-lua/plenary.nvim" },
  },

}

-- lazy.nvim setup
require("lazy").setup(plugins, {
  rocks = { enabled = false },
})

-- Neotest setup (pick ONE adapter)
local neotest = require("neotest")
neotest.setup({
  adapters = {
    require("neotest-gtest").setup({}),
    -- OR, if you prefer CTest as the runner:
    -- require("neotest-ctest").setup({}),
  },
})

-- setup optional
vim.opt.signcolumn = "yes:1"
vim.opt.fillchars:append({ eob = " " })

-- Semi-transparent windows (2B aesthetic)
vim.opt.winblend = 15
vim.opt.pumblend = 15

-- Transparent background (let kitty/tmux handle it)
vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
vim.api.nvim_set_hl(0, "NormalFloat", { bg = "#1a1214" })

-- Unified rounded borders for all LSP floats (hover, signature, diagnostics)
local border = "rounded"

-- Diagnostics float border
vim.diagnostic.config({
  float = { border = border },
})

-- Patch the common float helper used by LSP UIs
do
  local _open = vim.lsp.util.open_floating_preview
  function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
    opts = opts or {}
    opts.border = opts.border or border
    return _open(contents, syntax, opts, ...)
  end
end

-- Neon diagnostic icons
local icons = { Error = " ", Warn = " ", Info = " ", Hint = " " }

vim.diagnostic.config({
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = icons.Error,
      [vim.diagnostic.severity.WARN]  = icons.Warn,
      [vim.diagnostic.severity.INFO]  = icons.Info,
      [vim.diagnostic.severity.HINT]  = icons.Hint,
    },
  },
})

-- Better float window and menu highlights (neon theme)
vim.api.nvim_set_hl(0, "FloatBorder", { fg = "#f4b58a", bg = "none" })
vim.api.nvim_set_hl(0, "CmpBorder", { fg = "#f4b58a", bg = "none" })
vim.api.nvim_set_hl(0, "Pmenu", { bg = "#1a1214" })
vim.api.nvim_set_hl(0, "PmenuSel", { bg = "#3a414b" })

-- Noice/notification highlights (neon glow)
vim.api.nvim_set_hl(0, "NoiceCmdlinePopupBorder", { fg = "#f5a9b8" })
vim.api.nvim_set_hl(0, "NoiceCmdlineIcon", { fg = "#f4b58a" })
vim.api.nvim_set_hl(0, "NoiceCmdlinePopupTitle", { fg = "#f4b58a", bold = true })
vim.api.nvim_set_hl(0, "NoiceConfirmBorder", { fg = "#8bd5a2" })

-- Dropbar breadcrumb highlights
vim.api.nvim_set_hl(0, "WinBar", { fg = "#5a6270", bg = "none" })
vim.api.nvim_set_hl(0, "WinBarNC", { fg = "#3a414b", bg = "none" })

-- Telescope border glow
vim.api.nvim_set_hl(0, "TelescopeBorder", { fg = "#f4b58a" })
vim.api.nvim_set_hl(0, "TelescopePromptBorder", { fg = "#f5a9b8" })
vim.api.nvim_set_hl(0, "TelescopeResultsBorder", { fg = "#f4b58a" })
vim.api.nvim_set_hl(0, "TelescopePreviewBorder", { fg = "#8bd5a2" })
vim.api.nvim_set_hl(0, "TelescopePromptTitle", { fg = "#1a1214", bg = "#f5a9b8", bold = true })
vim.api.nvim_set_hl(0, "TelescopeResultsTitle", { fg = "#1a1214", bg = "#f4b58a", bold = true })
vim.api.nvim_set_hl(0, "TelescopePreviewTitle", { fg = "#1a1214", bg = "#8bd5a2", bold = true })

-- Snacks dashboard highlights
vim.api.nvim_set_hl(0, "SnacksDashboardHeader", { fg = "#f5a9b8", bold = true })
vim.api.nvim_set_hl(0, "SnacksDashboardKey", { fg = "#f4b58a", bold = true })
vim.api.nvim_set_hl(0, "SnacksDashboardDesc", { fg = "#f5f5f7" })
vim.api.nvim_set_hl(0, "SnacksDashboardIcon", { fg = "#8bd5a2" })
vim.api.nvim_set_hl(0, "SnacksDashboardFooter", { fg = "#5a6270", italic = true })

-- Cursorline subtle glow
vim.api.nvim_set_hl(0, "CursorLine", { bg = "#2d1f27" })
vim.api.nvim_set_hl(0, "ColorColumn", { bg = "#2d1f27" })

-- Git signs neon colors
vim.api.nvim_set_hl(0, "GitSignsAdd", { fg = "#8bd5a2" })
vim.api.nvim_set_hl(0, "GitSignsChange", { fg = "#f9e2af" })
vim.api.nvim_set_hl(0, "GitSignsDelete", { fg = "#ff6b6b" })

-- Flash.nvim
vim.api.nvim_set_hl(0, "FlashLabel", { fg = "#1a1214", bg = "#f4b58a", bold = true })
vim.api.nvim_set_hl(0, "FlashMatch", { fg = "#f5f5f7", bg = "#2d1f27" })
vim.api.nvim_set_hl(0, "FlashCurrent", { fg = "#1a1214", bg = "#f5a9b8", bold = true })
vim.api.nvim_set_hl(0, "FlashBackdrop", { fg = "#3a414b" })

-- Trouble.nvim
vim.api.nvim_set_hl(0, "TroubleNormal", { bg = "#150f0f" })
vim.api.nvim_set_hl(0, "TroubleNormalNC", { bg = "#150f0f" })
vim.api.nvim_set_hl(0, "TroubleText", { fg = "#f5f5f7" })
vim.api.nvim_set_hl(0, "TroubleCount", { fg = "#1a1214", bg = "#f4b58a", bold = true })
vim.api.nvim_set_hl(0, "TroubleFile", { fg = "#f4b58a" })
vim.api.nvim_set_hl(0, "TroubleFoldIcon", { fg = "#f5a9b8" })
vim.api.nvim_set_hl(0, "TroubleLocation", { fg = "#5a6270" })

-- Which-key
vim.api.nvim_set_hl(0, "WhichKey", { fg = "#f4b58a", bold = true })
vim.api.nvim_set_hl(0, "WhichKeyGroup", { fg = "#f5a9b8" })
vim.api.nvim_set_hl(0, "WhichKeyDesc", { fg = "#f5f5f7" })
vim.api.nvim_set_hl(0, "WhichKeySeparator", { fg = "#3a414b" })
vim.api.nvim_set_hl(0, "WhichKeyFloat", { bg = "#150f0f" })
vim.api.nvim_set_hl(0, "WhichKeyBorder", { fg = "#f4b58a" })
vim.api.nvim_set_hl(0, "WhichKeyValue", { fg = "#5a6270" })

-- Indent blankline
vim.api.nvim_set_hl(0, "IblIndent", { fg = "#2d1f27" })
vim.api.nvim_set_hl(0, "IblScope", { fg = "#f4b58a" })

-- Oil.nvim
vim.api.nvim_set_hl(0, "OilDir", { fg = "#f4b58a", bold = true })
vim.api.nvim_set_hl(0, "OilDirIcon", { fg = "#f4b58a" })
vim.api.nvim_set_hl(0, "OilLink", { fg = "#89dceb" })
vim.api.nvim_set_hl(0, "OilFile", { fg = "#f5f5f7" })

-- DAP UI
vim.api.nvim_set_hl(0, "DapUIScope", { fg = "#f4b58a", bold = true })
vim.api.nvim_set_hl(0, "DapUIType", { fg = "#f5a9b8" })
vim.api.nvim_set_hl(0, "DapUIValue", { fg = "#8bd5a2" })
vim.api.nvim_set_hl(0, "DapUIVariable", { fg = "#f5f5f7" })
vim.api.nvim_set_hl(0, "DapUIThread", { fg = "#8bd5a2" })
vim.api.nvim_set_hl(0, "DapUIStoppedThread", { fg = "#f4b58a" })
vim.api.nvim_set_hl(0, "DapUIFrameName", { fg = "#f5f5f7" })
vim.api.nvim_set_hl(0, "DapUISource", { fg = "#f5a9b8" })
vim.api.nvim_set_hl(0, "DapUIBreakpointsPath", { fg = "#f4b58a" })
vim.api.nvim_set_hl(0, "DapUIBreakpointsInfo", { fg = "#89dceb" })
vim.api.nvim_set_hl(0, "DapUIBreakpointsCurrentLine", { fg = "#8bd5a2", bold = true })
vim.api.nvim_set_hl(0, "DapUIBreakpointsLine", { fg = "#f4b58a" })
vim.api.nvim_set_hl(0, "DapUIBreakpointsDisabledLine", { fg = "#3a414b" })
vim.api.nvim_set_hl(0, "DapUIDecoration", { fg = "#f4b58a" })
vim.api.nvim_set_hl(0, "DapUIWatchesEmpty", { fg = "#3a414b" })
vim.api.nvim_set_hl(0, "DapUIWatchesValue", { fg = "#8bd5a2" })
vim.api.nvim_set_hl(0, "DapUIWatchesError", { fg = "#ff6b6b" })
vim.api.nvim_set_hl(0, "DapUIModifiedValue", { fg = "#f9e2af", bold = true })
vim.api.nvim_set_hl(0, "DapUIFloatNormal", { bg = "#150f0f" })
vim.api.nvim_set_hl(0, "DapUIFloatBorder", { fg = "#f4b58a" })

-- DAP breakpoint/stopped signs
vim.api.nvim_set_hl(0, "DapBreakpoint", { fg = "#ff6b6b" })
vim.api.nvim_set_hl(0, "DapBreakpointCondition", { fg = "#f9e2af" })
vim.api.nvim_set_hl(0, "DapLogPoint", { fg = "#89dceb" })
vim.api.nvim_set_hl(0, "DapStopped", { fg = "#8bd5a2", bg = "#2d1f27" })

-- Aerial (symbols outline)
vim.api.nvim_set_hl(0, "AerialLine", { bg = "#2d1f27" })
vim.api.nvim_set_hl(0, "AerialGuide", { fg = "#2d1f27" })
vim.api.nvim_set_hl(0, "AerialFunctionIcon", { fg = "#f4b58a" })
vim.api.nvim_set_hl(0, "AerialClassIcon", { fg = "#f5a9b8" })
vim.api.nvim_set_hl(0, "AerialVariableIcon", { fg = "#f5f5f7" })

-- Diffview
vim.api.nvim_set_hl(0, "DiffviewFilePanelTitle", { fg = "#f4b58a", bold = true })
vim.api.nvim_set_hl(0, "DiffviewFilePanelCounter", { fg = "#f5a9b8" })
vim.api.nvim_set_hl(0, "DiffviewFilePanelFileName", { fg = "#f5f5f7" })
vim.api.nvim_set_hl(0, "DiffviewNormal", { bg = "#150f0f" })
vim.api.nvim_set_hl(0, "DiffAdd", { bg = "#1a2e1a" })
vim.api.nvim_set_hl(0, "DiffChange", { bg = "#2d2a1a" })
vim.api.nvim_set_hl(0, "DiffDelete", { bg = "#2e1a1a" })
vim.api.nvim_set_hl(0, "DiffText", { bg = "#3d3a1a" })

-- Neotest
vim.api.nvim_set_hl(0, "NeotestPassed", { fg = "#8bd5a2" })
vim.api.nvim_set_hl(0, "NeotestFailed", { fg = "#ff6b6b" })
vim.api.nvim_set_hl(0, "NeotestRunning", { fg = "#f9e2af" })
vim.api.nvim_set_hl(0, "NeotestSkipped", { fg = "#5a6270" })
vim.api.nvim_set_hl(0, "NeotestNamespace", { fg = "#f5a9b8" })
vim.api.nvim_set_hl(0, "NeotestFile", { fg = "#f4b58a" })
vim.api.nvim_set_hl(0, "NeotestDir", { fg = "#f4b58a" })
vim.api.nvim_set_hl(0, "NeotestAdapterName", { fg = "#f5a9b8", bold = true })
vim.api.nvim_set_hl(0, "NeotestFocused", { bold = true, underline = true })
vim.api.nvim_set_hl(0, "NeotestIndent", { fg = "#2d1f27" })
vim.api.nvim_set_hl(0, "NeotestExpandMarker", { fg = "#3a414b" })
vim.api.nvim_set_hl(0, "NeotestWinSelect", { fg = "#f4b58a", bold = true })

-- Harpoon
vim.api.nvim_set_hl(0, "HarpoonWindow", { bg = "#150f0f" })
vim.api.nvim_set_hl(0, "HarpoonBorder", { fg = "#f4b58a" })

-- TODO comments
vim.api.nvim_set_hl(0, "TodoBgTODO", { fg = "#1a1214", bg = "#f4b58a", bold = true })
vim.api.nvim_set_hl(0, "TodoFgTODO", { fg = "#f4b58a" })
vim.api.nvim_set_hl(0, "TodoBgFIX", { fg = "#1a1214", bg = "#ff6b6b", bold = true })
vim.api.nvim_set_hl(0, "TodoFgFIX", { fg = "#ff6b6b" })
vim.api.nvim_set_hl(0, "TodoBgHACK", { fg = "#1a1214", bg = "#f9e2af", bold = true })
vim.api.nvim_set_hl(0, "TodoFgHACK", { fg = "#f9e2af" })
vim.api.nvim_set_hl(0, "TodoBgNOTE", { fg = "#1a1214", bg = "#8bd5a2", bold = true })
vim.api.nvim_set_hl(0, "TodoFgNOTE", { fg = "#8bd5a2" })
vim.api.nvim_set_hl(0, "TodoBgWARN", { fg = "#1a1214", bg = "#f9e2af", bold = true })
vim.api.nvim_set_hl(0, "TodoFgWARN", { fg = "#f9e2af" })
vim.api.nvim_set_hl(0, "TodoBgPERF", { fg = "#1a1214", bg = "#f5a9b8", bold = true })
vim.api.nvim_set_hl(0, "TodoFgPERF", { fg = "#f5a9b8" })

-- Fidget (LSP progress)
vim.api.nvim_set_hl(0, "FidgetTitle", { fg = "#f4b58a" })
vim.api.nvim_set_hl(0, "FidgetTask", { fg = "#5a6270" })

-- Treesitter context
vim.api.nvim_set_hl(0, "TreesitterContext", { bg = "#1f1519" })
vim.api.nvim_set_hl(0, "TreesitterContextLineNumber", { fg = "#f4b58a" })
vim.api.nvim_set_hl(0, "TreesitterContextBottom", { underline = true, sp = "#2d1f27" })

-- Mason
vim.api.nvim_set_hl(0, "MasonHeader", { fg = "#1a1214", bg = "#f4b58a", bold = true })
vim.api.nvim_set_hl(0, "MasonHighlight", { fg = "#f4b58a" })
vim.api.nvim_set_hl(0, "MasonHighlightBlock", { fg = "#1a1214", bg = "#f4b58a" })
vim.api.nvim_set_hl(0, "MasonHighlightBlockBold", { fg = "#1a1214", bg = "#f4b58a", bold = true })
vim.api.nvim_set_hl(0, "MasonMuted", { fg = "#5a6270" })
vim.api.nvim_set_hl(0, "MasonMutedBlock", { fg = "#1a1214", bg = "#3a414b" })

-- Lazy.nvim (plugin manager UI)
vim.api.nvim_set_hl(0, "LazyH1", { fg = "#1a1214", bg = "#f4b58a", bold = true })
vim.api.nvim_set_hl(0, "LazyH2", { fg = "#f4b58a", bold = true })
vim.api.nvim_set_hl(0, "LazyButton", { bg = "#2d1f27" })
vim.api.nvim_set_hl(0, "LazyButtonActive", { fg = "#1a1214", bg = "#f4b58a", bold = true })
vim.api.nvim_set_hl(0, "LazySpecial", { fg = "#f5a9b8" })
vim.api.nvim_set_hl(0, "LazyComment", { fg = "#5a6270" })
vim.api.nvim_set_hl(0, "LazyProgressDone", { fg = "#f4b58a" })
vim.api.nvim_set_hl(0, "LazyProgressTodo", { fg = "#3a414b" })
vim.api.nvim_set_hl(0, "LazyReasonPlugin", { fg = "#f5a9b8" })
vim.api.nvim_set_hl(0, "LazyReasonEvent", { fg = "#f9e2af" })
vim.api.nvim_set_hl(0, "LazyReasonKeys", { fg = "#89dceb" })
vim.api.nvim_set_hl(0, "LazyReasonCmd", { fg = "#8bd5a2" })

-- Copilot ghost text
vim.api.nvim_set_hl(0, "CopilotSuggestion", { fg = "#5a6270", italic = true })
vim.api.nvim_set_hl(0, "CopilotAnnotation", { fg = "#3a414b" })

-- Avante
vim.api.nvim_set_hl(0, "AvanteTitle", { fg = "#f4b58a", bold = true })
vim.api.nvim_set_hl(0, "AvanteSidebarNormal", { bg = "#150f0f" })

-- nvim-cmp item kinds
vim.api.nvim_set_hl(0, "CmpItemAbbrMatch", { fg = "#f4b58a", bold = true })
vim.api.nvim_set_hl(0, "CmpItemAbbrMatchFuzzy", { fg = "#f4b58a" })
vim.api.nvim_set_hl(0, "CmpItemAbbrDeprecated", { fg = "#3a414b", strikethrough = true })
vim.api.nvim_set_hl(0, "CmpItemKindFunction", { fg = "#f4b58a" })
vim.api.nvim_set_hl(0, "CmpItemKindMethod", { fg = "#f4b58a" })
vim.api.nvim_set_hl(0, "CmpItemKindVariable", { fg = "#f5f5f7" })
vim.api.nvim_set_hl(0, "CmpItemKindKeyword", { fg = "#f5a9b8" })
vim.api.nvim_set_hl(0, "CmpItemKindClass", { fg = "#f4b58a" })
vim.api.nvim_set_hl(0, "CmpItemKindStruct", { fg = "#f4b58a" })
vim.api.nvim_set_hl(0, "CmpItemKindInterface", { fg = "#f4b58a" })
vim.api.nvim_set_hl(0, "CmpItemKindModule", { fg = "#f5a9b8" })
vim.api.nvim_set_hl(0, "CmpItemKindProperty", { fg = "#f4b58a" })
vim.api.nvim_set_hl(0, "CmpItemKindField", { fg = "#f4b58a" })
vim.api.nvim_set_hl(0, "CmpItemKindEnum", { fg = "#f4b58a" })
vim.api.nvim_set_hl(0, "CmpItemKindEnumMember", { fg = "#89dceb" })
vim.api.nvim_set_hl(0, "CmpItemKindConstant", { fg = "#f9e2af" })
vim.api.nvim_set_hl(0, "CmpItemKindSnippet", { fg = "#8bd5a2" })
vim.api.nvim_set_hl(0, "CmpItemKindText", { fg = "#5a6270" })
vim.api.nvim_set_hl(0, "CmpItemKindFile", { fg = "#f5f5f7" })
vim.api.nvim_set_hl(0, "CmpItemKindFolder", { fg = "#f4b58a" })
vim.api.nvim_set_hl(0, "CmpItemMenu", { fg = "#5a6270", italic = true })

--
-- Lualine theme sync + noice integration
require("lualine").setup({
  options = {
    theme = "tokyonight",
    section_separators = { left = "", right = "" },
    component_separators = { left = "", right = "" },
  },
  sections = {
    lualine_a = { "mode" },
    lualine_b = { "branch", "diff", "diagnostics" },
    lualine_c = { { "filename", path = 1 } },
    lualine_x = {
      {
        function() return require("noice").api.status.mode.get() end,
        cond = function() return package.loaded["noice"] and require("noice").api.status.mode.has() end,
        color = { fg = "#f5a9b8" },
      },
      "encoding", "fileformat", "filetype",
    },
    lualine_y = { "progress" },
    lualine_z = { "location" },
  },
})

-- Treesitter
require("nvim-treesitter.configs").setup({
  ensure_installed = { "lua", "python", "c", "cpp", "bash", "json", "yaml", "markdown", "vim", "vimdoc", "java", "javadoc", "latex" },
  highlight = { enable = true },
  incremental_selection = { enable = true },
  indent = { enable = true },
  textobjects = {
    select = {
      enable = true,
      lookahead = true,
      keymaps = {
        ["af"] = "@function.outer",
        ["if"] = "@function.inner",
        ["ac"] = "@class.outer",
        ["ic"] = "@class.inner",
        ["aa"] = "@parameter.outer",
        ["ia"] = "@parameter.inner",
        ["ai"] = "@conditional.outer",
        ["ii"] = "@conditional.inner",
        ["al"] = "@loop.outer",
        ["il"] = "@loop.inner",
      },
    },
    move = {
      enable = true,
      set_jumps = true,
      goto_next_start = {
        ["]m"] = "@function.outer",
        ["]]"] = "@class.outer",
        ["]a"] = "@parameter.inner",
      },
      goto_prev_start = {
        ["[m"] = "@function.outer",
        ["[["] = "@class.outer",
        ["[a"] = "@parameter.inner",
      },
    },
    swap = {
      enable = true,
      swap_next = { ["<leader>sa"] = "@parameter.inner" },
      swap_previous = { ["<leader>sA"] = "@parameter.inner" },
    },
  },
})

-- Mason (LSP installer)
require("mason").setup()
require("mason-lspconfig").setup({
  ensure_installed = { "lua_ls", "pyright", "clangd", "bashls", "jsonls", "yamlls", "texlab" },
})

-- format on save


-- nvim-cmp (autocomplete)
local cmp = require("cmp")
local luasnip = require("luasnip")
cmp.setup({
  snippet = { expand = function(args) luasnip.lsp_expand(args.body) end },
  mapping = cmp.mapping.preset.insert({
    ["<C-b>"] = cmp.mapping.scroll_docs(-4),
    ["<C-f>"] = cmp.mapping.scroll_docs(4),
    ["<C-Space>"] = cmp.mapping.complete(),
    ["<CR>"] = cmp.mapping.confirm({ select = true }),
    ["<Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { "i", "s" }),
    ["<S-Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { "i", "s" }),
  }),
  sources = cmp.config.sources({ { name = "nvim_lsp" }, { name = "luasnip" } },
    { { name = "buffer" }, { name = "path" } }),
})

-- === LSP (Neovim 0.11+ native API) ===
local capabilities = require("cmp_nvim_lsp").default_capabilities()

-- keymaps + format-on-save for all LSP buffers
local on_attach    = function(_, bufnr)
  local map = function(mode, lhs, rhs, desc)
    vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
  end
  map("n", "gd", vim.lsp.buf.definition, "Go to definition")
  map("n", "gr", vim.lsp.buf.references, "References")
  map("n", "K", vim.lsp.buf.hover, "Hover")
  map("n", "<leader>rn", vim.lsp.buf.rename, "Rename")
  map("n", "<leader>ca", vim.lsp.buf.code_action, "Code Action")
  map("n", "[d", vim.diagnostic.goto_prev, "Prev Diagnostic")
  map("n", "]d", vim.diagnostic.goto_next, "Next Diagnostic")
  map("n", "<leader>f", function() vim.lsp.buf.format({ async = true }) end, "Format")

  -- format on save (synchronous so it finishes before write)
  vim.api.nvim_create_autocmd("BufWritePre", {
    buffer = bufnr,
    callback = function()
      local ft = vim.bo[bufnr].filetype
      if ft ~= "c" and ft ~= "cpp" then
        vim.lsp.buf.format({ async = false })
      end
    end,
  })
end

-- === Native LSP (Neovim 0.11) ===
local lsp          = vim.lsp
local caps         = capabilities -- from cmp_nvim_lsp

-- Common servers
lsp.config.pyright = { capabilities = caps, on_attach = on_attach }
lsp.config.clangd  = {
  capabilities = caps,
  on_attach = on_attach,
  -- Uncomment to enable clang-tidy hints from clangd itself:
  -- cmd = { "clangd", "--background-index", "--clang-tidy" },
}
lsp.config.bashls  = { capabilities = caps, on_attach = on_attach }
lsp.config.jsonls  = { capabilities = caps, on_attach = on_attach }
lsp.config.yamlls  = { capabilities = caps, on_attach = on_attach }

-- Lua (tweaks)
lsp.config.lua_ls  = {
  capabilities = caps,
  on_attach = on_attach,
  settings = {
    Lua = {
      diagnostics = { globals = { "vim" } },
      workspace   = { checkThirdParty = false },
    },
  },
  -- 0.11 prefers root_markers over a custom root_dir function
  root_markers = { ".luarc.json", ".luarc.jsonc", ".stylua.toml", ".luacheckrc", ".git" },
}

-- Enable all of them (auto-attach for matching filetypes)
lsp.config.texlab = {
  capabilities = caps,
  on_attach = on_attach,
  settings = {
    texlab = {
      build = {
        executable = "latexmk",
        args = { "-pdf", "-interaction=nonstopmode", "-synctex=1", "%f" },
        onSave = true,
      },
    },
  },
}

lsp.enable({ "pyright", "clangd", "bashls", "jsonls", "yamlls", "lua_ls", "texlab" })

-- Keymaps (global)
local map = vim.keymap.set
map("n", "<leader>ff", "<cmd>Telescope find_files<cr>", { desc = "Find files" })
map("n", "<leader>fg", "<cmd>Telescope live_grep<cr>", { desc = "Grep" })
map("n", "<leader>fb", "<cmd>Telescope buffers<cr>", { desc = "Buffers" })
map("n", "<leader>fh", "<cmd>Telescope help_tags<cr>", { desc = "Help" })
-- === Projects / CMake / DAP / Tests / Symbols ===
local function safe_call(mod, fn)
  local ok, m = pcall(require, mod)
  if not ok then
    vim.notify(("Module not loaded: %s"):format(mod), vim.log.levels.WARN)
    return
  end
  return fn(m)
end

-- Projects (Telescope projects extension)
map("n", "<leader>pp", function()
  safe_call("telescope", function(t) t.extensions.projects.projects({}) end)
end, { desc = "Projects" })

-- CMake (cmake-tools.nvim)
map("n", "<leader>cg", function() safe_call("cmake-tools", function(c) c.generate() end) end, { desc = "CMake Generate" })
map("n", "<leader>cb", function() safe_call("cmake-tools", function(c) c.build() end) end, { desc = "CMake Build" })
map("n", "<leader>cr", function() safe_call("cmake-tools", function(c) c.run() end) end, { desc = "CMake Run target" })
map("n", "<leader>ct", function() safe_call("cmake-tools", function(c) c.select_build_type() end) end,
  { desc = "CMake Build Type" })
map("n", "<leader>cl", function() safe_call("cmake-tools", function(c) c.select_launch_target() end) end,
  { desc = "CMake Launch Target" })

-- DAP (codelldb via mason-nvim-dap)
map("n", "<F5>", function() safe_call("dap", function(d) d.continue() end) end, { desc = "DAP Continue" })
map("n", "<F9>", function() safe_call("dap", function(d) d.toggle_breakpoint() end) end,
  { desc = "DAP Toggle Breakpoint" })
map("n", "<F10>", function() safe_call("dap", function(d) d.step_over() end) end, { desc = "DAP Step Over" })
map("n", "<F11>", function() safe_call("dap", function(d) d.step_into() end) end, { desc = "DAP Step Into" })

-- Neotest (pick gtest or ctest adapter in your setup)
map("n", "<leader>tn", function() safe_call("neotest", function(n) n.run.run() end) end, { desc = "Test Nearest" })
map("n", "<leader>ts", function() safe_call("neotest", function(n) n.summary.toggle() end) end, { desc = "Test Summary" })

-- Symbols outline (aerial.nvim)
map("n", "<leader>so", function() safe_call("aerial", function(a) a.toggle() end) end, { desc = "Symbols (Aerial)" })

-- C/C++ header ⇄ source (works when clangd is attached)
local function switch_header_source()
  local params = { uri = vim.uri_from_bufnr(0) }
  vim.lsp.buf_request(0, "textDocument/switchSourceHeader", params, function(err, result)
    if err or not result then return end
    vim.cmd.edit(vim.uri_to_fname(result))
  end)
end
map("n", "<leader>ch", switch_header_source, { desc = "C/C++ Switch header/source" })


-- Oil file explorer
map("n", "-", "<cmd>Oil<cr>", { desc = "Open parent directory" })

-- Trouble diagnostics
map("n", "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", { desc = "Diagnostics (Trouble)" })
map("n", "<leader>xq", "<cmd>Trouble quickfix toggle<cr>", { desc = "Quickfix (Trouble)" })

-- Quality of life
map({ "n", "v" }, "<leader>/", function() require("Comment.api").toggle.linewise.current() end,
  { desc = "Comment toggle" })

-- Harpoon
local harpoon = require("harpoon")
map("n", "<leader>ha", function() harpoon:list():add() end, { desc = "Harpoon add file" })
map("n", "<leader>hh", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end, { desc = "Harpoon menu" })
map("n", "<C-1>", function() harpoon:list():select(1) end, { desc = "Harpoon 1" })
map("n", "<C-2>", function() harpoon:list():select(2) end, { desc = "Harpoon 2" })
map("n", "<C-3>", function() harpoon:list():select(3) end, { desc = "Harpoon 3" })
map("n", "<C-4>", function() harpoon:list():select(4) end, { desc = "Harpoon 4" })

-- Undotree
map("n", "<leader>u", "<cmd>UndotreeToggle<cr>", { desc = "Undotree" })

-- Diffview
map("n", "<leader>gd", "<cmd>DiffviewOpen<cr>", { desc = "Git diff view" })
map("n", "<leader>gh", "<cmd>DiffviewFileHistory %<cr>", { desc = "Git file history" })
map("n", "<leader>gq", "<cmd>DiffviewClose<cr>", { desc = "Close diff view" })

-- AI (Avante)
map("n", "<leader>aa", "<cmd>AvanteAsk<cr>", { desc = "Avante ask" })
map("v", "<leader>aa", "<cmd>AvanteAsk<cr>", { desc = "Avante ask (selection)" })
map("n", "<leader>at", "<cmd>AvanteToggle<cr>", { desc = "Avante toggle" })
map("n", "<leader>ac", "<cmd>AvanteChat<cr>", { desc = "Avante chat" })

-- Lazygit
map("n", "<leader>gg", "<cmd>LazyGit<cr>", { desc = "LazyGit" })

-- Persistence (sessions)
map("n", "<leader>qs", function() require("persistence").load() end, { desc = "Restore session (cwd)" })
map("n", "<leader>ql", function() require("persistence").load({ last = true }) end, { desc = "Restore last session" })
map("n", "<leader>qd", function() require("persistence").stop() end, { desc = "Stop session recording" })

-- Spectre (find & replace)
map("n", "<leader>sr", function() require("spectre").toggle() end, { desc = "Search & Replace (Spectre)" })
map("n", "<leader>sw", function() require("spectre").open_visual({ select_word = true }) end, { desc = "Search current word" })
map("v", "<leader>sw", function() require("spectre").open_visual() end, { desc = "Search selection" })

-- Zen mode
map("n", "<leader>z", "<cmd>ZenMode<cr>", { desc = "Zen Mode" })
