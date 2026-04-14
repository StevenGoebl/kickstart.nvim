-- ==========================================
-- TREESITTER
-- ==========================================
return {

  { -- Syntax Highlighting + Text Objects + Folds
    'nvim-treesitter/nvim-treesitter',
    branch = 'master',
    build = ':TSUpdate',
    dependencies = { 'nvim-treesitter/nvim-treesitter-textobjects' },
    config = function()
      require('nvim-treesitter.configs').setup({
        ensure_installed = {
          'bash', 'c', 'cpp', 'html', 'julia', 'lua', 'markdown', 'markdown_inline',
          'python', 'r', 'rust', 'vim', 'vimdoc', 'latex',
          -- FIX: added julia treesitter parser (was missing despite Julia
          --      being listed as an active language).
        },
        highlight   = { enable = true },
        indent      = { enable = true },
        textobjects = {
          select = {
            enable    = true,
            lookahead = true,
            keymaps   = {
              ['af'] = '@function.outer',
              ['if'] = '@function.inner',
              ['ac'] = '@class.outer',
              ['ic'] = '@class.inner',
              ['aa'] = '@parameter.outer',
              ['ia'] = '@parameter.inner',
            },
          },
          move = {
            enable    = true,
            set_jumps = true,
            goto_next_start = {
              [']f'] = '@function.outer',
              -- FIX: was ']c' — conflicted with gitsigns next_hunk.
              [']a'] = '@class.outer',
            },
            goto_previous_start = {
              ['[f'] = '@function.outer',
              -- FIX: was '[c' — conflicted with gitsigns prev_hunk.
              ['[a'] = '@class.outer',
            },
          },
        },
      })

      -- FIX: Treesitter fold settings scoped to relevant filetypes only,
      -- so help/lazy/mason/etc are unaffected. foldenable = false means folds
      -- exist but are open on entry; foldlevel = 99 is a safe fallback for
      -- when folds are toggled on manually (zR etc.).
      vim.api.nvim_create_autocmd('FileType', {
        group = vim.api.nvim_create_augroup('ts-folding', { clear = true }),
        pattern = {
          'lua', 'python', 'r', 'rmd', 'quarto',
          'rust', 'c', 'cpp', 'bash',
          'markdown', 'tex', 'julia',
        },
        callback = function()
          vim.opt_local.foldmethod = 'expr'
          vim.opt_local.foldexpr   = 'nvim_treesitter#foldexpr()'
          vim.opt_local.foldenable = false
          vim.opt_local.foldlevel  = 99
        end,
      })
    end,
  },

}
