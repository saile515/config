local M = {}
local compound_state

local function clear_finished_compound(state)
	if compound_state == state and state.launch_complete and next(state.sessions) == nil then
		compound_state = nil
	end
end

local function read_json5(path)
	local file = io.open(path, "r")
	if not file then
		return nil, "Could not read " .. path
	end

	local contents = file:read("*a")
	file:close()

	local ok, value = pcall(require("json5").parse, contents)
	if not ok then
		return nil, tostring(value)
	end
	return value
end

local function notify_error(message)
	vim.notify(message, vim.log.levels.ERROR, { title = "nvim-dap" })
end

local function shell_args(command)
	local args = vim.split(vim.o.shellcmdflag, "%s+", { trimempty = true })
	table.insert(args, command)
	return args
end

function M.run_compound()
	local dap = require("dap")
	local path = vim.fs.joinpath(vim.fn.getcwd(), ".vscode", "launch.json")
	local launch, err = read_json5(path)
	if not launch then
		notify_error(err)
		return
	end

	local compounds = launch.compounds or {}
	if #compounds == 0 then
		vim.notify("No compounds found in .vscode/launch.json", vim.log.levels.INFO, { title = "nvim-dap" })
		return
	end

	vim.ui.select(compounds, {
		prompt = "Debug compound: ",
		format_item = function(compound)
			return compound.name
		end,
	}, function(compound)
		if not compound then
			return
		end

		local by_name = {}
		for _, config in ipairs(launch.configurations or {}) do
			by_name[config.name] = config
		end

		local selected = {}
		for _, name in ipairs(compound.configurations or {}) do
			if not by_name[name] then
				vim.notify(
					"Compound references unknown configuration: " .. name,
					vim.log.levels.ERROR,
					{ title = "nvim-dap" }
				)
				return
			end
			table.insert(selected, by_name[name])
		end
		if #selected == 0 then
			vim.notify("Compound has no configurations: " .. compound.name, vim.log.levels.WARN, { title = "nvim-dap" })
			return
		end

		local config_counts = {}
		for _, config in ipairs(selected) do
			config_counts[config.name] = (config_counts[config.name] or 0) + 1
		end
		compound_state = {
			config_counts = config_counts,
			sessions = {},
			terminating = {},
			stop_all = compound.stopAll == true,
			stop_requested = false,
			launch_complete = false,
		}
		local state = compound_state
		for _, config in ipairs(selected) do
			dap.run(vim.deepcopy(config), { new = true })
		end
		vim.defer_fn(function()
			if compound_state == state and not state.launch_complete and next(state.sessions) == nil then
				compound_state = nil
			end
		end, 300000)
	end)
end

function M.setup()
	local dap = require("dap")

	require("mason-nvim-dap").setup()
	require("dap.ext.vscode").json_decode = require("json5").parse
	local helpers = {
		notify_error = notify_error,
		read_json5 = read_json5,
		shell_args = shell_args,
	}
	require("debuggers.node").setup(dap, helpers)
	require("debuggers.dotnet").setup(dap, helpers)

	vim.api.nvim_create_autocmd("VimLeavePre", {
		group = vim.api.nvim_create_augroup("debugger.cleanup", { clear = true }),
		callback = function()
			local function close_sessions(sessions)
				for _, session in ipairs(vim.tbl_values(sessions or {})) do
					close_sessions(session.children)
					if not session.closed then
						session:close()
					end
				end
			end

			close_sessions(dap.sessions())
		end,
	})

	dap.listeners.on_session["debugger.compound"] = function(old, new)
		local state = compound_state
		if not state or not new or (old and old.id == new.id) then
			return
		end
		local count = state.config_counts[new.config.name]
		if not count then
			return
		end
		if count == 1 then
			state.config_counts[new.config.name] = nil
		else
			state.config_counts[new.config.name] = count - 1
		end
		state.sessions[new.id] = true
		if not next(state.config_counts) then
			state.launch_complete = true
		end
		if state.stop_requested then
			state.terminating[new.id] = true
			new:disconnect({ terminateDebuggee = true }, function()
				state.sessions[new.id] = nil
				clear_finished_compound(state)
			end)
		end
	end

	dap.listeners.after.event_terminated["debugger.stop_compound"] = function(session)
		local state = compound_state
		if not state or not state.sessions[session.id] then
			return
		end
		state.sessions[session.id] = nil
		if state.stop_all then
			state.stop_requested = true
			for id in pairs(state.sessions) do
				local other = dap.sessions()[id]
				if other and not state.terminating[id] then
					state.terminating[id] = true
					other:disconnect({ terminateDebuggee = true }, function()
						state.sessions[id] = nil
						clear_finished_compound(state)
					end)
				elseif not other then
					state.sessions[id] = nil
				end
			end
		end
		clear_finished_compound(state)
	end

	vim.api.nvim_create_user_command("DapCompound", M.run_compound, {})
end

return M
