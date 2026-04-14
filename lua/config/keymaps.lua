-- ==========================================
-- BASIC KEYMAPS
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
-- FIX: replaced <cmd>bdelete<CR> with mini.bufremove so the window stays open
--      when deleting a buffer. See mini.bufremove plugin entry in ui.lua.
vim.keymap.set('n', '<leader>bd', function()
  require('mini.bufremove').delete(0, false)
end, { desc = '[B]uffer [D]elete' })

-- Paste without losing register
vim.keymap.set('x', '<leader>p', '"_dP', { desc = 'Paste without overwriting register' })

-- Highlight on yank
-- FIX: vim.hl was introduced in Neovim 0.11; fall back to vim.highlight on 0.10.
vim.api.nvim_create_autocmd('TextYankPost', {
  group = vim.api.nvim_create_augroup('highlight-yank', { clear = true }),
  callback = function() (vim.hl or vim.highlight).on_yank() end,
})
