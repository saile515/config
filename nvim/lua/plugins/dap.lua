return {
	"mfussenegger/nvim-dap",
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
		{
			"<F5>",
			function()
				require("dap").continue()
			end,
			desc = "Debug: continue",
		},
		{
			"<F9>",
			function()
				require("dap").toggle_breakpoint()
			end,
			desc = "Debug: toggle breakpoint",
		},
		{
			"<F10>",
			function()
				require("dap").step_over()
			end,
			desc = "Debug: step over",
		},
		{
			"<F11>",
			function()
				require("dap").step_into()
			end,
			desc = "Debug: step into",
		},
		{
			"<S-F11>",
			function()
				require("dap").step_out()
			end,
			desc = "Debug: step out",
		},
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
		{
			"<leader>dt",
			function()
				require("dap").terminate()
			end,
			desc = "Debug: terminate",
		},
		{ "<leader>dC", "<cmd>DapCompound<cr>", desc = "Debug: run compound" },
	},
	config = function()
		require("debugger").setup()
	end,
}
