-- ==========================================
-- LSP, MASON & FORMATTING
-- ==========================================
return {

  { -- Autoformat
    'stevearc/conform.nvim',
    keys = {
      {
        '<leader>f',
        function() require('conform').format { async = true, lsp_format = 'fallback' } end,
        mode = '',
        desc = '[F]ormat buffer',
      },
    },
    opts = {
      format_on_save   = { timeout_ms = 500, lsp_format = 'fallback' },
      formatters_by_ft = {
        lua    = { 'stylua' },
        -- FIX: ruff_format and ruff_organize_imports are the sole formatting
        -- path for Python. The Ruff LSP has its formatting capability disabled
        -- in on_attach below to prevent double-formatting on save.
        python = { 'ruff_format', 'ruff_organize_imports' },
        r      = { 'styler' },
        rust   = { 'rustfmt' },
        cpp    = { 'clang_format' },
        c      = { 'clang_format' },
        -- NOTE: Julia formatting uses JuliaFormatter.jl. Install inside Julia:
        --       import Pkg; Pkg.add("JuliaFormatter")
        --       It is not a Mason package; conform will find it via `julia -e`.
        julia  = { 'julia_formatter' },
      },
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
      vim.diagnostic.config({
        virtual_text  = false,
        float         = { border = 'rounded', source = true },
        signs         = true,
        underline     = true,
        update_in_insert = false,
        severity_sort = true,
      })

      vim.api.nvim_create_autocmd('LspAttach', {
        callback = function(event)
          local map = function(keys, func, desc)
            vim.keymap.set('n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
          end
          local builtin = require('telescope.builtin')

          -- Navigation
          map('gd',  vim.lsp.buf.definition,     '[G]oto [D]efinition')
          map('gD',  vim.lsp.buf.declaration,    '[G]oto [D]eclaration')
          map('gr',  builtin.lsp_references,     '[G]oto [R]eferences')
          map('gi',  vim.lsp.buf.implementation, '[G]oto [I]mplementation')
          map('K',   vim.lsp.buf.hover,          'Hover Documentation')

          -- Actions
          -- NOTE: <leader>rn is safe here — rustaceanvim's <leader>r* keys are
          --       only set in Rust buffers via its own on_attach.
          map('<leader>rn', vim.lsp.buf.rename,          '[R]e[n]ame symbol')
          map('<leader>ca', vim.lsp.buf.code_action,     '[C]ode [A]ction')
          map('<leader>D',  vim.lsp.buf.type_definition, 'Type [D]efinition')

          -- Symbols
          map('<leader>ds', builtin.lsp_document_symbols,          '[D]ocument [S]ymbols')
          map('<leader>ws', builtin.lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')

          -- Diagnostics
          map(']d', function() vim.diagnostic.goto_next({ float = true }) end, 'Next Diagnostic')
          map('[d', function() vim.diagnostic.goto_prev({ float = true }) end, 'Prev Diagnostic')

          -- Inlay hints toggle (Neovim 0.10+)
          if vim.lsp.inlay_hint then
            map('<leader>th', function()
              vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
            end, '[T]oggle Inlay [H]ints')
          end
        end,
      })

      -- NOTE: rust_analyzer is intentionally absent — rustaceanvim manages it.
      local servers = {
        pyright           = {},
        -- FIX: Ruff LSP formatting disabled here. Ruff provides both diagnostics
        -- and formatting, but conform owns formatting (ruff_format +
        -- ruff_organize_imports). Without this, format-on-save would run twice.
        ruff              = {
          on_attach = function(client, _)
            client.server_capabilities.documentFormattingProvider      = false
            client.server_capabilities.documentRangeFormattingProvider = false
          end,
        },
        clangd            = {
          cmd = {
            "clangd",
            "--background-index",
            "--clang-tidy",
            "--header-insertion=iwyu",
            "--completion-style=detailed",
            "--function-arg-placeholders",
          },
          init_options = {
            usePlaceholders    = true,
            completeUnimported = true,
            clangdFileStatus   = true,
          },
        },
        r_language_server = {},
        marksman          = {},
        texlab            = {},
        -- FIX: julials re-added. Was removed because treesitter, REPL, and
        --      formatter were missing — all three are now present.
        julials           = {},
        lua_ls            = {
          settings = {
            Lua = {
              diagnostics = { globals = { 'vim' } },
              workspace   = { checkThirdParty = false },
              telemetry   = { enable = false },
            },
          },
        },
      }

      -- FIX: explicit Mason package names (differ from lspconfig names).
      -- rustfmt ships with the Rust toolchain (not a Mason package).
      -- styler: install via R:     install.packages("styler")
      -- JuliaFormatter: install via Julia: import Pkg; Pkg.add("JuliaFormatter")
      require('mason-tool-installer').setup {
        ensure_installed = {
          -- LSP servers
          'pyright',
          'ruff',
          'clangd',
          'r-languageserver',
          'marksman',
          'texlab',
          'lua-language-server',
          -- FIX: julia-lsp re-added alongside the other Julia fixes.
          'julia-lsp',
          -- Formatters
          'stylua',
          'clang-format',
        },
      }

      require('mason-lspconfig').setup {
        handlers = {
          function(server_name)
            -- Skip rust_analyzer — rustaceanvim owns it
            if server_name == 'rust_analyzer' then return end
            require('lspconfig')[server_name].setup(servers[server_name] or {})
          end,
        },
      }
    end,
  },

{
    'danymat/neogen',
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    config = function()
      require('neogen').setup {
        -- If you use Neovim 0.10+, you can use the built-in native snippet engine!
        -- Otherwise, keep this as 'luasnip' if you have LuaSnip installed.
        snippet_engine = 'luasnip',
      }
      
      vim.keymap.set('n', '<leader>nf', ":lua require('neogen').generate()<CR>", { desc = 'Generate [N]eogen [F]unction Docs' })
    end,
  },
{
    'R-nvim/R.nvim',
    lazy = false,
    -- Note: R.nvim relies heavily on your "LocalLeader" key. 
    -- If you haven't explicitly set a maplocalleader in your config, 
    -- Neovim defaults to the backslash (\) key.
  },
}
