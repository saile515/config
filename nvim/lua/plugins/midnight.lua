return {
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
}
