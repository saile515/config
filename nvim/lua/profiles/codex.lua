local function git_output(args, stdin)
	local result = vim.system(args, { text = true, stdin = stdin }):wait()
	if result.code ~= 0 then
		return nil
	end
	return vim.trim(result.stdout)
end

local function open_codediff()
	local args = { "--inline" }
	local status = git_output({ "git", "status", "--porcelain" })

	if status == "" then
		local head = git_output({ "git", "rev-parse", "--verify", "HEAD" })
		local base = head and git_output({ "git", "rev-parse", "--verify", "HEAD^" })

		if head and not base then
			base = git_output({ "git", "hash-object", "-t", "tree", "--stdin" }, "")
		end

		if base and head then
			table.insert(args, 1, head)
			table.insert(args, 1, base)
		end
	end

	vim.cmd("CodeDiff " .. table.concat(args, " "))
end

vim.api.nvim_create_autocmd("VimEnter", {
	once = true,
	callback = function()
		local editor_win = vim.api.nvim_get_current_win()

		vim.cmd("rightbelow vsplit")
		vim.cmd("vertical resize 80")
		vim.cmd("terminal codex")
		local codex_win = vim.api.nvim_get_current_win()
		vim.g.codex_terminal_win = codex_win

		vim.api.nvim_set_current_win(editor_win)
		vim.cmd("belowright split")
		vim.cmd("resize 12")
		vim.cmd("terminal")
		vim.api.nvim_buf_set_name(0, "codex")

		vim.api.nvim_set_current_win(editor_win)
		vim.g.codex_codediff_tab = vim.api.nvim_get_current_tabpage()
		vim.g.codex_codediff_main_win = editor_win
		vim.g.codex_codediff_pending = true
		open_codediff()

		vim.api.nvim_set_current_win(codex_win)
		vim.cmd("startinsert")
	end,
})
