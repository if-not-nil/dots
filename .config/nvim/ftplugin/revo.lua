vim.opt_local.commentstring = "# %s"
vim.opt_local.shiftwidth = 2
vim.opt_local.tabstop = 2
vim.opt_local.expandtab = true

vim.b.match_words = "\\<do\\>:\\<end\\>,{:}"

vim.treesitter.start(0, "revo")
