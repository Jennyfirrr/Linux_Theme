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
    "ahmedkhalf/project.nvim",
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

  { "stevearc/aerial.nvim",                    opts = {} },
  { "nvim-treesitter/nvim-treesitter-context", opts = {} },

  -- Neotest core + C/C++ adapters (pick one adapter)
  { "nvim-neotest/neotest",                    dependencies = { "nvim-lua/plenary.nvim", "nvim-treesitter/nvim-treesitter", "nvim-neotest/nvim-nio" } },
  { "alfaix/neotest-gtest" },  -- GoogleTest
  { "orjangj/neotest-ctest" }, -- CTest (GTest/Catch2/doctest)

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

--
-- Lualine theme sync
require("lualine").setup({ options = { theme = "tokyonight" } })

-- Treesitter
require("nvim-treesitter.configs").setup({
  ensure_installed = { "lua", "python", "c", "cpp", "bash", "json", "yaml", "markdown", "vim", "vimdoc", "java", "javadoc" },
  highlight = { enable = true },
  incremental_selection = { enable = true },
  indent = { enable = true },
})

-- Mason (LSP installer)
require("mason").setup()
require("mason-lspconfig").setup({
  ensure_installed = { "lua_ls", "pyright", "clangd", "bashls", "jsonls", "yamlls" },
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
lsp.enable({ "pyright", "clangd", "bashls", "jsonls", "yamlls", "lua_ls" })

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
