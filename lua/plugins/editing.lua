-- ==========================================
-- EDITING ENHANCEMENTS
-- ==========================================
return {

  { -- Auto-close brackets, quotes, parens
    -- FIX: added nvim-cmp as explicit dependency to guarantee load order.
    -- Both share event = 'InsertEnter' and autopairs' config calls require('cmp'),
    -- so without this the order was non-deterministic.
    'windwp/nvim-autopairs',
    event = 'InsertEnter',
    dependencies = { 'hrsh7th/nvim-cmp' },
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

  -- NOTE: Comment.nvim removed — Neovim 0.10+ ships gc/gb natively via
  --       vim.comment. If you are on Neovim 0.9, add it back:
  --       { 'numToStr/Comment.nvim', event = 'VeryLazy', opts = {} }

  { -- Highlight matching bracket/paren
    'andymass/vim-matchup',
    event = 'BufReadPost',
    init = function() vim.g.matchup_matchparen_offscreen = { method = 'popup' } end,
  },

}
