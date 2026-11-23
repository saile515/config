local language_utils = require("language_utils")

return {
	"nvim-treesitter/nvim-treesitter",
	lazy = false,
	branch = "main",
	build = ":TSUpdate",
	config = function()
		local ts = require("nvim-treesitter")

		ts.setup({})
		ts.install(language_utils.override_set("treesitter"))
	end,
}
