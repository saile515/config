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
		opts = {},
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
