local language_utils = require("language_utils")

return {
	"neovim/nvim-lspconfig",
	config = function()
		local lsps = language_utils.override_set("lsp")

		for _, lsp in ipairs(lsps) do
			vim.lsp.enable(lsp)
		end
	end,
}
