return {
	lua = {
		lsp = "lua_ls",
		lsp_package = "lua-language-server",
		formatter = "stylua",
	},
	cpp = {
		lsp = "clangd",
		formatter = "clang-format",
	},
	c = {
		lsp = "clangd",
		formatter = "clang-format",
	},
	javascript = {
		lsp = "ts_ls",
		lsp_package = "typescript-language-server",
		formatter = "oxfmt",
	},
	jsx = {
		lsp = "ts_ls",
		lsp_package = "typescript-language-server",
		formatter = "oxfmt",
		conform = "javascriptreact",
	},
	typescript = {
		lsp = "ts_ls",
		lsp_package = "typescript-language-server",
		formatter = "oxfmt",
	},
	tsx = {
		lsp = "ts_ls",
		lsp_package = "typescript-language-server",
		formatter = "oxfmt",
		conform = "typescriptreact",
	},
	json = {
		lsp = false,
		formatter = "oxfmt",
	},
	yaml = {
		lsp = false,
		formatter = "oxfmt",
	},
	toml = {
		lsp = false,
		formatter = "oxfmt",
	},
	html = {
		lsp_package = "html-lsp",
		formatter = "oxfmt",
	},
	css = {
		lsp = "cssls",
		lsp_package = "css-lsp",
		formatter = "oxfmt",
	},
	markdown = {
		lsp = false,
		formatter = "oxfmt",
	},
	mdx = {
		treesitter = false,
		lsp = "mdx_analyzer",
		lsp_package = "mdx-analyzer",
		formatter = "oxfmt",
	},
	c_sharp = {
		lsp = "roslyn_ls",
		lsp_package = "roslyn-language-server",
		formatter = "csharpier",
	},
	gdscript = {
		lsp_package = false,
		formatter = "gdtoolkit",
		formatter_cli = "gdformat",
	},
}
