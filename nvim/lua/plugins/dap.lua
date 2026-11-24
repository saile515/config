return {
	"mfussenegger/nvim-dap",
	lazy = false,
	dependencies = {
		{
			"Joakker/lua-json5",
			build = vim.fn.has("win32") == 1 and "powershell ./install.ps1" or "./install.sh",
		},
		{
			"jay-babu/mason-nvim-dap.nvim",
			dependencies = { "mason-org/mason.nvim" },
		},
	},
	keys = {
		{ "<F5>", "<cmd>DapContinue<cr>", desc = "Debug: continue" },
		{ "<F9>", "<cmd>DapToggleBreakpoint<cr>", desc = "Debug: toggle breakpoint" },
		{ "<F10>", "<cmd>DapStepOver<cr>", desc = "Debug: step over" },
		{ "<F11>", "<cmd>DapStepInto<cr>", desc = "Debug: step into" },
		{ "<S-F11>", "<cmd>DapStepOut<cr>", desc = "Debug: step out" },
		{
			"<leader>dh",
			function()
				require("dap.ui.widgets").hover()
			end,
			desc = "Debug: hover",
		},
		{
			"<leader>dr",
			function()
				require("dap").repl.open()
			end,
			desc = "Debug: open REPL",
		},
		{ "<leader>dt", "<cmd>DapTerminate<cr>", desc = "Debug: terminate" },
		{ "<leader>dC", "<cmd>DapCompound<cr>", desc = "Debug: run compound" },
	},
	config = function()
		require("debugger").setup()
	end,
}
