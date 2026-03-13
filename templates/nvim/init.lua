-- =========================
-- Neovim Starter (minimal but powerful)
-- Leader = Space, plugin manager = lazy.nvim
-- =========================

-- Leader
vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.python3_host_prog = vim.fn.expand("~/.venvs/nvim/bin/python")

-- Suppress deprecation warnings from plugins we don't control (project.nvim, telescope)
local _orig_deprecate = vim.deprecate
vim.deprecate = function(name, alternative, version, plugin, backtrace)
  if name and name:match("buf_get_clients") then return end
  return _orig_deprecate(name, alternative, version, plugin, backtrace)
end

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
vim.opt.smoothscroll = true
vim.opt.cursorline = true
vim.opt.guicursor = "n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50,a:blinkwait400-blinkoff400-blinkon250"
vim.opt.clipboard = "unnamedplus"

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
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
        hl["@number"]        = { fg = "#f9e2af", bold = true }
        hl["@number.hex"]    = { fg = "#f9e2af", bold = true }
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
  -- Neo-tree (file tree sidebar)
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    cmd = "Neotree",
    keys = {
      { "<leader>e", "<cmd>Neotree toggle<cr>", desc = "File Explorer (Neo-tree)" },
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    opts = {
      close_if_last_window = true,
      popup_border_style = "rounded",
      enable_git_status = true,
      enable_diagnostics = true,
      window = {
        width = 36,
        mappings = {
          ["<space>"] = "none",
          ["l"] = "open",
          ["h"] = "close_node",
          ["<cr>"] = "open",
          ["s"] = "open_split",
          ["v"] = "open_vsplit",
        },
      },
      filesystem = {
        follow_current_file = { enabled = true },
        use_libuv_file_watcher = true,
        group_empty_dirs = true,
        filtered_items = {
          visible = false,
          hide_dotfiles = false,
          hide_gitignored = false,
          hide_by_name = { ".git", "node_modules", ".cache" },
        },
      },
      default_component_configs = {
        indent = {
          indent_size = 2,
          padding = 1,
          with_markers = true,
          indent_marker = "│",
          last_indent_marker = "└",
        },
        icon = {
          folder_closed = "",
          folder_open = "",
          folder_empty = "",
        },
        name = {
          trailing_slash = false,
          use_git_status_colors = true,
        },
        git_status = {
          symbols = {
            added     = "",
            modified  = "",
            deleted   = "",
            renamed   = "",
            untracked = "",
            ignored   = "",
            unstaged  = "",
            staged    = "",
            conflict  = "",
          },
        },
      },
    },
  },

  -- Bufferline (buffer tabs)
  {
    "akinsho/bufferline.nvim",
    version = "*",
    event = "BufReadPost",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      options = {
        diagnostics = "nvim_lsp",
        offsets = {
          { filetype = "neo-tree", text = "  File Explorer", text_align = "left", highlight = "Directory", separator = true },
        },
        separator_style = "thin",
        show_buffer_close_icons = false,
        show_close_icon = false,
      },
      highlights = {
        fill = { bg = "#150f0f" },
        background = { fg = "#5a6270", bg = "#150f0f" },
        buffer_selected = { fg = "#f5f5f7", bg = "#1a1214", bold = true },
        buffer_visible = { fg = "#5a6270", bg = "#150f0f" },
        separator = { fg = "#2d1f27", bg = "#150f0f" },
        separator_selected = { fg = "#2d1f27", bg = "#1a1214" },
        separator_visible = { fg = "#2d1f27", bg = "#150f0f" },
        indicator_selected = { fg = "#f4b58a", bg = "#1a1214" },
        modified = { fg = "#f9e2af", bg = "#150f0f" },
        modified_selected = { fg = "#f9e2af", bg = "#1a1214" },
        modified_visible = { fg = "#f9e2af", bg = "#150f0f" },
        tab = { fg = "#5a6270", bg = "#150f0f" },
        tab_selected = { fg = "#f4b58a", bg = "#1a1214", bold = true },
        tab_separator = { fg = "#2d1f27", bg = "#150f0f" },
        tab_separator_selected = { fg = "#2d1f27", bg = "#1a1214" },
        duplicate = { fg = "#5a6270", bg = "#150f0f", italic = true },
        duplicate_selected = { fg = "#f5f5f7", bg = "#1a1214", italic = true },
        duplicate_visible = { fg = "#5a6270", bg = "#150f0f", italic = true },
        diagnostic_selected = { bold = true },
      },
    },
  },

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

  -- Diagnostics UI
  {
    "folke/trouble.nvim",
    cmd = "Trouble",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {},
  },
  -- TODO highlights
  { "folke/todo-comments.nvim",         dependencies = { "nvim-lua/plenary.nvim" },       opts = {} },

  -- Projects
  {
    "coffebar/project.nvim",
    pin = true,
    event = "VeryLazy",
    opts = {
      detection_methods = { "lsp", "pattern" },
      patterns = { ".git", "compile_commands.json", "CMakeLists.txt", "Makefile" },
      silent_chdir = true,
    },
    config = function(_, opts)
      require("project_nvim").setup(opts)
      require("telescope").load_extension("projects")
    end,
  },

  {
    "stevearc/overseer.nvim",
    cmd = "OverseerRun",
    opts = {},
  },
  {
    "akinsho/toggleterm.nvim",
    cmd = "ToggleTerm",
    keys = {
      { "<C-\\>", "<cmd>ToggleTerm<cr>", desc = "Toggle Terminal" },
    },
    opts = {
      open_mapping = [[<C-\>]],
    },
  },

  {
    "Civitasv/cmake-tools.nvim",
    ft = { "c", "cpp", "cmake" },
    dependencies = { "nvim-lua/plenary.nvim", "stevearc/overseer.nvim", "akinsho/toggleterm.nvim" },
    opts = {
      cmake_use_preset = true,
      cmake_regenerate_on_save = true,
      cmake_generate_options = { "-DCMAKE_EXPORT_COMPILE_COMMANDS=1" },
      cmake_compile_commands_options = { action = "soft_link", target = vim.uv.cwd() },
      -- preset DAP integration (we'll install codelldb via Mason)
      cmake_dap_configuration = { name = "cpp", type = "codelldb", request = "launch", runInTerminal = true },
    },
  },

  {
    "mfussenegger/nvim-dap",
    keys = {
      { "<F5>", function() require("dap").continue() end, desc = "DAP Continue" },
      { "<F9>", function() require("dap").toggle_breakpoint() end, desc = "DAP Toggle Breakpoint" },
      { "<F10>", function() require("dap").step_over() end, desc = "DAP Step Over" },
      { "<F11>", function() require("dap").step_into() end, desc = "DAP Step Into" },
    },
  },
  { "nvim-neotest/nvim-nio",             lazy = true },
  {
    "rcarriga/nvim-dap-ui",
    dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },
    lazy = true,
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
    lazy = true,
    opts = {
      automatic_installation = true,
      ensure_installed = { "codelldb" },
    },
  },
  {
    "theHamsta/nvim-dap-virtual-text",
    dependencies = { "mfussenegger/nvim-dap", "nvim-treesitter/nvim-treesitter" },
    lazy = true,
    opts = {},
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
    ft = "tex",
    init = function()
      vim.g.vimtex_view_method = "zathura"
      vim.g.vimtex_compiler_method = "latexmk"
      vim.g.vimtex_quickfix_mode = 0
    end,
  },

  {
    "stevearc/aerial.nvim",
    cmd = "AerialToggle",
    opts = {},
  },
  { "nvim-treesitter/nvim-treesitter-context", opts = {} },

  -- Neotest core + GTest adapter (lazy-loaded)
  {
    "nvim-neotest/neotest",
    cmd = "Neotest",
    dependencies = { "nvim-lua/plenary.nvim", "nvim-treesitter/nvim-treesitter", "nvim-neotest/nvim-nio", "alfaix/neotest-gtest" },
    config = function()
      require("neotest").setup({
        adapters = {
          require("neotest-gtest").setup({}),
        },
      })
    end,
  },
  { "alfaix/neotest-gtest", lazy = true },

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
  { "mbbill/undotree", cmd = "UndotreeToggle" },

  -- Fidget (LSP progress spinner — route through noice instead)
  {
    "j-hui/fidget.nvim",
    opts = {
      notification = { override_vim_notify = false },
    },
  },

  -- Diffview (full git diff/merge viewer)
  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewFileHistory", "DiffviewClose" },
    dependencies = { "nvim-lua/plenary.nvim" },
  },

  -- === AI ===

  -- Copilot (inline ghost-text completions)
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    opts = {
      suggestion = {
        enabled = true,
        auto_trigger = true,
        debounce = 150,
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
        ["*"] = true,
        ["AvanteInput"] = false,
        ["Avante"] = false,
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
        auto_add_current_file = false,
        auto_apply_diff_after_generation = true,
      },
      history = {
        max_tokens = 8192,
      },
      windows = {
        width = 30,
        sidebar_header = {
          rounded = true,
          include_model = true,
        },
      },
    },
  },
  { "MunifTanjim/nui.nvim" },

  -- mini.ai (enhanced text objects)
  {
    "echasnovski/mini.ai",
    event = "VeryLazy",
    opts = { n_lines = 500 },
  },

  -- Snacks (dashboard)
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
      notifier = { enabled = false },
      indent = { enabled = false },
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
    keys = {
      { "<leader>sr", function() require("spectre").toggle() end, desc = "Search & Replace (Spectre)" },
      { "<leader>sw", function() require("spectre").open_visual({ select_word = true }) end, desc = "Search current word" },
      { "<leader>sw", function() require("spectre").open_visual() end, desc = "Search selection", mode = "v" },
    },
  },

  -- === Visual Polish ===

  -- Noice (floating cmdline, messages, search popup)
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = { "MunifTanjim/nui.nvim", "rcarriga/nvim-notify" },
    opts = {
      cmdline = {
        enabled = true,
        view = "cmdline_popup",
        format = {
          cmdline = { pattern = "^:", icon = " ", lang = "vim" },
          search_down = { kind = "search", pattern = "^/", icon = " ", lang = "regex" },
          search_up = { kind = "search", pattern = "^%?", icon = " ", lang = "regex" },
          filter = { pattern = "^:%s*!", icon = " ", lang = "bash" },
          lua = { pattern = { "^:%s*lua%s+", "^:%s*lua%s*=%s*", "^:%s*=%s*" }, icon = " ", lang = "lua" },
        },
      },
      messages = { enabled = true, view_search = "virtualtext" },
      popupmenu = { enabled = true, backend = "nui" },
      lsp = {
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
          ["cmp.entry.get_documentation"] = true,
        },
        hover = { enabled = true },
        signature = { enabled = true },
        progress = { enabled = false }, -- fidget handles this
      },
      presets = {
        bottom_search = false,
        command_palette = true,
        long_message_to_split = true,
        lsp_doc_border = true,
      },
    },
  },

  -- Notify (pretty notification popups, used by noice)
  {
    "rcarriga/nvim-notify",
    opts = {
      background_colour = "#1a1214",
      fps = 60,
      render = "wrapped-compact",
      stages = "fade",
      timeout = 2500,
      max_width = 60,
      icons = {
        ERROR = " ",
        WARN = " ",
        INFO = " ",
        DEBUG = " ",
        TRACE = " ",
      },
    },
  },

  -- Colorizer (show hex colors inline — skip C/C++ where 0x constants aren't colors)
  {
    "NvChad/nvim-colorizer.lua",
    event = "BufReadPost",
    opts = {
      filetypes = { "*", "!c", "!cpp", "!h" },
      user_default_options = {
        RGB = true,
        RRGGBB = true,
        names = false,
        RRGGBBAA = true,
        css = true,
        css_fn = true,
        mode = "background",
        virtualtext = "  ",
      },
    },
  },

  -- Rainbow delimiters (colored nested brackets)
  {
    "HiPhish/rainbow-delimiters.nvim",
    event = "BufReadPost",
    config = function()
      local rd = require("rainbow-delimiters")
      require("rainbow-delimiters.setup").setup({
        strategy = { [""] = rd.strategy["global"] },
        query = { [""] = "rainbow-delimiters" },
        highlight = {
          "RainbowDelimiterPeach",
          "RainbowDelimiterPink",
          "RainbowDelimiterMint",
          "RainbowDelimiterYellow",
          "RainbowDelimiterCyan",
          "RainbowDelimiterRed",
        },
      })
    end,
  },

  -- Colorful window separator (highlight active window border)
  {
    "nvim-zh/colorful-winsep.nvim",
    event = "WinNew",
    opts = {
      hi = {
        fg = "#f4b58a",
      },
      symbols = { "─", "│", "╭", "╮", "╰", "╯" },
    },
  },

  -- Scrollbar (diagnostics, search, git marks)
  {
    "petertriho/nvim-scrollbar",
    event = "BufReadPost",
    opts = {
      handle = {
        color = "#2d1f27",
        highlight = "ScrollbarHandle",
      },
      marks = {
        Search = { color = "#f4b58a" },
        Error = { color = "#ff6b6b" },
        Warn = { color = "#f9e2af" },
        Info = { color = "#89dceb" },
        Hint = { color = "#8bd5a2" },
        Misc = { color = "#f5a9b8" },
        GitAdd = { color = "#8bd5a2" },
        GitChange = { color = "#f9e2af" },
        GitDelete = { color = "#ff6b6b" },
      },
      excluded_filetypes = { "neo-tree", "dashboard", "lazy", "mason", "notify" },
    },
    config = function(_, opts)
      require("scrollbar").setup(opts)
      require("scrollbar.handlers.gitsigns").setup()
      require("scrollbar.handlers.search").setup()
    end,
    dependencies = { "lewis6991/gitsigns.nvim", "kevinhwang91/nvim-hlslens" },
  },

  -- hlslens (search result count/index, used by scrollbar)
  {
    "kevinhwang91/nvim-hlslens",
    event = "BufReadPost",
    opts = { calm_down = true, nearest_only = true },
  },

  -- Tint (dim inactive windows)
  {
    "levouh/tint.nvim",
    event = "WinNew",
    opts = {
      tint = -30,
      saturation = 0.7,
      tint_background_colors = true,
      highlight_ignore_patterns = { "WinSeparator", "Status.*", "EndOfBuffer" },
      window_ignore_function = function(winid)
        local buf = vim.api.nvim_win_get_buf(winid)
        local ft = vim.bo[buf].filetype
        return ft == "neo-tree" or ft == "aerial" or ft == "Trouble"
      end,
    },
  },

}

