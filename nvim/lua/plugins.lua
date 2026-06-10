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
		opts = {
			ensure_installed = {
				"cspell",
				"prettierd",
				"stylua",
				"clang-format",
			},
		},
	},
	{
		"mason-org/mason-lspconfig.nvim",
		opts = {
			ensure_installed = { "clangd", "ts_ls", "lua_ls" },
		},
	},
	{
		"stevearc/conform.nvim",
		opts = {
			formatters_by_ft = {
				lua = { "stylua" },
				cpp = { "clang-format" },
				c = { "clang-format" },
				typescript = { "prettierd" },
				javascript = { "prettierd" },
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
		"nvim-treesitter/nvim-treesitter",
	},
}
