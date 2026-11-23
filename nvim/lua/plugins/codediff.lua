local function is_codex_profile()
	local profile = vim.g.nvim_profile or vim.env.NVIM_PROFILE
	return profile == "codex"
end

local function options()
	if not is_codex_profile() then
		return {}
	end

	return {
		diff = { layout = "inline" },
		explorer = {
			initial_focus = "modified",
			focus_on_select = true,
			auto_open_on_cursor = true,
		},
	}
end

local function setup(options)
	require("codediff").setup(options)

	if not is_codex_profile() then
		return
	end

	local api = vim.api
	local view = require("codediff.ui.view")
	local create_view = view.create
	local layout = require("codediff.ui.layout")
	local arrange_layout = layout.arrange
	local lifecycle = require("codediff.ui.lifecycle")
	local explorer_width = require("codediff.config").options.explorer.width

	local helpers = require("codediff.ui.view.helpers")
	-- Load an unloaded file in its target window without moving focus out of the explorer.
	helpers.open_real_file = function(win, target)
		local bufnr = vim.fn.bufadd(target)
		if api.nvim_buf_is_loaded(bufnr) then
			helpers.show_real_file_buffer(win, bufnr)
			return bufnr
		end

		api.nvim_win_call(win, function()
			vim.cmd("edit " .. vim.fn.fnameescape(target))
		end)
		return api.nvim_win_get_buf(win)
	end

	-- CodeDiff's layout manager assumes its session owns the whole tab.
	layout.arrange = function(tabpage)
		if tabpage ~= vim.g.codex_codediff_tab then
			return arrange_layout(tabpage)
		end

		local session = lifecycle.get_session(tabpage)
		local panel = session and session.panel and session.panel.view
		if panel and panel.winid and api.nvim_win_is_valid(panel.winid) and not panel.is_hidden then
			api.nvim_win_set_width(panel.winid, explorer_width)
		end
	end

	view.create = function(session_config, ...)
		local embed_tab = vim.g.codex_codediff_tab
		local main_win = vim.g.codex_codediff_main_win
		if not vim.g.codex_codediff_pending or not embed_tab or not main_win then
			return create_view(session_config, ...)
		end

		api.nvim_set_current_tabpage(embed_tab)
		api.nvim_set_current_win(main_win)
		local run_command = vim.cmd
		local open_window = api.nvim_open_win
		-- Reuse the main pane instead of CodeDiff's usual `tabnew` workspace.
		vim.cmd = function(command, ...)
			if type(command) == "string" and command:match("^%s*tabnew%s*$") then
				return
			end
			return run_command(command, ...)
		end
		-- Keep the explorer split inside the editor area, above its terminal.
		api.nvim_open_win = function(buf, enter, config)
			if config and config.split == "left" and config.win == -1 then
				config = vim.tbl_extend("force", config, { win = main_win })
			end
			return open_window(buf, enter, config)
		end

		local ok, result = pcall(create_view, session_config, ...)
		vim.cmd = run_command
		api.nvim_open_win = open_window
		vim.g.codex_codediff_pending = false
		if not ok then
			error(result, 0)
		end
		return result
	end

	local group = api.nvim_create_augroup("CodexCodeDiffEmbed", { clear = true })
	api.nvim_create_autocmd("User", {
		group = group,
		pattern = "CodeDiffClose",
		callback = function(event)
			if event.data and event.data.tabpage == vim.g.codex_codediff_tab then
				vim.g.codex_codediff_pending = nil
				vim.g.codex_codediff_tab = nil
				vim.g.codex_codediff_main_win = nil
			end
		end,
	})
end

return {
	"esmuellert/codediff.nvim",
	cmd = "CodeDiff",
	opts = options,
	config = function(_, opts)
		setup(opts)
	end,
}