-- lazy.nvim setup
require("lazy").setup(plugins, {
  rocks = { enabled = false },
})

-- setup optional
vim.opt.signcolumn = "yes:1"
vim.opt.fillchars:append({ eob = " ", vert = "│" })

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

-- Patch the common float helper used by LSP UIs (fallback when noice isn't active)
do
  local _open = vim.lsp.util.open_floating_preview
  function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
    opts = opts or {}
    opts.border = opts.border or border
    return _open(contents, syntax, opts, ...)
  end
end

-- Neon diagnostic icons
local icons = { Error = " ", Warn = " ", Info = " ", Hint = " " }

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
vim.api.nvim_set_hl(0, "PmenuSbar", { bg = "#2d1f27" })
vim.api.nvim_set_hl(0, "PmenuThumb", { bg = "#5a6270" })

-- Search
vim.api.nvim_set_hl(0, "CurSearch", { fg = "#1a1214", bg = "#f4b58a", bold = true })

-- Fold
vim.api.nvim_set_hl(0, "Folded", { fg = "#5a6270", bg = "#2d1f27" })
vim.api.nvim_set_hl(0, "FoldColumn", { fg = "#3a414b", bg = "none" })

-- Tab line (fallback for when bufferline isn't active)
vim.api.nvim_set_hl(0, "TabLine", { fg = "#5a6270", bg = "#150f0f" })
vim.api.nvim_set_hl(0, "TabLineSel", { fg = "#f4b58a", bg = "#2d1f27", bold = true })
vim.api.nvim_set_hl(0, "TabLineFill", { bg = "#150f0f" })

-- Status line (fallback)
vim.api.nvim_set_hl(0, "StatusLine", { fg = "#c4b6a8", bg = "#150f0f" })
vim.api.nvim_set_hl(0, "StatusLineNC", { fg = "#3a414b", bg = "#150f0f" })

-- Misc UI
vim.api.nvim_set_hl(0, "WildMenu", { fg = "#1a1214", bg = "#f4b58a", bold = true })
vim.api.nvim_set_hl(0, "Title", { fg = "#f4b58a", bold = true })
vim.api.nvim_set_hl(0, "Directory", { fg = "#89dceb" })
vim.api.nvim_set_hl(0, "Question", { fg = "#8bd5a2" })
vim.api.nvim_set_hl(0, "SpecialKey", { fg = "#3a414b" })
vim.api.nvim_set_hl(0, "NonText", { fg = "#3a414b" })
vim.api.nvim_set_hl(0, "Conceal", { fg = "#5a6270" })

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

-- Window separator accent
vim.api.nvim_set_hl(0, "WinSeparator", { fg = "#2d1f27" })

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

-- Neo-tree
vim.api.nvim_set_hl(0, "NeoTreeNormal", { bg = "#150f0f" })
vim.api.nvim_set_hl(0, "NeoTreeNormalNC", { bg = "#150f0f" })
vim.api.nvim_set_hl(0, "NeoTreeEndOfBuffer", { fg = "#150f0f", bg = "#150f0f" })
vim.api.nvim_set_hl(0, "NeoTreeDirectoryName", { fg = "#f4b58a" })
vim.api.nvim_set_hl(0, "NeoTreeDirectoryIcon", { fg = "#f4b58a" })
vim.api.nvim_set_hl(0, "NeoTreeRootName", { fg = "#f5a9b8", bold = true })
vim.api.nvim_set_hl(0, "NeoTreeFileName", { fg = "#f5f5f7" })
vim.api.nvim_set_hl(0, "NeoTreeFileIcon", { fg = "#f5f5f7" })
vim.api.nvim_set_hl(0, "NeoTreeGitAdded", { fg = "#8bd5a2" })
vim.api.nvim_set_hl(0, "NeoTreeGitModified", { fg = "#f9e2af" })
vim.api.nvim_set_hl(0, "NeoTreeGitDeleted", { fg = "#ff6b6b" })
vim.api.nvim_set_hl(0, "NeoTreeGitUntracked", { fg = "#89dceb" })
vim.api.nvim_set_hl(0, "NeoTreeGitConflict", { fg = "#ff6b6b", bold = true })
vim.api.nvim_set_hl(0, "NeoTreeIndentMarker", { fg = "#2d1f27" })
vim.api.nvim_set_hl(0, "NeoTreeWinSeparator", { fg = "#2d1f27", bg = "#150f0f" })
vim.api.nvim_set_hl(0, "NeoTreeCursorLine", { bg = "#2d1f27" })
vim.api.nvim_set_hl(0, "NeoTreeTitleBar", { fg = "#1a1214", bg = "#f4b58a", bold = true })
vim.api.nvim_set_hl(0, "NeoTreeFloatBorder", { fg = "#f4b58a" })
vim.api.nvim_set_hl(0, "NeoTreeFloatTitle", { fg = "#f4b58a", bold = true })

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

-- Rainbow delimiters (FoxML palette)
vim.api.nvim_set_hl(0, "RainbowDelimiterPeach", { fg = "#f4b58a" })
vim.api.nvim_set_hl(0, "RainbowDelimiterPink", { fg = "#f5a9b8" })
vim.api.nvim_set_hl(0, "RainbowDelimiterMint", { fg = "#8bd5a2" })
vim.api.nvim_set_hl(0, "RainbowDelimiterYellow", { fg = "#f9e2af" })
vim.api.nvim_set_hl(0, "RainbowDelimiterCyan", { fg = "#89dceb" })
vim.api.nvim_set_hl(0, "RainbowDelimiterRed", { fg = "#ff6b6b" })

-- Noice cmdline & popups
vim.api.nvim_set_hl(0, "NoiceCmdlinePopup", { bg = "#150f0f" })
vim.api.nvim_set_hl(0, "NoiceCmdlinePopupBorder", { fg = "#f4b58a" })
vim.api.nvim_set_hl(0, "NoiceCmdlinePopupTitle", { fg = "#f4b58a", bold = true })
vim.api.nvim_set_hl(0, "NoiceCmdlinePopupBorderSearch", { fg = "#f9e2af" })
vim.api.nvim_set_hl(0, "NoiceCmdlineIcon", { fg = "#f4b58a" })
vim.api.nvim_set_hl(0, "NoiceCmdlineIconSearch", { fg = "#f9e2af" })
vim.api.nvim_set_hl(0, "NoicePopupmenu", { bg = "#150f0f" })
vim.api.nvim_set_hl(0, "NoicePopupmenuBorder", { fg = "#f4b58a" })
vim.api.nvim_set_hl(0, "NoicePopupmenuSelected", { bg = "#2d1f27" })
vim.api.nvim_set_hl(0, "NoicePopupmenuMatch", { fg = "#f4b58a", bold = true })
vim.api.nvim_set_hl(0, "NoiceMini", { bg = "#150f0f" })
vim.api.nvim_set_hl(0, "NoiceFormatProgressDone", { fg = "#1a1214", bg = "#f4b58a" })
vim.api.nvim_set_hl(0, "NoiceFormatProgressTodo", { fg = "#5a6270", bg = "#2d1f27" })
vim.api.nvim_set_hl(0, "NoiceLspProgressTitle", { fg = "#f4b58a" })
vim.api.nvim_set_hl(0, "NoiceConfirm", { bg = "#150f0f" })
vim.api.nvim_set_hl(0, "NoiceConfirmBorder", { fg = "#f5a9b8" })
vim.api.nvim_set_hl(0, "NoiceVirtualText", { fg = "#f4b58a" })
vim.api.nvim_set_hl(0, "NoiceSplit", { bg = "#150f0f" })
vim.api.nvim_set_hl(0, "NoiceSplitBorder", { fg = "#f4b58a", bg = "#150f0f" })

-- :messages window highlights
vim.api.nvim_set_hl(0, "MsgArea", { fg = "#c4b6a8", bg = "#150f0f" })
vim.api.nvim_set_hl(0, "WarningMsg", { fg = "#f9e2af", bold = true })
vim.api.nvim_set_hl(0, "ErrorMsg", { fg = "#ff6b6b", bold = true })
vim.api.nvim_set_hl(0, "ModeMsg", { fg = "#f4b58a", bold = true })
vim.api.nvim_set_hl(0, "MoreMsg", { fg = "#8bd5a2" })

-- Notify
vim.api.nvim_set_hl(0, "NotifyERRORBorder", { fg = "#ff6b6b" })
vim.api.nvim_set_hl(0, "NotifyWARNBorder", { fg = "#f9e2af" })
vim.api.nvim_set_hl(0, "NotifyINFOBorder", { fg = "#89dceb" })
vim.api.nvim_set_hl(0, "NotifyDEBUGBorder", { fg = "#5a6270" })
vim.api.nvim_set_hl(0, "NotifyTRACEBorder", { fg = "#f5a9b8" })
vim.api.nvim_set_hl(0, "NotifyERRORIcon", { fg = "#ff6b6b" })
vim.api.nvim_set_hl(0, "NotifyWARNIcon", { fg = "#f9e2af" })
vim.api.nvim_set_hl(0, "NotifyINFOIcon", { fg = "#89dceb" })
vim.api.nvim_set_hl(0, "NotifyDEBUGIcon", { fg = "#5a6270" })
vim.api.nvim_set_hl(0, "NotifyTRACEIcon", { fg = "#f5a9b8" })
vim.api.nvim_set_hl(0, "NotifyERRORTitle", { fg = "#ff6b6b" })
vim.api.nvim_set_hl(0, "NotifyWARNTitle", { fg = "#f9e2af" })
vim.api.nvim_set_hl(0, "NotifyINFOTitle", { fg = "#89dceb" })
vim.api.nvim_set_hl(0, "NotifyDEBUGTitle", { fg = "#5a6270" })
vim.api.nvim_set_hl(0, "NotifyTRACETitle", { fg = "#f5a9b8" })
vim.api.nvim_set_hl(0, "NotifyBackground", { bg = "#1a1214" })

-- Scrollbar
vim.api.nvim_set_hl(0, "ScrollbarHandle", { bg = "#2d1f27" })
vim.api.nvim_set_hl(0, "ScrollbarSearchHandle", { fg = "#f4b58a", bg = "#2d1f27" })
vim.api.nvim_set_hl(0, "ScrollbarSearch", { fg = "#f4b58a" })
vim.api.nvim_set_hl(0, "ScrollbarErrorHandle", { fg = "#ff6b6b", bg = "#2d1f27" })
vim.api.nvim_set_hl(0, "ScrollbarError", { fg = "#ff6b6b" })
vim.api.nvim_set_hl(0, "ScrollbarWarnHandle", { fg = "#f9e2af", bg = "#2d1f27" })
vim.api.nvim_set_hl(0, "ScrollbarWarn", { fg = "#f9e2af" })
vim.api.nvim_set_hl(0, "ScrollbarInfoHandle", { fg = "#89dceb", bg = "#2d1f27" })
vim.api.nvim_set_hl(0, "ScrollbarInfo", { fg = "#89dceb" })
vim.api.nvim_set_hl(0, "ScrollbarHintHandle", { fg = "#8bd5a2", bg = "#2d1f27" })
vim.api.nvim_set_hl(0, "ScrollbarHint", { fg = "#8bd5a2" })
vim.api.nvim_set_hl(0, "ScrollbarGitAddHandle", { fg = "#8bd5a2", bg = "#2d1f27" })
vim.api.nvim_set_hl(0, "ScrollbarGitAdd", { fg = "#8bd5a2" })
vim.api.nvim_set_hl(0, "ScrollbarGitChangeHandle", { fg = "#f9e2af", bg = "#2d1f27" })
vim.api.nvim_set_hl(0, "ScrollbarGitChange", { fg = "#f9e2af" })
vim.api.nvim_set_hl(0, "ScrollbarGitDeleteHandle", { fg = "#ff6b6b", bg = "#2d1f27" })
vim.api.nvim_set_hl(0, "ScrollbarGitDelete", { fg = "#ff6b6b" })

-- hlslens (search result counter)
vim.api.nvim_set_hl(0, "HlSearchNear", { fg = "#1a1214", bg = "#f4b58a", bold = true })
vim.api.nvim_set_hl(0, "HlSearchLens", { fg = "#5a6270" })
vim.api.nvim_set_hl(0, "HlSearchLensNear", { fg = "#1a1214", bg = "#f4b58a" })

-- Avante
vim.api.nvim_set_hl(0, "AvanteTitle", { fg = "#1a1214", bg = "#f4b58a", bold = true })
vim.api.nvim_set_hl(0, "AvanteReversedTitle", { fg = "#f4b58a", bg = "#150f0f" })
vim.api.nvim_set_hl(0, "AvanteSubtitle", { fg = "#1a1214", bg = "#89dceb", bold = true })
vim.api.nvim_set_hl(0, "AvanteReversedSubtitle", { fg = "#89dceb", bg = "#150f0f" })
vim.api.nvim_set_hl(0, "AvanteThirdTitle", { fg = "#c4b6a8", bg = "#2d1f27" })
vim.api.nvim_set_hl(0, "AvanteReversedThirdTitle", { fg = "#2d1f27", bg = "#150f0f" })
vim.api.nvim_set_hl(0, "AvanteSidebarNormal", { bg = "#150f0f" })
vim.api.nvim_set_hl(0, "AvanteSidebarWinSeparator", { fg = "#2d1f27", bg = "#150f0f" })
vim.api.nvim_set_hl(0, "AvanteSidebarWinHorizontalSeparator", { fg = "#2d1f27" })
vim.api.nvim_set_hl(0, "AvantePromptInput", { bg = "#1a1214" })
vim.api.nvim_set_hl(0, "AvantePromptInputBorder", { fg = "#f4b58a", bg = "#150f0f" })
vim.api.nvim_set_hl(0, "AvanteInlineHint", { fg = "#f5a9b8", italic = true })
vim.api.nvim_set_hl(0, "AvantePopupHint", { fg = "#5a6270", bg = "#150f0f" })
vim.api.nvim_set_hl(0, "AvanteConfirmTitle", { fg = "#1a1214", bg = "#ff6b6b", bold = true })
vim.api.nvim_set_hl(0, "AvanteButtonDefault", { fg = "#1a1214", bg = "#5a6270" })
vim.api.nvim_set_hl(0, "AvanteButtonDefaultHover", { fg = "#1a1214", bg = "#8bd5a2" })
vim.api.nvim_set_hl(0, "AvanteButtonPrimary", { fg = "#1a1214", bg = "#c4b6a8" })
vim.api.nvim_set_hl(0, "AvanteButtonPrimaryHover", { fg = "#1a1214", bg = "#89dceb" })
vim.api.nvim_set_hl(0, "AvanteButtonDanger", { fg = "#1a1214", bg = "#c4b6a8" })
vim.api.nvim_set_hl(0, "AvanteButtonDangerHover", { fg = "#1a1214", bg = "#ff6b6b" })
vim.api.nvim_set_hl(0, "AvanteToBeDeleted", { bg = "#3d1f23", strikethrough = true })
vim.api.nvim_set_hl(0, "AvanteToBeDeletedWOStrikethrough", { bg = "#3d1f23" })
vim.api.nvim_set_hl(0, "AvanteConflictCurrent", { bg = "#3d1f23", bold = true })
vim.api.nvim_set_hl(0, "AvanteConflictCurrentLabel", { bg = "#4d2529" })
vim.api.nvim_set_hl(0, "AvanteConflictIncoming", { bg = "#1a3328", bold = true })
vim.api.nvim_set_hl(0, "AvanteConflictIncomingLabel", { bg = "#1f3d2e" })
vim.api.nvim_set_hl(0, "AvanteStateSpinnerGenerating", { fg = "#1a1214", bg = "#f5a9b8" })
vim.api.nvim_set_hl(0, "AvanteStateSpinnerToolCalling", { fg = "#1a1214", bg = "#89dceb" })
vim.api.nvim_set_hl(0, "AvanteStateSpinnerFailed", { fg = "#1a1214", bg = "#ff6b6b" })
vim.api.nvim_set_hl(0, "AvanteStateSpinnerSucceeded", { fg = "#1a1214", bg = "#8bd5a2" })
vim.api.nvim_set_hl(0, "AvanteStateSpinnerSearching", { fg = "#1a1214", bg = "#f9e2af" })
vim.api.nvim_set_hl(0, "AvanteStateSpinnerThinking", { fg = "#1a1214", bg = "#f5a9b8" })
vim.api.nvim_set_hl(0, "AvanteStateSpinnerCompacting", { fg = "#1a1214", bg = "#f9e2af" })
vim.api.nvim_set_hl(0, "AvanteTaskRunning", { fg = "#f5a9b8" })
vim.api.nvim_set_hl(0, "AvanteTaskCompleted", { fg = "#8bd5a2" })
vim.api.nvim_set_hl(0, "AvanteTaskFailed", { fg = "#ff6b6b" })
vim.api.nvim_set_hl(0, "AvanteThinking", { fg = "#f5a9b8", italic = true })

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
-- Lualine theme sync (noice integration removed)
require("lualine").setup({
  options = {
    theme = {
      normal   = { a = { fg = "#1a1214", bg = "#f4b58a", gui = "bold" }, b = { fg = "#f4b58a", bg = "#2d1f27" }, c = { fg = "#5a6270", bg = "#150f0f" } },
      insert   = { a = { fg = "#1a1214", bg = "#8bd5a2", gui = "bold" }, b = { fg = "#8bd5a2", bg = "#2d1f27" } },
      visual   = { a = { fg = "#1a1214", bg = "#f5a9b8", gui = "bold" }, b = { fg = "#f5a9b8", bg = "#2d1f27" } },
      replace  = { a = { fg = "#1a1214", bg = "#ff6b6b", gui = "bold" }, b = { fg = "#ff6b6b", bg = "#2d1f27" } },
      command  = { a = { fg = "#1a1214", bg = "#f9e2af", gui = "bold" }, b = { fg = "#f9e2af", bg = "#2d1f27" } },
      inactive = { a = { fg = "#5a6270", bg = "#150f0f" }, b = { fg = "#3a414b", bg = "#150f0f" }, c = { fg = "#3a414b", bg = "#150f0f" } },
    },
    section_separators = { left = "", right = "" },
    component_separators = { left = "", right = "" },
  },
  sections = {
    lualine_a = { "mode" },
    lualine_b = { "branch", "diff", "diagnostics" },
    lualine_c = { { "filename", path = 1 } },
    lualine_x = {
      {
        function()
          local ok, api = pcall(require, "copilot.api")
          if not ok then return "" end
          local status = api.status.data.status
          if status == "InProgress" then return " " end
          if status == "Warning" then return " " end
          if status == "Normal" then return " " end
          return ""
        end,
        color = function()
          local ok, api = pcall(require, "copilot.api")
          if not ok then return { fg = "#5a6270" } end
          local status = api.status.data.status
          if status == "InProgress" then return { fg = "#f9e2af" } end
          if status == "Warning" then return { fg = "#ff6b6b" } end
          return { fg = "#8bd5a2" }
        end,
      },
      {
        function()
          local clients = vim.lsp.get_clients({ bufnr = 0 })
          if #clients == 0 then return "" end
          return " " .. clients[1].name
        end,
        color = { fg = "#f4b58a" },
      },
      "filetype",
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


-- Open neo-tree at current file's directory
map("n", "-", "<cmd>Neotree reveal<cr>", { desc = "Reveal file in tree" })

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

-- Bufferline navigation
map("n", "H", "<cmd>BufferLineCyclePrev<cr>", { desc = "Prev buffer" })
map("n", "L", "<cmd>BufferLineCycleNext<cr>", { desc = "Next buffer" })
map("n", "<leader>bd", function()
  local cur = vim.api.nvim_get_current_buf()
  local bufs = vim.iter(vim.api.nvim_list_bufs()):filter(function(b)
    return vim.api.nvim_buf_is_valid(b) and vim.bo[b].buflisted
  end):totable()
  if #bufs <= 1 then
    vim.cmd("enew")
    if vim.api.nvim_buf_is_valid(cur) and cur ~= vim.api.nvim_get_current_buf() then
      vim.cmd("bdelete " .. cur)
    end
  else
    vim.cmd("bprevious | bdelete #")
  end
end, { desc = "Close buffer" })
map("n", "<leader>bo", "<cmd>BufferLineCloseOthers<cr>", { desc = "Close other buffers" })
map("n", "<leader>bl", "<cmd>BufferLineCloseRight<cr>", { desc = "Close buffers to right" })
map("n", "<leader>bh", "<cmd>BufferLineCloseLeft<cr>", { desc = "Close buffers to left" })

-- Window management
map("n", "<leader>v", "<cmd>vsplit<cr>", { desc = "Vertical split" })
map("n", "<leader>s", "<cmd>split<cr>", { desc = "Horizontal split" })
map("n", "<C-Left>", "<cmd>vertical resize -5<cr>", { desc = "Shrink window" })
map("n", "<C-Right>", "<cmd>vertical resize +5<cr>", { desc = "Grow window" })
map("n", "<C-Up>", "<cmd>resize +3<cr>", { desc = "Grow window height" })
map("n", "<C-Down>", "<cmd>resize -3<cr>", { desc = "Grow window height" })

-- AI (Avante)
map("n", "<leader>aa", "<cmd>AvanteAsk<cr>", { desc = "Avante ask" })
map("v", "<leader>aa", "<cmd>AvanteAsk<cr>", { desc = "Avante ask (selection)" })
map("n", "<leader>at", "<cmd>AvanteToggle<cr>", { desc = "Avante toggle" })
map("n", "<leader>ac", "<cmd>AvanteChat<cr>", { desc = "Avante chat" })
map("v", "<leader>ae", "<cmd>AvanteEdit<cr>", { desc = "Avante edit (selection)" })
map("n", "<leader>ar", "<cmd>AvanteRefresh<cr>", { desc = "Avante refresh" })
map("n", "<leader>aS", "<cmd>AvanteStop<cr>", { desc = "Avante stop" })

-- Lazygit
map("n", "<leader>gg", "<cmd>LazyGit<cr>", { desc = "LazyGit" })

-- Persistence (sessions)
map("n", "<leader>qs", function() require("persistence").load() end, { desc = "Restore session (cwd)" })
map("n", "<leader>ql", function() require("persistence").load({ last = true }) end, { desc = "Restore last session" })
map("n", "<leader>qd", function() require("persistence").stop() end, { desc = "Stop session recording" })

-- Zen mode
map("n", "<leader>z", "<cmd>ZenMode<cr>", { desc = "Zen Mode" })

-- === QoL ===

-- Navigate splits with Ctrl+hjkl (no Ctrl+w prefix needed)
map("n", "<C-h>", "<C-w>h", { desc = "Focus left split" })
map("n", "<C-j>", "<C-w>j", { desc = "Focus below split" })
map("n", "<C-k>", "<C-w>k", { desc = "Focus above split" })
map("n", "<C-l>", "<C-w>l", { desc = "Focus right split" })

-- Quick close window
map("n", "<leader>q", function()
  local wins = vim.iter(vim.api.nvim_tabpage_list_wins(0)):filter(function(w)
    local buf = vim.api.nvim_win_get_buf(w)
    return vim.bo[buf].filetype ~= "neo-tree"
  end):totable()
  if #wins <= 1 then
    -- last file window: close the buffer instead of the window
    vim.cmd("enew")
  else
    vim.cmd("close")
  end
end, { desc = "Close window" })
map("n", "<leader>o", "<cmd>only<cr>", { desc = "Unsplit (keep only this window)" })

-- Esc clears search highlights
map("n", "<Esc>", "<cmd>nohlsearch<cr>", { desc = "Clear search highlight" })

-- Esc exits terminal mode
map("t", "<Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- Move selected lines up/down with Alt+j/k
map("v", "<A-j>", ":m '>+1<cr>gv=gv", { desc = "Move selection down" })
map("v", "<A-k>", ":m '<-2<cr>gv=gv", { desc = "Move selection up" })

-- Keep visual selection when indenting
map("v", "<", "<gv", { desc = "Indent left and reselect" })
map("v", ">", ">gv", { desc = "Indent right and reselect" })

-- Centered scrolling (cursor stays mid-screen)
map("n", "<C-d>", "<C-d>zz", { desc = "Scroll down (centered)" })
map("n", "<C-u>", "<C-u>zz", { desc = "Scroll up (centered)" })
map("n", "n", "nzzzv", { desc = "Next search result (centered)" })
map("n", "N", "Nzzzv", { desc = "Prev search result (centered)" })

-- Highlight on yank (brief flash)
vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function() vim.highlight.on_yank({ timeout = 200 }) end,
})

-- Remember cursor position when reopening files
vim.api.nvim_create_autocmd("BufReadPost", {
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    if mark[1] > 0 and mark[1] <= vim.api.nvim_buf_line_count(0) then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- Strip trailing whitespace on save
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*",
  callback = function()
    local pos = vim.api.nvim_win_get_cursor(0)
    vim.cmd([[%s/\s\+$//e]])
    pcall(vim.api.nvim_win_set_cursor, 0, pos)
  end,
})
