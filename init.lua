-- ==========================================
-- 1. CORE SETTINGS
-- ==========================================
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.g.have_nerd_font = true

-- UI Options
vim.o.number = true
vim.o.relativenumber = true
vim.o.mouse = 'a'
vim.o.showmode = false
vim.o.breakindent = true
vim.o.cursorline = true
vim.o.scrolloff = 10
vim.o.signcolumn = 'yes'
vim.o.splitright = true
vim.o.splitbelow = true
vim.o.termguicolors = true
vim.o.colorcolumn = '100'     -- Visual ruler at 100 chars
vim.o.list = true              -- Show whitespace characters
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

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

-- Better up/down on wrapped lines
vim.keymap.set({ 'n', 'x' }, 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
vim.keymap.set({ 'n', 'x' }, 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })

-- Move selected lines up/down in visual mode
vim.keymap.set('v', 'J', ":m '>+1<CR>gv=gv", { desc = 'Move selection down' })
vim.keymap.set('v', 'K', ":m '<-2<CR>gv=gv", { desc = 'Move selection up' })

-- Keep cursor centered when jumping
vim.keymap.set('n', '<C-d>', '<C-d>zz')
vim.keymap.set('n', '<C-u>', '<C-u>zz')
vim.keymap.set('n', 'n', 'nzzzv')
vim.keymap.set('n', 'N', 'Nzzzv')

-- Window Navigation
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Focus left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Focus right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Focus lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Focus upper window' })

-- Window resizing
vim.keymap.set('n', '<C-Left>',  '<C-w><', { desc = 'Shrink window width' })
vim.keymap.set('n', '<C-Right>', '<C-w>>', { desc = 'Expand window width' })
vim.keymap.set('n', '<C-Up>',    '<C-w>+', { desc = 'Expand window height' })
vim.keymap.set('n', '<C-Down>',  '<C-w>-', { desc = 'Shrink window height' })

-- Buffer navigation
vim.keymap.set('n', '<S-l>', '<cmd>bnext<CR>',     { desc = 'Next buffer' })
vim.keymap.set('n', '<S-h>', '<cmd>bprevious<CR>', { desc = 'Prev buffer' })
vim.keymap.set('n', '<leader>bd', '<cmd>bdelete<CR>', { desc = '[B]uffer [D]elete' })

