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

local function workspace()
	return vim.fn.getcwd()
end

local function is_absolute(path)
	local first = path:sub(1, 1)
	local drive_path = path:sub(2, 2) == ":" and (path:sub(3, 3) == "/" or path:sub(3, 3) == "\\")
	return first == "/" or first == "\\" or drive_path
end

local function expand_task_value(value, root)
	if type(value) ~= "string" then
		return value
	end

	return value
		:gsub("%${workspaceFolder}", root)
		:gsub("%${workspaceRoot}", root)
		:gsub("%${workspaceFolderBasename}", vim.fn.fnamemodify(root, ":t"))
		:gsub("%${env:([%w_]+)}", function(name)
			return os.getenv(name) or ""
		end)
end

local function failed_adapter(message, callback)
	vim.notify(message, vim.log.levels.ERROR, { title = "nvim-dap" })
	if vim.fn.has("win32") == 1 then
		callback({ type = "executable", command = "cmd.exe", args = { "/c", "exit", "1" } })
	else
		callback({ type = "executable", command = "false", args = {} })
	end
end

local function run_prelaunch_task(label, callback)
	if not label then
		callback(true)
		return
	end

	local root = workspace()
	local tasks_path = vim.fs.joinpath(root, ".vscode", "tasks.json")
	local tasks, err = read_json5(tasks_path)
	if not tasks then
		callback(false, err)
		return
	end

	local task
	for _, candidate in ipairs(tasks.tasks or {}) do
		if candidate.label == label then
			task = candidate
			break
		end
	end
	if not task then
		callback(false, "Task not found in " .. tasks_path .. ": " .. label)
		return
	end
	if task.type ~= "shell" or type(task.command) ~= "string" then
		callback(false, "Only shell tasks with a command are supported as preLaunchTask")
		return
	end

	local command = expand_task_value(task.command, root)
	for _, arg in ipairs(task.args or {}) do
		command = command .. " " .. vim.fn.shellescape(expand_task_value(arg, root))
	end

	local shell_command = { vim.o.shell }
	vim.list_extend(shell_command, vim.split(vim.o.shellcmdflag, "%s+", { trimempty = true }))
	table.insert(shell_command, command)

	local options = task.options or {}
	local cwd = expand_task_value(options.cwd, root) or root
	if not is_absolute(cwd) then
		cwd = vim.fs.joinpath(root, cwd)
	end
	local env = {}
	for key, value in pairs(options.env or {}) do
		env[key] = expand_task_value(value, root)
	end

	vim.system(shell_command, { cwd = cwd, env = env, text = true }, function(result)
		vim.schedule(function()
			if result.code == 0 then
				callback(true)
			else
				local output = vim.trim((result.stdout or "") .. "\n" .. (result.stderr or ""))
				callback(false, "preLaunchTask failed (exit " .. result.code .. ")" .. (output ~= "" and ":\n" .. output or ""))
			end
		end)
	end)
end

local function netcoredbg_adapter()
	local command = vim.fn.exepath("netcoredbg")
	if command == "" then
		command = "netcoredbg"
	end
	return { type = "executable", command = command, args = { "--interpreter=vscode" } }
end

local function target_path(project_path, callback)
	if type(project_path) ~= "string" or project_path == "" then
		callback(nil, "The .NET launch configuration requires projectPath or program")
		return
	end

	project_path = vim.fn.fnamemodify(project_path, ":p")
	vim.system({ "dotnet", "msbuild", project_path, "-getProperty:TargetPath" }, { text = true }, function(result)
		vim.schedule(function()
			if result.code ~= 0 then
				callback(nil, vim.trim(result.stderr or result.stdout or "dotnet msbuild failed"))
				return
			end

			local output = vim.trim(result.stdout or "")
			local target
			local ok, properties = pcall(vim.json.decode, output)
			if ok and properties.Properties then
				target = properties.Properties.TargetPath
			end
			target = target or output:match("TargetPath%s*=%s*([^\r\n]+)") or output
			target = vim.trim(target):gsub('^"(.*)"$', "%1")
			if target == "" then
				callback(nil, "Could not determine the .NET project's output path")
				return
			end

			if not is_absolute(target) then
				target = vim.fs.joinpath(vim.fs.dirname(project_path), target)
			end
			callback(vim.fn.fnamemodify(target, ":p"))
		end)
	end)
end

