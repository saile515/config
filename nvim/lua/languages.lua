return {
	lua = {
		lsp = "lua_ls",
		lsp_package = "lua-language-server",
		formatter = "stylua",
		debugger = "local-lua-debugger-vscode",
	},
	cpp = {
		lsp = "clangd",
		formatter = "clang-format",
		debugger = "codelldb",
	},
	c = {
		lsp = "clangd",
		formatter = "clang-format",
		debugger = "codelldb",
	},
	javascript = {
		lsp = "ts_ls",
		lsp_package = "typescript-language-server",
		formatter = "oxfmt",
		debugger = "js-debug-adapter",
	},
	jsx = {
		lsp = "ts_ls",
		lsp_package = "typescript-language-server",
		formatter = "oxfmt",
		debugger = "js-debug-adapter",
		conform = "javascriptreact",
	},
	typescript = {
		lsp = "ts_ls",
		lsp_package = "typescript-language-server",
		formatter = "oxfmt",
		debugger = "js-debug-adapter",
	},
	tsx = {
		lsp = "ts_ls",
		lsp_package = "typescript-language-server",
		formatter = "oxfmt",
		debugger = "js-debug-adapter",
		conform = "typescriptreact",
	},
	json = {
		lsp = false,
		formatter = "oxfmt",
		debugger = false,
	},
	yaml = {
		lsp = false,
		formatter = "oxfmt",
		debugger = false,
	},
	toml = {
		lsp = false,
		formatter = "oxfmt",
		debugger = false,
	},
	html = {
		lsp_package = "html-lsp",
		formatter = "oxfmt",
		debugger = false,
	},
	css = {
		lsp = "cssls",
		lsp_package = "css-lsp",
		formatter = "oxfmt",
		debugger = false,
	},
	markdown = {
		lsp = false,
		formatter = "oxfmt",
		debugger = false,
	},
	mdx = {
		treesitter = false,
		lsp = "mdx_analyzer",
		lsp_package = "mdx-analyzer",
		formatter = "oxfmt",
		debugger = false,
	},
	c_sharp = {
		lsp = "roslyn_ls",
		lsp_package = "roslyn-language-server",
		formatter = "csharpier",
		debugger = "netcoredbg",
	},
	gdscript = {
		lsp_package = false,
		formatter = "gdtoolkit",
		formatter_cli = "gdformat",
		debugger = false,
	},
}
