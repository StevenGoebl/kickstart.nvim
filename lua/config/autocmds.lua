-- ==========================================
-- POST-PLUGIN AUTOCMDS
-- ==========================================
-- Loaded after lazy.setup() so all plugins are available.

-- R / Quarto / Rmd: devtools & targets shortcuts sent to iron REPL
-- All under <leader>d* — buffer-local, only active in R/Quarto files.
-- NOTE: <leader>ds is global (telescope document symbols) but these are
--       buffer-local and win for R files, which is the intended behaviour.
vim.api.nvim_create_autocmd("FileType", {
  pattern  = { "r", "rmd", "quarto" },
  callback = function()
    local map = function(k, v, desc)
      vim.keymap.set("n", k, v, { buffer = true, desc = desc })
    end
    map("<leader>dl", "<cmd>IronSend devtools::load_all()<CR>",      "R: load_all()")
    map("<leader>dt", "<cmd>IronSend devtools::test()<CR>",          "R: test()")
    map("<leader>dd", "<cmd>IronSend devtools::document()<CR>",      "R: document()")
    map("<leader>dc", "<cmd>IronSend devtools::check()<CR>",         "R: check()")
    map("<leader>di", "<cmd>IronSend devtools::install()<CR>",       "R: install()")
    map("<leader>dm", "<cmd>IronSend targets::tar_make()<CR>",       "R: tar_make()")
    map("<leader>dv", "<cmd>IronSend targets::tar_visnetwork()<CR>", "R: tar_visnetwork()")
  end,
})

-- C / C++: clangd switch between header and source file
vim.api.nvim_create_autocmd("FileType", {
  pattern  = { "c", "cpp" },
  callback = function()
    vim.keymap.set("n", "<leader>ch",
      "<cmd>ClangdSwitchSourceHeader<CR>",
      { buffer = true, desc = "[C]langd: Switch [H]eader/Source" })
  end,
})
