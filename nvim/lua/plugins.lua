return {
	{
		"dasupradyumna/midnight.nvim",
		lazy = false,
		config = function()
			vim.cmd("colorscheme midnight")

			vim.api.nvim_set_hl(0, "Normal", {
				bg = "#000000",
			})

			vim.api.nvim_set_hl(0, "NormalFloat", {
				bg = "#000000",
			})
		end,
	},
	{ "neovim/nvim-lspconfig" },
	{
		"mason-org/mason.nvim",
		opts = {},
	},
	{
		"mason-org/mason-lspconfig.nvim",
		dependencies = { "mason-org/mason.nvim", "neovim/nvim-lspconfig" },
		opts = {
			ensure_installed = { "clangd", "ts_ls", "lua_ls", "roslyn_ls" },
			automatic_enable = { "clangd", "ts_ls", "lua_ls", "roslyn_ls" },
		},
	},
	{
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
			{ "<F5>", function() require("dap").continue() end, desc = "Debug: continue" },
			{ "<F9>", function() require("dap").toggle_breakpoint() end, desc = "Debug: toggle breakpoint" },
			{ "<F10>", function() require("dap").step_over() end, desc = "Debug: step over" },
			{ "<F11>", function() require("dap").step_into() end, desc = "Debug: step into" },
			{ "<S-F11>", function() require("dap").step_out() end, desc = "Debug: step out" },
			{ "<leader>dh", function() require("dap.ui.widgets").hover() end, desc = "Debug: hover" },
			{ "<leader>dr", function() require("dap").repl.open() end, desc = "Debug: open REPL" },
			{ "<leader>dt", function() require("dap").terminate() end, desc = "Debug: terminate" },
			{ "<leader>dC", "<cmd>DapCompound<cr>", desc = "Debug: run compound" },
		},
		config = function()
			require("debugger").setup()
		end,
	},
	{
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		dependencies = { "mason-org/mason.nvim" },
		opts = {
			ensure_installed = {
				"cspell",
				"oxfmt",
				"stylua",
				"clang-format",
			},
			run_on_start = true,
		},
	},
	{
		"stevearc/conform.nvim",
		opts = {
			formatters_by_ft = {
				lua = { "stylua" },
				cpp = { "clang-format" },
				c = { "clang-format" },
				javascript = { "oxfmt" },
				javascriptreact = { "oxfmt" },
				typescript = { "oxfmt" },
				typescriptreact = { "oxfmt" },
				json = { "oxfmt" },
				yaml = { "oxfmt" },
				toml = { "oxfmt" },
				html = { "oxfmt" },
				css = { "oxfmt" },
				markdown = { "oxfmt" },
				mdx = { "oxfmt" },
			},
			format_on_save = {},
		},
	},
	{
		"folke/trouble.nvim",
		opts = {},
		cmd = "Trouble",
	},
	{
		"nvim-telescope/telescope.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		opts = {
			pickers = {
				find_files = {
					hidden = true,
					no_ignore = false,
				},
			},
		},
	},
	{
		"esmuellert/codediff.nvim",
		cmd = "CodeDiff",
	},
	{
		"nvim-treesitter/nvim-treesitter",
		branch = "main",
		lazy = false,
		build = ":TSUpdate",
		config = function()
			require("nvim-treesitter").setup()
			require("nvim-treesitter").install({
				"bash",
				"c",
				"cpp",
				"c_sharp",
				"css",
				"html",
				"javascript",
				"json",
				"lua",
				"markdown",
				"markdown_inline",
				"query",
				"toml",
				"tsx",
				"typescript",
				"vim",
				"vimdoc",
				"yaml",
			})
			vim.treesitter.language.register("bash", { "sh" })
			vim.treesitter.language.register("c_sharp", { "cs" })
			vim.treesitter.language.register("javascript", { "javascriptreact" })
			vim.treesitter.language.register("tsx", { "typescriptreact" })

			vim.api.nvim_create_autocmd("FileType", {
				pattern = {
					"bash",
					"c",
					"cpp",
					"cs",
					"css",
					"html",
					"javascript",
					"javascriptreact",
					"json",
					"lua",
					"markdown",
					"query",
					"sh",
					"toml",
					"tsx",
					"typescript",
					"typescriptreact",
					"vim",
					"vimdoc",
					"yaml",
				},
				callback = function(ev)
					vim.treesitter.start(ev.buf)
				end,
			})
		end,
	},
}
