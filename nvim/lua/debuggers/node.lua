local M = {}

function M.setup(dap, helpers)
	local function configure_node_terminal_adapter()
		dap.adapters["node-terminal"] = function(callback, config)
			if config.request ~= "launch" or type(config.command) ~= "string" or config.command == "" then
				helpers.notify_error("node-terminal requires a launch request with a command")
				return
			end

			config.type = "pwa-node"
			config.runtimeExecutable = vim.o.shell
			config.runtimeArgs = helpers.shell_args(config.command)
			config.command = nil
			config.program = nil
			config.args = {}
			config.console = "integratedTerminal"
			config.autoAttachChildProcesses = true
			callback(dap.adapters["pwa-node"])
		end
	end

	dap.adapters["pwa-node"] = {
		type = "server",
		host = "127.0.0.1",
		port = "${port}",
		id = "pwa-node",
		executable = {
			command = "js-debug-adapter",
			args = { "${port}", "127.0.0.1" },
		},
	}
	configure_node_terminal_adapter()
	dap.defaults["pwa-node"].terminal_win_cmd = "tabnew"
	dap.defaults["pwa-node"].focus_terminal = false
end

return M
