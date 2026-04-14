-- ==========================================
-- CORE SETTINGS
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
vim.o.colorcolumn = '100'
vim.o.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- System & Search
vim.schedule(function() vim.o.clipboard = 'unnamedplus' end)
vim.o.undofile = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.updatetime = 250
vim.o.timeoutlen = 500
vim.o.inccommand = 'split'
