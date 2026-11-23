local languages = require("languages")

local M = {}

function M.unique(values)
	local map = {}

	for _, value in ipairs(values) do
		map[value] = true
	end

	local result = {}

	for value, _ in pairs(map) do
		table.insert(result, value)
	end

	return result
end

function M.override(...)
	local args = { ... }
	local length = table.getn(args)
	for i = 1, length + 1 do
		local value = args[i]

		if value == false then
			return nil
		end

		if value ~= nil then
			return value
		end
	end

	return nil
end

function M.override_set(...)
	local keys = { ... }
	local result = {}

	for lang, opts in pairs(languages) do
		local values = {}

		for _, key in ipairs(keys) do
			table.insert(values, opts[key])
		end

		local value = M.override(unpack(values), lang)

		if value then
			table.insert(result, value)
		end
	end

	return M.unique(result)
end

function M.concat_tables(...)
	local tables = { ... }
	local result = {}

	for _, current_table in ipairs(tables) do
		local table_length = table.getn(current_table)
		for i = 1, table_length do
			table.insert(result, current_table[i])
		end
	end

	return result
end

return M
