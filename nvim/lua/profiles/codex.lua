vim.api.nvim_create_autocmd("VimEnter", {
  once = true,
  callback = function()
    local editor_win = vim.api.nvim_get_current_win()

    vim.cmd("rightbelow vsplit")
    vim.cmd("vertical resize 80")
    vim.cmd("terminal codex")
    local codex_win = vim.api.nvim_get_current_win()

    vim.api.nvim_set_current_win(editor_win)
    vim.cmd("belowright split")
    vim.cmd("resize 12")
    vim.cmd("terminal")
    vim.api.nvim_buf_set_name(0, "codex")

    vim.api.nvim_set_current_win(codex_win)
    vim.cmd("startinsert")
  end,
})
