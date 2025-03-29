-- Only one of the following should be set to `true`, otherwise `false`
local starship_enabled = true
local ohmyposh_enabled = false



-- Ensure only one of the options is enabled
if starship_enabled and ohmyposh_enabled then
	error("Only one of 'starship_enabled' or 'ohmyposh_enabled' can be set to true.")
	return
end

-- Load the appropriate prompt based on the enabled option
if starship_enabled then
	-- Initialize Starship prompt
	local starship_init = io.popen("starship init cmd")
	if not starship_init then
		error("Failed to initialize Starship prompt.")
		return
	end
	load(starship_init:read("*a"))()
	starship_init:close()

elseif ohmyposh_enabled then
	-- Ensure POSH_THEMES_PATH is set
	local posh_themes_path = os.getenv("POSH_THEMES_PATH")
	if not posh_themes_path then
		error("Environment variable 'POSH_THEMES_PATH' is not set.")
		return
	end

	-- Construct the full path to the Oh My Posh theme file
	local ohmyposh_theme_file = posh_themes_path .. "/catppuccin_mocha.omp.json"
	local ohmyposh_theme = string.gsub(ohmyposh_theme_file, "\\", "/")

	-- Initialize Oh My Posh prompt
	local ohmyposh_init = io.popen("oh-my-posh init cmd --config " .. ohmyposh_theme)
	if not ohmyposh_init then
		error("Failed to initialize Oh My Posh prompt.")
		return
	end
	load(ohmyposh_init:read("*a"))()
	ohmyposh_init:close()
else
	-- Return if no `oh-my-posh` or `starship` prompt is enabled
	return
end
