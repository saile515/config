return {
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
}
