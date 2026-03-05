-- ==========================================
-- 1. CORE SETTINGS (Clean & Focused)
-- ==========================================
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.g.have_nerd_font = true -- Set to true for beautiful icons!

-- UI Options
vim.o.number = true
vim.o.relativenumber = true -- Great for jumping around code
vim.o.mouse = 'a'
vim.o.showmode = false      -- Hidden because Lualine shows it
vim.o.breakindent = true
vim.o.cursorline = true
vim.o.scrolloff = 10        -- Keep context around the cursor
vim.o.signcolumn = 'yes'
vim.o.splitright = true
vim.o.splitbelow = true
vim.o.termguicolors = true

-- System & Search
vim.schedule(function() vim.o.clipboard = 'unnamedplus' end)
vim.o.undofile = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.updatetime = 250
vim.o.timeoutlen = 300
vim.o.inccommand = 'split'

-- ==========================================
-- 2. BASIC KEYMAPS
-- ==========================================
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

-- Window Navigation
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Focus left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Focus right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Focus lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Focus upper window' })

-- Highlight on yank
vim.api.nvim_create_autocmd('TextYankPost', {
  group = vim.api.nvim_create_augroup('highlight-yank', { clear = true }),
  callback = function() vim.hl.on_yank() end,
})

-- ==========================================
-- 3. PLUGIN MANAGER (Lazy.nvim)
-- ==========================================
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', 'https://github.com/folke/lazy.nvim.git', lazypath }
end
vim.opt.rtp:prepend(lazypath)