-- Paste without losing register
vim.keymap.set('x', '<leader>p', '"_dP', { desc = 'Paste without overwriting register' })

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
        style = "moon",
        transparent = true,
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
          bottom_search = true,
          command_palette = true,
          long_message_to_split = true,
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
          globalstatus = true,
        },
        sections = {
          lualine_a = { 'mode' },
          lualine_b = { 'branch', 'diff', 'diagnostics' },
          lualine_c = { 'filename' },
          lualine_x = { 'filetype' },
          lualine_y = { 'progress' },
          lualine_z = { 'location' }
        },
      }
    end
  },

  { -- Keybind Cheatsheet
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      icons = { mappings = vim.g.have_nerd_font },
    },
    keys = {
      { "<leader>?", function() require("which-key").show({ global = false }) end, desc = "Buffer Keymaps (which-key)" },
    },
  },

  { -- Git signs in the gutter + blame
    'lewis6991/gitsigns.nvim',
    opts = {
      signs = {
        add          = { text = '▎' },
        change       = { text = '▎' },
        delete       = { text = '' },
        topdelete    = { text = '' },
        changedelete = { text = '▎' },
      },
      on_attach = function(bufnr)
        local gs = require('gitsigns')
        local map = function(mode, l, r, desc)
          vim.keymap.set(mode, l, r, { buffer = bufnr, desc = 'Git: ' .. desc })
        end
        map('n', ']c', gs.next_hunk,          'Next hunk')
        map('n', '[c', gs.prev_hunk,          'Prev hunk')
        map('n', '<leader>gb', gs.blame_line, '[G]it [B]lame line')
        map('n', '<leader>gp', gs.preview_hunk, '[G]it [P]review hunk')
        map('n', '<leader>gr', gs.reset_hunk,   '[G]it [R]eset hunk')
        map('n', '<leader>gs', gs.stage_hunk,   '[G]it [S]tage hunk')
      end
    },
  },

  { -- Highlighted TODO / FIXME / NOTE comments
    "folke/todo-comments.nvim",
    event = "VimEnter",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = { signs = true },
    keys = {
      { "<leader>st", "<cmd>TodoTelescope<cr>", desc = "[S]earch [T]ODOs" },
      { "]t", function() require("todo-comments").jump_next() end, desc = "Next TODO" },
      { "[t", function() require("todo-comments").jump_prev() end, desc = "Prev TODO" },
    },
  },

  { -- Better diagnostics list
    "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    keys = {
      { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>",              desc = "Diagnostics (Trouble)" },
      { "<leader>xb", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Buffer Diagnostics (Trouble)" },
    },
    opts = {},
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

  -- NEW: Visual indent guides — especially useful for Python
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    event = "BufReadPost",
    opts = {
      indent = { char = "│" },
      scope = { enabled = true, show_start = false },
      exclude = { filetypes = { "help", "lazy", "mason", "notify", "toggleterm" } },
    },
  },

  -- NEW: Show current function/class context at top of screen (great for long R/Python files)
  {
    "nvim-treesitter/nvim-treesitter-context",
    event = "BufReadPost",
    opts = {
      max_lines = 3,         -- max lines of context shown
      min_window_height = 20,
      mode = "cursor",
    },
    keys = {
      { "<leader>tc", "<cmd>TSContextToggle<cr>", desc = "[T]oggle [C]ontext" },
    },
  },

  -- NEW: Oil.nvim — edit the filesystem like a buffer (open with <leader>o or -)
  {
    "stevearc/oil.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    keys = {
      { "<leader>o", "<cmd>Oil<cr>",           desc = "[O]il file explorer" },
      { "-",         "<cmd>Oil<cr>",           desc = "Open parent directory" },
    },
    opts = {
      default_file_explorer = true,
      columns = { "icon", "permissions", "size", "mtime" },
      view_options = { show_hidden = true },
      -- Keys inside the oil buffer
      keymaps = {
        ["<CR>"]  = "actions.select",
        ["-"]     = "actions.parent",
        ["_"]     = "actions.open_cwd",
        ["gs"]    = "actions.change_sort",
        ["gx"]    = "actions.open_external",
        ["g."]    = "actions.toggle_hidden",
      },
    },
  },

  -- ==========================================
  -- B. EDITING ENHANCEMENTS
  -- ==========================================

  { -- Auto-close brackets, quotes, parens
    'windwp/nvim-autopairs',
    event = 'InsertEnter',
    config = function()
      local autopairs = require('nvim-autopairs')
      autopairs.setup { check_ts = true }
      local cmp_autopairs = require('nvim-autopairs.completion.cmp')
      require('cmp').event:on('confirm_done', cmp_autopairs.on_confirm_done())
    end,
  },

  { -- Surround text objects: ys, cs, ds
    "kylechui/nvim-surround",
    event = "VeryLazy",
    opts = {},
  },

  { -- Better commenting: gc + motion
    'numToStr/Comment.nvim',
    event = 'VeryLazy',
    opts = {},
  },

  { -- Highlight matching bracket/paren
    'andymass/vim-matchup',
    event = 'BufReadPost',
    init = function() vim.g.matchup_matchparen_offscreen = { method = 'popup' } end,
  },

  -- ==========================================
  -- C. DOMAIN SPECIFIC (LaTeX, R, Python, Quarto)
  -- ==========================================

  {
    "lervag/vimtex",
    lazy = false,
    ft = { "tex", "bib" },
    init = function()
      vim.g.vimtex_view_method = 'skim'
      vim.g.vimtex_view_skim_sync = 1
      vim.g.vimtex_view_skim_activate = 1

      vim.g.vimtex_compiler_method = 'latexmk'
      vim.g.vimtex_compiler_latexmk = {
        aux_dir = '.aux',
        out_dir = '.out',
        callback = 1,
        continuous = 1,
        executable = 'latexmk',
        options = {
          '-pdf',
          '-shell-escape',
          '-verbose',
          '-file-line-error',
          '-synctex=1',
          '-interaction=nonstopmode',
        },
      }

      vim.g.vimtex_syntax_enabled = 1
      vim.opt.conceallevel = 2
      vim.g.vimtex_syntax_conceal = {
        accents = 1,
        ligatures = 1,
        cites = 1,
        fancy = 1,
        greek = 1,
        math_bounds = 1,
        math_delimiters = 1,
        math_fracs = 1,
        math_super_sub = 1,
        math_symbols = 1,
        sections = 0,
        styles = 1,
      }

      vim.g.vimtex_toc_config = {
        split_pos = 'left',
        split_width = 30,
        show_help = 0,
      }

      vim.g.vimtex_quickfix_mode = 2
      vim.g.vimtex_quickfix_open_on_warning = 0
      vim.g.vimtex_imaps_enabled = 0
      vim.g.vimtex_complete_enabled = 1
    end,
  },

  { -- Live Browser Markdown Preview
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    build = "cd app && yarn install && git restore .",
    init = function() vim.g.mkdp_filetypes = { "markdown" } end,
    ft = { "markdown" },
  },

  { -- In-Editor Markdown Rendering
    'MeanderingProgrammer/render-markdown.nvim',
    dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' },
    opts = {},
    ft = { "markdown", "quarto" },
  },

  -- NEW: Send code to R/Python REPL without leaving Neovim
  -- Usage: <leader>sl = send line, <leader>sc = send motion, <leader>sf = send file
  -- <leader>rs = open REPL, <leader>rq = close REPL
  {
    "Vigemus/iron.nvim",
    keys = {
      { "<leader>rs", "<cmd>IronRepl<cr>",    desc = "[R]epl [S]tart" },
      { "<leader>rr", "<cmd>IronRestart<cr>", desc = "[R]epl [R]estart" },
      { "<leader>rq", "<cmd>IronHide<cr>",    desc = "[R]epl [Q]uit/Hide" },
      { "<leader>rf", "<cmd>IronFocus<cr>",   desc = "[R]epl [F]ocus" },
    },
    config = function()
      require("iron.core").setup({
        config = {
          -- Detect filetype automatically; falls back to python
          scratch_repl = true,
          repl_definition = {
            python = {
              -- Uses ipython if available, falls back to python3
              command = function()
                local ipython = vim.fn.executable("ipython") == 1
                return ipython and { "ipython", "--no-autoindent" } or { "python3" }
              end,
            },
            r = { command = { "R" } },
          },
          -- Open REPL as a vertical split on the right (40% width)
          repl_open_cmd = require("iron.view").right("40%"),
        },
        keymaps = {
          send_motion   = "<leader>sc",  -- e.g. <leader>scip sends paragraph
          visual_send   = "<leader>sc",  -- send visual selection
          send_file     = "<leader>sf",  -- send entire file
          send_line     = "<leader>sl",  -- send current line
          send_paragraph= "<leader>sp",  -- send paragraph (great for R/Python blocks)
          send_until_cursor = "<leader>su", -- send from top to cursor
          cr            = "<leader>s<cr>",
          interrupt     = "<leader>s<space>",
          exit          = "<leader>sq",
          clear         = "<leader>sc",
        },
        highlight = { italic = true },
        ignore_blank_lines = true,
      })
    end,
  },

  -- NEW: Quarto — notebook-style .qmd editing with LSP in code cells
  -- Run cells with iron.nvim, get completions/diagnostics per language
  {
    "quarto-dev/quarto-nvim",
    ft = { "quarto" },
    dependencies = {
      -- otter.nvim: injects LSP into code chunks inside .qmd files
      {
        "jmbuhr/otter.nvim",
        opts = {
          lsp = { diagnostic_update_events = { "BufWritePost" } },
          buffers = { set_filetype = true },
        },
      },
    },
    config = function()
      require("quarto").setup({
        debug = false,
        closePreviewOnExit = true,
        lspFeatures = {
          enabled = true,
          chunks = "all",
          languages = { "python", "r", "julia", "bash" },
          diagnostics = { enabled = true, triggers = { "BufWritePost" } },
          completion = { enabled = true },
        },
        codeRunner = {
          enabled = true,
          default_method = "iron",  -- uses iron.nvim to run cells
          ft_runners = {
            python = "iron",
            r      = "iron",
          },
        },
        keymap = {
          -- <leader>qr = run cell, <leader>qa = run all, <leader>qp = run to cursor
          hover         = "K",
          definition    = "gd",
          rename        = "<leader>rn",
          references    = "gr",
          format        = "<leader>f",
          run_cell              = "<leader>qr",
          run_above             = "<leader>qu",
          run_below             = "<leader>qd",
          run_all               = "<leader>qa",
          run_line              = "<leader>ql",
          run_range             = "<leader>qr",
          goto_prev_cell        = "[q",
          goto_next_cell        = "]q",
        },
      })
    end,
  },

  -- ==========================================
  -- D. LSP & CORE UTILS
  -- ==========================================

  { -- Telescope (Fuzzy Finder)
    'nvim-telescope/telescope.nvim',
    event = 'VimEnter',
    dependencies = {
      'nvim-lua/plenary.nvim',
      { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
    },
    config = function()
      require('telescope').setup {
        defaults = {
          path_display = { 'truncate' },
          sorting_strategy = 'ascending',
          layout_config = { prompt_position = 'top' },
        }
      }
      require('telescope').load_extension('fzf')

      local builtin = require 'telescope.builtin'
      vim.keymap.set('n', '<leader>sf', builtin.find_files,  { desc = '[S]earch [F]iles' })
      vim.keymap.set('n', '<leader>sg', builtin.live_grep,   { desc = '[S]earch by [G]rep' })
      vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
      vim.keymap.set('n', '<leader>sr', builtin.oldfiles,    { desc = '[S]earch [R]ecent files' })
      vim.keymap.set('n', '<leader>sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })
      vim.keymap.set('n', '<leader>sk', builtin.keymaps,     { desc = '[S]earch [K]eymaps' })
      vim.keymap.set('n', '<leader><leader>', builtin.buffers, { desc = '[ ] Find existing buffers' })
      vim.keymap.set('n', '<leader>/', builtin.current_buffer_fuzzy_find, { desc = '[/] Fuzzy search buffer' })
    end,
  },

  { -- Treesitter (Syntax Highlighting + Text Objects)
    'nvim-treesitter/nvim-treesitter',
    branch = 'master',
    build = ':TSUpdate',
    dependencies = {
      'nvim-treesitter/nvim-treesitter-textobjects',
    },
    config = function()
      require('nvim-treesitter.configs').setup({
        ensure_installed = {
          'bash', 'c', 'cpp', 'html', 'lua', 'markdown', 'markdown_inline',
          'python', 'r', 'vim', 'vimdoc', 'latex',
        },
        highlight = { enable = true },
        indent = { enable = true },
        textobjects = {
          select = {
            enable = true,
            lookahead = true,
            keymaps = {
              ['af'] = '@function.outer',
              ['if'] = '@function.inner',
              ['ac'] = '@class.outer',
              ['ic'] = '@class.inner',
              ['aa'] = '@parameter.outer',
              ['ia'] = '@parameter.inner',
            },
          },
          move = {
            enable = true,
            set_jumps = true,
            goto_next_start     = { [']f'] = '@function.outer', [']c'] = '@class.outer' },
            goto_previous_start = { ['[f'] = '@function.outer', ['[c'] = '@class.outer' },
          },
        },
      })
    end,
  },

  { -- Autoformat
    'stevearc/conform.nvim',
    keys = {
      { '<leader>f', function() require('conform').format { async = true, lsp_format = 'fallback' } end, mode = '', desc = '[F]ormat buffer' }
    },
    opts = {
      format_on_save = { timeout_ms = 500, lsp_format = 'fallback' },
      formatters_by_ft = {
        lua    = { 'stylua' },
        -- CHANGED: use ruff_format instead of black+isort (you already have ruff LSP;
        -- this is faster and keeps everything consistent — ruff handles imports too)
        python = { 'ruff_format', 'ruff_organize_imports' },
        r      = { 'styler' },  -- NEW: R formatter (install with: install.packages("styler"))
      },
    },
  },

  { -- Autocompletion
    'hrsh7th/nvim-cmp',
    event = 'InsertEnter',
    dependencies = {
      {
        'L3MON4D3/LuaSnip',
        build = (function()
          if vim.fn.has 'win32' == 1 or vim.fn.executable 'make' == 0 then return end
          return 'make install_jsregexp'
        end)(),
        dependencies = {
          {
            'rafamadriz/friendly-snippets',
            config = function()
              require('luasnip.loaders.from_vscode').lazy_load({ exclude = { "tex" } })
            end,
          },
        },
      },
      'saadparwaiz1/cmp_luasnip',
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-omni',
    },
    config = function()
      local cmp = require 'cmp'
      local luasnip = require 'luasnip'
      luasnip.config.setup {}

      -- ==========================================
      -- Custom LaTeX Snippets
      -- ==========================================
      luasnip.add_snippets("tex", {
        luasnip.snippet("beq", {
          luasnip.text_node({ "\\begin{equation}", "\t" }),
          luasnip.insert_node(1),
          luasnip.text_node({ "", "\\end{equation}" })
        }),
        luasnip.snippet("bth", {
          luasnip.text_node({ "\\begin{theorem}", "\t" }),
          luasnip.insert_node(1),
          luasnip.text_node({ "", "\\end{theorem}" })
        }),
        -- FIXED: was "\\begi{lemma}" (typo), now "\\begin{lemma}"
        luasnip.snippet("ble", {
          luasnip.text_node({ "\\begin{lemma}", "\t" }),
          luasnip.insert_node(1),
          luasnip.text_node({ "", "\\end{lemma}" })
        }),
        luasnip.snippet("bpf", {
          luasnip.text_node({ "\\begin{proof}", "\t" }),
          luasnip.insert_node(1),
          luasnip.text_node({ "", "\\end{proof}" })
        }),
        luasnip.snippet("im", {
          luasnip.text_node("\\( "),
          luasnip.insert_node(1),
          luasnip.text_node(" \\)")
        }),
        luasnip.snippet("dm", {
          luasnip.text_node({ "\\[", "\t" }),
          luasnip.insert_node(1),
          luasnip.text_node({ "", "\\]" })
        }),
        luasnip.snippet("bit", {
          luasnip.text_node({ "\\begin{itemize}", "\t\\item " }),
          luasnip.insert_node(1),
          luasnip.text_node({ "", "\\end{itemize}" })
        }),
        luasnip.snippet("frac", {
          luasnip.text_node("\\frac{"),
          luasnip.insert_node(1),
          luasnip.text_node("}{"),
          luasnip.insert_node(2),
          luasnip.text_node("}")
        }),
        -- NEW: Common math snippets for statistics/probability work
        luasnip.snippet("bpr", {   -- proposition
          luasnip.text_node({ "\\begin{proposition}", "\t" }),
          luasnip.insert_node(1),
          luasnip.text_node({ "", "\\end{proposition}" })
        }),
        luasnip.snippet("bco", {   -- corollary
          luasnip.text_node({ "\\begin{corollary}", "\t" }),
          luasnip.insert_node(1),
          luasnip.text_node({ "", "\\end{corollary}" })
        }),
        luasnip.snippet("bde", {   -- definition
          luasnip.text_node({ "\\begin{definition}", "\t" }),
          luasnip.insert_node(1),
          luasnip.text_node({ "", "\\end{definition}" })
        }),
        luasnip.snippet("bal", {   -- align*
          luasnip.text_node({ "\\begin{align*}", "\t" }),
          luasnip.insert_node(1),
          luasnip.text_node({ "", "\\end{align*}" })
        }),
        luasnip.snippet("EE", {    -- expectation E[X]
          luasnip.text_node("\\mathbb{E}\\left["),
          luasnip.insert_node(1),
          luasnip.text_node("\\right]")
        }),
        luasnip.snippet("PP", {    -- probability P(A)
          luasnip.text_node("\\mathbb{P}\\left("),
          luasnip.insert_node(1),
          luasnip.text_node("\\right)")
        }),
        luasnip.snippet("VV", {    -- variance Var[X]
          luasnip.text_node("\\text{Var}\\left["),
          luasnip.insert_node(1),
          luasnip.text_node("\\right]")
        }),
        luasnip.snippet("iid", {
          luasnip.text_node("\\overset{\\text{iid}}{\\sim}")
        }),
        luasnip.snippet("sum", {   -- sum with limits
          luasnip.text_node("\\sum_{"),
          luasnip.insert_node(1, "i=1"),
          luasnip.text_node("}^{"),
          luasnip.insert_node(2, "n"),
          luasnip.text_node("}")
        }),
      })
      -- ==========================================

      cmp.setup {
        snippet = {
          expand = function(args) luasnip.lsp_expand(args.body) end,
        },
        completion = { completeopt = 'menu,menuone,noinsert' },
        mapping = cmp.mapping.preset.insert {
          ['<C-n>']     = cmp.mapping.select_next_item(),
          ['<C-p>']     = cmp.mapping.select_prev_item(),
          ['<C-b>']     = cmp.mapping.scroll_docs(-4),
          ['<C-f>']     = cmp.mapping.scroll_docs(4),
          ['<C-y>']     = cmp.mapping.confirm { select = true },
          ['<CR>']      = cmp.mapping.confirm { select = true },
          ['<C-Space>'] = cmp.mapping.complete {},
          ['<C-e>']     = cmp.mapping.abort(),

          ['<Tab>'] = cmp.mapping(function(fallback)
            if luasnip.expand_or_locally_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { 'i', 's' }),
          ['<S-Tab>'] = cmp.mapping(function(fallback)
            if luasnip.locally_jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { 'i', 's' }),
        },
        sources = {
          { name = 'nvim_lsp', priority = 1000 },
          { name = 'luasnip',  priority = 750 },
          { name = 'path',     priority = 250 },
        },
        formatting = {
          format = function(entry, vim_item)
            vim_item.menu = ({
              nvim_lsp = '[LSP]',
              luasnip  = '[Snip]',
              path     = '[Path]',
              omni     = '[VimTeX]',
            })[entry.source.name]
            return vim_item
          end,
        },
      }

      cmp.setup.filetype({ "tex" }, {
        sources = {
          { name = 'omni',     priority = 1000 },
          { name = 'luasnip',  priority = 900 },
          { name = 'nvim_lsp', priority = 750 },
          { name = 'path',     priority = 250 },
        }
      })
    end,
  },

  { -- LSP Configuration
    'neovim/nvim-lspconfig',
    dependencies = {
      { 'mason-org/mason.nvim', opts = {} },
      'mason-org/mason-lspconfig.nvim',
      'WhoIsSethDaniel/mason-tool-installer.nvim',
    },
    config = function()
      vim.diagnostic.config({
        virtual_text = { prefix = '●' },
        float = { border = 'rounded', source = true },
        signs = true,
        underline = true,
        update_in_insert = false,
        severity_sort = true,
      })

      vim.api.nvim_create_autocmd('LspAttach', {
        callback = function(event)
          local map = function(keys, func, desc)
            vim.keymap.set('n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
          end
          local builtin = require('telescope.builtin')

          map('gd',         vim.lsp.buf.definition,    '[G]oto [D]efinition')
          map('gD',         vim.lsp.buf.declaration,   '[G]oto [D]eclaration')
          map('gr',         builtin.lsp_references,    '[G]oto [R]eferences')
          map('gi',         vim.lsp.buf.implementation,'[G]oto [I]mplementation')
          map('K',          vim.lsp.buf.hover,         'Hover Documentation')
          map('<leader>rn', vim.lsp.buf.rename,        '[R]e[n]ame symbol')
          map('<leader>ca', vim.lsp.buf.code_action,   '[C]ode [A]ction')
          map('<leader>D',  vim.lsp.buf.type_definition, 'Type [D]efinition')
          map('<leader>ds', builtin.lsp_document_symbols,  '[D]ocument [S]ymbols')
          map('<leader>ws', builtin.lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')

          map(']d', function() vim.diagnostic.goto_next({ float = true }) end, 'Next Diagnostic')
          map('[d', function() vim.diagnostic.goto_prev({ float = true }) end, 'Prev Diagnostic')
        end,
      })

      local servers = {
        pyright  = {},
        julials  = {},
        ruff     = {},
        clangd   = {},
        r_language_server = {},
        marksman = {},
        texlab   = {},
        lua_ls   = {
          settings = {
            Lua = {
              diagnostics = { globals = { 'vim' } },
              workspace   = { checkThirdParty = false },
              telemetry   = { enable = false },
            }
          }
        },
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
