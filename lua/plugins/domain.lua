-- ==========================================
-- DOMAIN SPECIFIC
-- LaTeX, Markdown, R, Python, Quarto, Rust, C++, Julia
-- ==========================================
return {

  { -- LaTeX
    "lervag/vimtex",
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
          '-lualatex', '-shell-escape', '-verbose',
          '-file-line-error', '-synctex=1', '-interaction=nonstopmode',
        },
      }
      vim.g.vimtex_syntax_enabled = 1
      vim.opt.conceallevel = 2
      vim.g.vimtex_syntax_conceal = {
        accents = 1, ligatures = 1, cites = 1, fancy = 1, greek = 1,
        math_bounds = 1, math_delimiters = 1, math_fracs = 1,
        math_super_sub = 1, math_symbols = 1, sections = 0, styles = 1,
      }
      vim.g.vimtex_toc_config         = { split_pos = 'left', split_width = 30, show_help = 0 }
      vim.g.vimtex_quickfix_mode      = 2
      vim.g.vimtex_quickfix_open_on_warning = 0
      vim.g.vimtex_imaps_enabled      = 0
      vim.g.vimtex_complete_enabled   = 1
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

  { -- Send code to R/Python/Julia REPL
    -- Keymap namespace: <leader>e* = execute, <leader>i* = iron REPL management
    "Vigemus/iron.nvim",
    keys = {
      { "<leader>ii", "<cmd>IronRepl<cr>",    desc = "[I]ron REPL start" },
      { "<leader>ir", "<cmd>IronRestart<cr>", desc = "[I]ron [R]estart" },
      { "<leader>ih", "<cmd>IronHide<cr>",    desc = "[I]ron [H]ide" },
      { "<leader>if", "<cmd>IronFocus<cr>",   desc = "[I]ron [F]ocus" },
    },
    config = function()
      require("iron.core").setup({
        config = {
          scratch_repl = true,
          repl_definition = {
            python = {
              command = function()
                return vim.fn.executable("ipython") == 1
                  and { "ipython", "--no-autoindent" }
                  or  { "python3" }
              end,
            },
            r      = { command = { "radian" } },
            quarto = { command = { "radian" } },
            rmd    = { command = { "radian" } },
            julia  = { command = { "julia", "--project" } },
          },
          repl_open_cmd = require("iron.view").right("40%"),
        },
        keymaps = {
          send_motion       = "<leader>em",
          visual_send       = "<leader>em",
          send_file         = "<leader>ef",
          send_line         = "<leader>el",
          send_paragraph    = "<leader>ep",
          send_until_cursor = "<leader>eu",
          cr                = "<leader>e<cr>",
          interrupt         = "<leader>e<space>",
          -- FIX: was <leader>eq — now <leader>eQ to avoid shadowing <leader>q
          --      (diagnostic quickfix list).
          exit              = "<leader>eQ",
          clear             = "<leader>eC",
        },
        highlight          = { italic = true },
        ignore_blank_lines = true,
      })
    end,
  },

  { -- Quarto — notebook-style .qmd editing
    "quarto-dev/quarto-nvim",
    ft = { "quarto" },
    dependencies = {
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
          enabled  = true,
          chunks   = "all",
          -- FIX: added julia back — otter.nvim can inject Julia LSP into
          --      code cells now that julials is restored.
          languages    = { "python", "r", "julia", "bash" },
          diagnostics  = { enabled = true, triggers = { "BufWritePost" } },
          completion   = { enabled = true },
        },
        codeRunner = {
          enabled        = true,
          default_method = "iron",
          ft_runners     = { python = "iron", r = "iron" },
        },
        keymap = {
          -- FIX: removed K, gd, gr, <leader>rn, <leader>f from here.
          --      otter.nvim injects LSP into code cells, so LspAttach fires
          --      and sets those keys automatically — defining them twice caused
          --      silent overwrites depending on load order.
          run_cell       = "<leader>qr",
          run_above      = "<leader>qu",
          run_below      = "<leader>qd",
          run_all        = "<leader>qa",
          run_line       = "<leader>ql",
          -- FIX: run_range was also "<leader>qr" — duplicate of run_cell.
          run_range      = "<leader>qR",
          goto_prev_cell = "[q",
          goto_next_cell = "]q",
        },
      })
    end,
  },

  { -- Rust (replaces rust LSP in nvim-lspconfig — do not add rust_analyzer there)
    'mrcjkb/rustaceanvim',
    version = '^5',
    -- FIX: had both `lazy = false` and `ft = {'rust'}` — contradictory.
    --      `ft` is sufficient: plugin loads only for Rust files.
    ft = { 'rust' },
    config = function()
      vim.g.rustaceanvim = {
        tools = { hover_actions = { auto_focus = true } },
        server = {
          on_attach = function(_, bufnr)
            local map = function(keys, func, desc)
              vim.keymap.set('n', keys, func, { buffer = bufnr, desc = 'Rust: ' .. desc })
            end
            map('<leader>ra', function() vim.cmd.RustLsp('codeAction') end,       'Code Action')
            map('<leader>rh', function() vim.cmd.RustLsp('hover', 'actions') end, 'Hover Actions')
            map('<leader>rr', function() vim.cmd.RustLsp('runnables') end,        'Runnables')
            map('<leader>rd', function() vim.cmd.RustLsp('debuggables') end,      'Debuggables')
            map('<leader>re', function() vim.cmd.RustLsp('expandMacro') end,      'Expand Macro')
            map('<leader>rc', function() vim.cmd.RustLsp('openCargo') end,        'Open Cargo.toml')
            map('<leader>rp', function() vim.cmd.RustLsp('parentModule') end,     'Parent Module')
          end,
          settings = {
            ['rust-analyzer'] = {
              checkOnSave  = { command = 'clippy' },
              cargo        = { allFeatures = true },
              inlayHints   = { lifetimeElisionHints = { enable = 'always' } },
            },
          },
        },
      }
    end,
  },

}