require('lazy').setup({

  -- ==========================================
  -- A. UI & FOCUS PLUGINS
  -- ==========================================
  
  { -- Colorscheme
    'folke/tokyonight.nvim',
    priority = 1000,
    config = function()
      require('tokyonight').setup { 
        style = "moon", -- A slightly softer, less contrasting dark theme
        transparent = true, -- Makes the background transparent for a cleaner look
        styles = { comments = { italic = true }, keywords = { italic = true } } 
      }
      vim.cmd.colorscheme 'tokyonight'
    end,
  },

  { -- Clean Command Line & Notifications
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = { "MunifTanjim/nui.nvim", "rcarriga/nvim-notify" },
    config = function()
      require("noice").setup({
        lsp = {
          override = {
            ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
            ["vim.lsp.util.stylize_markdown"] = true,
            ["cmp.entry.get_documentation"] = true,
          },
        },
        presets = {
          bottom_search = true, -- uses a classic bottom cmdline for search
          command_palette = true, -- position the cmdline and popupmenu together
          long_message_to_split = true, -- long messages will be sent to a split
          inc_rename = false, 
          lsp_doc_border = true, 
        },
      })
    end
  },

  { -- Minimal Status Line
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      require('lualine').setup {
        options = {
          theme = 'auto',
          component_separators = '|',
          section_separators = '',
          globalstatus = true, -- Use one single statusline for all splits
        },
        sections = {
          lualine_a = {'mode'},
          lualine_b = {'branch', 'diff', 'diagnostics'},
          lualine_c = {'filename'},
          lualine_x = {'filetype'},
          lualine_y = {'progress'},
          lualine_z = {'location'}
        },
      }
    end
  },

  { -- Distraction Free Coding
    "folke/zen-mode.nvim",
    dependencies = { "folke/twilight.nvim" },
    keys = {
      { "<leader>z", "<cmd>ZenMode<cr>", desc = "Toggle [Z]en Mode" },
    },
    opts = {
      window = { width = 100, options = { number = false, relativenumber = false, signcolumn = "no" } },
      plugins = { twilight = { enabled = true }, gitsigns = { enabled = false } },
    }
  },

  { "folke/twilight.nvim", opts = { context = 15 } },

  -- ==========================================
  -- B. DOMAIN SPECIFIC (LaTeX, R, Markdown)
  -- ==========================================

  { -- LaTeX
    "lervag/vimtex",
    lazy = false, 
    init = function()
      vim.g.vimtex_view_method = 'zathura'
      vim.g.vimtex_compiler_method = 'latexmk'
    end,
  },

  { -- R Console Integration
    "R-nvim/R.nvim",
    lazy = false,
    config = function()
      require("r").setup({})
    end,
  },

 { -- Live Browser Markdown Preview
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    -- This installs the dependencies, then instantly resets the git tracking so Lazy doesn't panic!
    build = "cd app && yarn install && git restore .", 
    init = function() vim.g.mkdp_filetypes = { "markdown" } end,
    ft = { "markdown" },
  },

  { -- In-Editor Markdown Rendering (Makes MD look beautiful natively)
    'MeanderingProgrammer/render-markdown.nvim',
    dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' },
    opts = {},
    ft = { "markdown", "quarto" },
  },

  -- ==========================================
  -- C. LSP & CORE UTILS (Python, C++, etc)
  -- ==========================================

  { -- Telescope (Fuzzy Finder)
    'nvim-telescope/telescope.nvim',
    event = 'VimEnter',
    dependencies = { 'nvim-lua/plenary.nvim', { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' } },
    config = function()
      local builtin = require 'telescope.builtin'
      vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = '[S]earch [F]iles' })
      vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = '[S]earch by [G]rep' })
      vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
      vim.keymap.set('n', '<leader><leader>', builtin.buffers, { desc = '[ ] Find existing buffers' })
    end,
  },

  { -- Treesitter (Syntax Highlighting)
    'nvim-treesitter/nvim-treesitter',
    branch = 'master', -- THIS IS THE MAGIC FIX!
    build = ':TSUpdate',
    config = function()
      require('nvim-treesitter.configs').setup({
        ensure_installed = { 'bash', 'c', 'cpp', 'html', 'lua', 'markdown', 'markdown_inline', 'python', 'r', 'vim', 'vimdoc' },
        highlight = { enable = true },
        indent = { enable = true },
      })
    end,
  },

  { -- Autoformat (Conform)
    'stevearc/conform.nvim',
    keys = { { '<leader>f', function() require('conform').format { async = true, lsp_format = 'fallback' } end, mode = '', desc = '[F]ormat buffer' } },
    opts = {
      format_on_save = { timeout_ms = 500, lsp_format = 'fallback' },
      formatters_by_ft = { lua = { 'stylua' }, python = { "isort", "black" } },
    },
  },

  { -- Autocompletion (Blink.cmp)
    'saghen/blink.cmp',
    version = '1.*',
    dependencies = { 'L3MON4D3/LuaSnip' },
    opts = {
      keymap = { preset = 'default' },
      appearance = { nerd_font_variant = 'mono' },
      completion = { documentation = { auto_show = true, auto_show_delay_ms = 500 } },
      sources = { default = { 'lsp', 'path', 'snippets', 'buffer' } },
      signature = { enabled = true },
    },
  },

  { -- LSP Configuration
    'neovim/nvim-lspconfig',
    dependencies = {
      { 'mason-org/mason.nvim', opts = {} },
      'mason-org/mason-lspconfig.nvim',
      'WhoIsSethDaniel/mason-tool-installer.nvim',
    },
    config = function()
      -- LSP Keybinds
      vim.api.nvim_create_autocmd('LspAttach', {
        callback = function(event)
          local map = function(keys, func, desc)
            vim.keymap.set('n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
          end
          map('gd', vim.lsp.buf.definition, '[G]oto [D]efinition')
          map('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
          map('K', vim.lsp.buf.hover, 'Hover Documentation')
          map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
        end,
      })

      -- Setup Language Servers
      local servers = {
        pyright = {},
        ruff = {},
        clangd = {},
        r_language_server = {},
        marksman = {},
        texlab = {},
        lua_ls = { settings = { Lua = { diagnostics = { globals = { 'vim' } } } } },
      }

      require('mason-tool-installer').setup { ensure_installed = vim.tbl_keys(servers) }
      require('mason-lspconfig').setup {
        handlers = {
          function(server_name)
            require('lspconfig')[server_name].setup(servers[server_name] or {})
          end,
        },
      }
    end,
  },

})