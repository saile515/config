local profile = vim.g.nvim_profile or vim.env.NVIM_PROFILE

if profile == nil or profile == "" then
  return
end

if type(profile) ~= "string" or not profile:match("^[%w_-]+$") then
  error("Invalid Neovim profile name: expected letters, numbers, underscores, or hyphens")
end

local module = "profiles." .. profile
local ok, err = pcall(require, module)
if not ok then
  error(("Failed to load Neovim profile %q: %s"):format(profile, err), 0)
end
