local M = {}

function M.setup(dap, helpers)
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

	local function run_process(command, options, name, callback)
		options.text = true
		local ok, spawn_error = pcall(
			vim.system,
			command,
			options,
			vim.schedule_wrap(function(result)
				if result.code == 0 then
					callback(vim.trim(result.stdout or ""))
					return
				end

				local output = vim.trim((result.stdout or "") .. "\n" .. (result.stderr or ""))
				local message = name .. " failed (exit " .. result.code .. ")"
				callback(nil, output == "" and message or (message .. ":\n" .. output))
			end)
		)
		if not ok then
			callback(nil, tostring(spawn_error))
		end
	end

	local function run_prelaunch_task(label, callback)
		if not label then
			callback()
			return
		end

		local root = vim.fn.getcwd()
		local tasks_path = vim.fs.joinpath(root, ".vscode", "tasks.json")
		local tasks, err = helpers.read_json5(tasks_path)
		if not tasks then
			callback(err)
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
			callback("Task not found in " .. tasks_path .. ": " .. label)
			return
		end
		if task.type ~= "shell" or type(task.command) ~= "string" then
			callback("Only shell tasks with a command are supported as preLaunchTask")
			return
		end

		local command = expand_task_value(task.command, root)
		for _, arg in ipairs(task.args or {}) do
			command = command .. " " .. vim.fn.shellescape(expand_task_value(arg, root))
		end

		local shell_command = { vim.o.shell }
		vim.list_extend(shell_command, helpers.shell_args(command))

		local options = task.options or {}
		local cwd = expand_task_value(options.cwd, root) or root
		if not is_absolute(cwd) then
			cwd = vim.fs.joinpath(root, cwd)
		end
		local env = {}
		for key, value in pairs(options.env or {}) do
			env[key] = expand_task_value(value, root)
		end

		run_process(shell_command, { cwd = cwd, env = env }, "preLaunchTask", function(_, err)
			callback(err)
		end)
	end

	local function target_path(project_path, callback)
		local command = { "dotnet", "msbuild", project_path, "-getProperty:TargetPath" }
		run_process(command, {}, "dotnet msbuild", function(output, err)
			if err then
				callback(nil, err)
				return
			end

			local target = output:match("TargetPath%s*=%s*([^\r\n]+)") or output
			local decoded, properties = pcall(vim.json.decode, output)
			if decoded and type(properties) == "table" and type(properties.Properties) == "table" then
				local property = properties.Properties.TargetPath
				if type(property) == "string" then
					target = property
				end
			end
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

		local settings = helpers.read_json5(settings_path)
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

	local coreclr = {
		type = "executable",
		command = "netcoredbg",
		args = { "--interpreter=vscode" },
	}

	dap.adapters.dotnet = function(callback, config)
		local project_path = config.projectPath
		if type(project_path) == "string" and project_path ~= "" then
			project_path = vim.fn.fnamemodify(project_path, ":p")
		else
			project_path = nil
		end
		if not config.program and not project_path then
			helpers.notify_error("The .NET launch configuration requires projectPath or program")
			return
		end

		local function launch(program, err)
			if err then
				helpers.notify_error(err)
				return
			end

			if project_path then
				apply_launch_settings(config, project_path)
			end
			config.type = "coreclr"
			config.program = program
			config.cwd = config.cwd or vim.fs.dirname(project_path or program)
			config.projectPath = nil
			config.preLaunchTask = nil
			config.launchConfigurationId = nil
			config.launchSettingsFilePath = nil
			config.launchSettingsProfile = nil
			callback(coreclr)
		end

		run_prelaunch_task(config.preLaunchTask, function(err)
			if err then
				helpers.notify_error(err)
			elseif config.program then
				launch(config.program)
			else
				target_path(project_path, launch)
			end
		end)
	end
end

return M
