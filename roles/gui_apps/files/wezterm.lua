-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices

-- For example, changing the color scheme:
config.color_scheme = "AdventureTime"

-- config.font = wezterm.font("Fira Code")
-- You can specify some parameters to influence the font selection;
-- for example, this selects a Bold, Italic font variant.
config.font = wezterm.font("JetBrainsMono Nerd Font")
-- config.font = wezterm.font("CaskaydiaMono Nerd Font", { weight = "Bold", italic = false })

-- and finally, return the configuration to wezterm
-- color_scheme = 'termnial.sexy',
config.color_scheme = "Catppuccin Mocha"
config.enable_tab_bar = false
config.font_size = 16.0
-- font = wezterm.font('JetBrains Mono'),
-- macos_window_background_blur = 40,
config.macos_window_background_blur = 30

-- window_background_image = '/Users/omerhamerman/Downloads/3840x1080-Wallpaper-041.jpg',
-- window_background_image_hsb = {
-- 	brightness = 0.01,
-- 	hue = 1.0,
-- 	saturation = 0.5,
-- },
-- window_background_opacity = 0.92,
config.window_background_opacity = 1.0
-- window_background_opacity = 0.78,
-- window_background_opacity = 0.20,
config.window_decorations = "RESIZE"
config.keys = {
	{
		key = "f",
		mods = "CTRL",
		action = wezterm.action.ToggleFullScreen,
	},
	{
		key = "'",
		mods = "CTRL",
		action = wezterm.action.ClearScrollback("ScrollbackAndViewport"),
	},
}
config.mouse_bindings = {
	-- Ctrl-click will open the link under the mouse cursor
	{
		event = { Up = { streak = 1, button = "Left" } },
		mods = "CTRL",
		action = wezterm.action.OpenLinkAtMouseCursor,
	},
}

wezterm.on("gui-startup", function(cmd)
	-- Get the main screen dimensions
	local screen = wezterm.gui.screens().main

	-- Set the desired window size (you can adjust these values)
	local width = math.floor(screen.width * 0.9)
	local height = math.floor(screen.height * 0.9)

	-- Calculate the position to center the window
	local x = math.floor((screen.width - width) / 2)
	local y = math.floor((screen.height - height) / 2)

	-- Spawn the window with the calculated size and position
	local tab, pane, window = wezterm.mux.spawn_window(cmd or {})
	window:gui_window():set_inner_size(width, height)
	window:gui_window():set_position(x, y)
end)

return config
