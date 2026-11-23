local languages = require("languages")
local language_utils = require("language_utils")

local formatters = {}

for lang, opts in pairs(languages) do
	local conform_name = language_utils.override(opts["conform"], lang)
	local formatter_name = language_utils.override(opts["formatter_cli"], opts["formatter"], lang)

	if conform_name and formatter_name then
		formatters[conform_name] = { formatter_name }
	end
end

return {
	"stevearc/conform.nvim",
	opts = {
		formatters_by_ft = formatters,
		format_on_save = {},
	},
}
