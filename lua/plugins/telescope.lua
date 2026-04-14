-- ==========================================
-- TELESCOPE (Fuzzy Finder)
-- ==========================================
return {

  {
    'nvim-telescope/telescope.nvim',
    event = 'VimEnter',
    dependencies = {
      'nvim-lua/plenary.nvim',
      { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
    },
    config = function()
      require('telescope').setup {
        defaults = {
          path_display     = { 'truncate' },
          sorting_strategy = 'ascending',
          layout_config    = { prompt_position = 'top' },
        },
      }
      require('telescope').load_extension('fzf')

      local builtin = require 'telescope.builtin'
      vim.keymap.set('n', '<leader>sf', builtin.find_files,  { desc = '[S]earch [F]iles' })
      vim.keymap.set('n', '<leader>sg', builtin.live_grep,   { desc = '[S]earch by [G]rep' })
      vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
      vim.keymap.set('n', '<leader>sr', builtin.oldfiles,    { desc = '[S]earch [R]ecent files' })
      vim.keymap.set('n', '<leader>sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })
      vim.keymap.set('n', '<leader>sk', builtin.keymaps,     { desc = '[S]earch [K]eymaps' })
      -- FIX: added Noice history search via Telescope
      vim.keymap.set('n', '<leader>sn', '<cmd>Noice telescope<cr>', { desc = '[S]earch [N]oice history' })
      vim.keymap.set('n', '<leader><leader>', builtin.buffers,                   { desc = '[ ] Find existing buffers' })
      vim.keymap.set('n', '<leader>/',        builtin.current_buffer_fuzzy_find, { desc = '[/] Fuzzy search buffer' })
    end,
  },

}
