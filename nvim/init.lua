require("config.lazy")
vim.filetype.add({
	extension = {
		mdx = "markdown",
		mjml = "html",
		pcss = "css",
		postcss = "css",
	},
})
require("lsp")
require("preferences")
require("keys")
require("config.profile")
