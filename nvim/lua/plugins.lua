local languages = require("languages")
local codediff = require("config.codediff")

function unique(value)
	local map = {}

	for _, value in ipairs(value) do
		map[value] = true
	end

	local result = {}

	for value, _ in pairs(map) do
		table.insert(result, value)
	end

	return result
end

function override(...)
	local args = { ... }
	local length = table.getn(args)
	for i = 1, length + 1 do
		local value = args[i]

		if value == false then
			return nil
		end

		if value ~= nil then
			return value
		end
	end

	return nil
end

function override_set(...)
	local keys = { ... }
	local result = {}

	for lang, opts in pairs(languages) do
		local values = {}

		for _, key in ipairs(keys) do
			table.insert(values, opts[key])
		end

		local value = override(unpack(values), lang)

		if value then
			table.insert(result, value)
		end
	end

	return unique(result)
end

function concat_tables(...)
	local tables = { ... }
	local result = {}

	for _, current_table in ipairs(tables) do
		local table_length = table.getn(current_table)
		for i = 1, table_length do
			table.insert(result, current_table[i])
		end
	end

	return result
end

local formatters = {}

for lang, opts in pairs(languages) do
	local conform_name = override(opts["conform"], lang)
	local formatter_name = override(opts["formatter_cli"], opts["formatter"], lang)

	if conform_name and formatter_name then
		formatters[conform_name] = { formatter_name }
	end
end

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
	{
		"neovim/nvim-lspconfig",
		config = function()
			local lsps = override_set("lsp")

			for _, lsp in ipairs(lsps) do
				vim.lsp.enable(lsp)
			end
		end,
	},
	{
		"mason-org/mason.nvim",
		opts = {},
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
	},
	{
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		dependencies = { "mason-org/mason.nvim" },
		opts = {
			ensure_installed = concat_tables(override_set("formatter"), override_set("lsp_package", "lsp")),
			auto_update = true,
		},
	},
	{
		"stevearc/conform.nvim",
		opts = {
			formatters_by_ft = formatters,
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
			defaults = {
				file_ignore_patterns = { "%.git/" },
			},
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
		opts = codediff.options,
		config = function(_, options)
			codediff.setup(options)
		end,
	},
	{
		"nvim-treesitter/nvim-treesitter",
		lazy = false,
		branch = "main",
		build = ":TSUpdate",
		config = function()
			local ts = require("nvim-treesitter")

			ts.setup({})
			ts.install(override_set("treesitter"))
		end,
	},
}
