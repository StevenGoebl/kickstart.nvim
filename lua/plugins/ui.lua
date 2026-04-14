-- ==========================================
-- UI & FOCUS PLUGINS
-- ==========================================
return {

  { -- Colorscheme
    'folke/tokyonight.nvim',
    priority = 1000,
    config = function()
      require('tokyonight').setup {
        style = "moon",
        transparent = true,
        styles = { comments = { italic = true }, keywords = { italic = true } },
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
    end,
  },
  {
    "kdheepak/lazygit.nvim", 
    dependencies = { "nvim-lua/plenary.nvim"}, 
    keys = {
	{ "<leader>gg", "<cmd>LazyGit<cr>", desc = "[G]it La[g]y"}, 
	}, 
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
          lualine_z = { 'location' },
        },
      }
    end,
  },

  { -- Keybind Cheatsheet
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = { icons = { mappings = vim.g.have_nerd_font } },
    keys = {
      {
        "<leader>?",
        function() require("which-key").show({ global = false }) end,
        desc = "Buffer Keymaps (which-key)",
      },
    },
    config = function(_, opts)
      local wk = require("which-key")
      wk.setup(opts)
      wk.add({
        { '<leader>g', group = '[G]it' },
        { '<leader>s', group = '[S]earch' },
        { '<leader>d', group = '[D]ev / Devtools' },
        { '<leader>e', group = '[E]xecute (Iron)' },
        { '<leader>i', group = '[I]ron REPL' },
        { '<leader>r', group = '[R]ename / Rust' },
        { '<leader>q', group = '[Q]uarto' },
        { '<leader>x', group = 'Trouble [X]' },
        { '<leader>t', group = '[T]oggle' },
        { '<leader>b', group = '[B]uffer' },
        { '<leader>c', group = '[C]langd' },
        { '<leader>w', group = '[W]orkspace' },
      })
    end,
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
        -- FIX: ]c/[c were conflicting with treesitter class nav.
        -- Gitsigns keeps ]c/[c (hunk navigation is more frequent).
        map('n', ']c',          gs.next_hunk,       'Next hunk')
        map('n', '[c',          gs.prev_hunk,       'Prev hunk')
        map('n', '<leader>gb',  gs.blame_line,      '[G]it [B]lame line')
        map('n', '<leader>gp',  gs.preview_hunk,    '[G]it [P]review hunk')
        -- FIX: was <leader>gr — too easy to confuse with `gr` (LSP references).
        map('n', '<leader>gR',  gs.reset_hunk,      '[G]it [R]eset hunk')
        map('n', '<leader>gs',  gs.stage_hunk,      '[G]it [S]tage hunk')
        map('n', '<leader>gu',  gs.undo_stage_hunk, '[G]it [U]ndo stage hunk')
      end,
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
      window = {
        width = 100,
        options = { number = false, relativenumber = false, signcolumn = "no" },
      },
      plugins = { twilight = { enabled = true }, gitsigns = { enabled = false } },
    },
  },

  { "folke/twilight.nvim", opts = { context = 15 } },

  { -- Visual indent guides
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    event = "BufReadPost",
    opts = {
      indent = { char = "│" },
      scope = { enabled = true, show_start = false },
      exclude = { filetypes = { "help", "lazy", "mason", "notify", "toggleterm" } },
    },
  },

  { -- Show current function/class context at top of screen
    "nvim-treesitter/nvim-treesitter-context",
    event = "BufReadPost",
    opts = { max_lines = 3, min_window_height = 20, mode = "cursor" },
    keys = {
      { "<leader>tc", "<cmd>TSContextToggle<cr>", desc = "[T]oggle [C]ontext" },
    },
  },

  { -- Oil.nvim — edit the filesystem like a buffer
    "stevearc/oil.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    keys = {
      { "<leader>o", "<cmd>Oil<cr>", desc = "[O]il file explorer" },
      { "-",         "<cmd>Oil<cr>", desc = "Open parent directory" },
    },
    opts = {
      default_file_explorer = true,
      columns = { "icon", "permissions", "size", "mtime" },
      view_options = { show_hidden = true },
      keymaps = {
        ["<CR>"] = "actions.select",
        ["-"]    = "actions.parent",
        ["_"]    = "actions.open_cwd",
        ["gs"]   = "actions.change_sort",
        ["gx"]   = "actions.open_external",
        ["g."]   = "actions.toggle_hidden",
      },
    },
  },

  -- FIX: mini.bufremove so <leader>bd keeps the window alive when
  --      deleting a buffer instead of closing the split.
  { 'echasnovski/mini.bufremove', version = '*' },
{
  "stevearc/aerial.nvim",
  dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
  keys = {
    { "<leader>ta", "<cmd>AerialToggle<cr>", desc = "[T]oggle [A]erial outline" },
  },
  opts = {
    backends = { "treesitter", "lsp", "markdown" },
    layout = { min_width = 28 },
    attach_mode = "global",
  },
},
}