local function apply_launch_settings(config, project_path)
	if config.launchSettingsProfile == "" then
		return
	end

	local settings_path = config.launchSettingsFilePath
	if not settings_path then
		settings_path = vim.fs.joinpath(vim.fs.dirname(project_path), "Properties", "launchSettings.json")
	elseif not is_absolute(settings_path) then
		settings_path = vim.fs.joinpath(vim.fs.dirname(project_path), settings_path)
	end

	local settings = read_json5(settings_path)
	if not settings then
		return
	end

	local profile_name = config.launchSettingsProfile
	if not profile_name and type(config.launchConfigurationId) == "string" then
		profile_name = config.launchConfigurationId:match(";(.*)$") or config.launchConfigurationId
	end
	local profile = profile_name and settings.profiles and settings.profiles[profile_name]
	if not profile then
		for _, candidate in pairs(settings.profiles or {}) do
			if candidate.commandName == "Project" then
				profile = candidate
				break
			end
		end
	end
	if not profile or profile.commandName ~= "Project" then
		return
	end

	local env = vim.deepcopy(profile.environmentVariables or {})
	if profile.applicationUrl and env.ASPNETCORE_URLS == nil then
		env.ASPNETCORE_URLS = profile.applicationUrl
	end
	config.env = vim.tbl_extend("force", env, config.env or {})
	config.cwd = config.cwd or profile.workingDirectory or vim.fs.dirname(project_path)

	local has_args = config.args and (type(config.args) ~= "table" or #config.args > 0)
	if not has_args and profile.commandLineArgs and profile.commandLineArgs ~= "" then
		config.args = require("dap.utils").splitstr(profile.commandLineArgs)
	end
end

local function js_adapter(dap, adapter_id)
	local function adapter_for(port)
		return {
			type = "server",
			host = "127.0.0.1",
			port = port,
			id = adapter_id,
			reverse_request_handlers = {
				attachedChildSession = function(parent, request)
					local config = request.arguments.config
					local child_port = tonumber(config.__jsDebugChildServer)
					if not child_port then
						vim.notify("JavaScript debugger did not provide a child-session port", vim.log.levels.ERROR)
						return
					end

					local child_session
					child_session = require("dap.session").connect(adapter_for(child_port), {}, function(err)
						if err then
							vim.notify("Could not connect to JavaScript child session: " .. tostring(err), vim.log.levels.ERROR)
							return
						end

						child_session.parent = parent
						parent.children[child_session.id] = child_session
						child_session.on_close["debugger.js_child"] = function(session)
							if session.parent then
								session.parent.children[session.id] = nil
								if dap.session() == session then
									dap.set_session(session.parent)
								end
								session.parent = nil
							end
						end
						dap.set_session(child_session)
						child_session:initialize(config)
					end)
				end,
			},
		}
	end

	local adapter = adapter_for("${port}")
	adapter.executable = {
		command = "js-debug-adapter",
		args = { "${port}", "127.0.0.1" },
	}
	return adapter
end

local function configure_node_terminal_adapter(dap)
	dap.adapters["node-terminal"] = function(callback, config)
		if config.request ~= "launch" or type(config.command) ~= "string" or config.command == "" then
			failed_adapter("node-terminal requires a launch request with a command", callback)
			return
		end

		local shell_args = vim.split(vim.o.shellcmdflag, "%s+", { trimempty = true })
		table.insert(shell_args, config.command)
		config.type = "pwa-node"
		config.command = nil
		config.runtimeExecutable = vim.o.shell
		config.runtimeArgs = shell_args
		config.program = nil
		config.args = {}
		config.console = "integratedTerminal"
		config.autoAttachChildProcesses = true
		callback(dap.adapters["pwa-node"])
	end
end

local function configure_dotnet_adapter(dap)
	dap.adapters.dotnet = function(callback, config)
		local function start()
			local function launch(program)
				if not program then
					failed_adapter("Could not resolve the .NET launch target", callback)
					return
				end

				local project_path = config.projectPath and vim.fn.fnamemodify(config.projectPath, ":p")
				if project_path then
					apply_launch_settings(config, project_path)
				end
				config.type = "coreclr"
				config.program = program
				config.cwd = config.cwd or (project_path and vim.fs.dirname(project_path)) or vim.fs.dirname(program)
				config.projectPath = nil
				config.preLaunchTask = nil
				config.launchConfigurationId = nil
				config.launchSettingsFilePath = nil
				config.launchSettingsProfile = nil
				callback(netcoredbg_adapter())
			end

			if config.program then
				launch(config.program)
			else
				target_path(config.projectPath, function(program, err)
					if err then
						failed_adapter(err, callback)
					else
						launch(program)
					end
				end)
			end
		end

		run_prelaunch_task(config.preLaunchTask, function(ok, err)
			if not ok then
				failed_adapter(err or "preLaunchTask failed", callback)
				return
			end
			start()
		end)
	end
end

local function load_launch_json()
	local path = vim.fs.joinpath(workspace(), ".vscode", "launch.json")
	local launch, err = read_json5(path)
	if not launch then
		vim.notify(err, vim.log.levels.ERROR, { title = "nvim-dap" })
		return nil
	end
	return launch
end

function M.run_compound()
	local dap = require("dap")
	local launch = load_launch_json()
	if not launch then
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
				vim.notify("Compound references unknown configuration: " .. name, vim.log.levels.ERROR, { title = "nvim-dap" })
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

	require("mason-nvim-dap").setup({
		ensure_installed = { "coreclr", "js" },
	})
	require("dap.ext.vscode").json_decode = require("json5").parse
	dap.adapters["pwa-node"] = js_adapter(dap, "pwa-node")
	configure_node_terminal_adapter(dap)
	configure_dotnet_adapter(dap)
	dap.defaults["pwa-node"].terminal_win_cmd = "tabnew"
	dap.defaults["pwa-node"].focus_terminal = false

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
