local language_utils = require("language_utils")

return {
	"WhoIsSethDaniel/mason-tool-installer.nvim",
	dependencies = { "mason-org/mason.nvim" },
	opts = {
		ensure_installed = language_utils.concat_tables(
			language_utils.override_set("formatter"),
			language_utils.override_set("lsp_package", "lsp"),
			language_utils.override_set("debugger")
		),
		auto_update = true,
	},
}
