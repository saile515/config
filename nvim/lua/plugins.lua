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
		},
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
	},
	{
		"esmuellert/codediff.nvim",
		cmd = "CodeDiff",
	},
	{
		"nvim-treesitter/nvim-treesitter",
	},
}
