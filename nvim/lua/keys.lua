local map = vim.keymap.set

vim.g.mapleader = " "

map("n", "<leader><space>", ":Telescope find_files<enter>")

map("n", "<C-s>", ":w<enter>")
map("i", "<C-s>", "<esc>:w<enter>")

map("t", "<esc>", "<C-\\><C-n>")

map("i", "<C-space>", vim.lsp.completion.get)
map("n", "<F12>", vim.lsp.buf.definition)
