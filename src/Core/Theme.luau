--[[
    Tzar UI Library - Theme System
    Centralized theming with colors, fonts, and sizes
]]

local Types = require("./Types")

--// Theme Definitions

local Dark: Types.Theme = {
	Colors = {
		-- Base backgrounds
		Background = Color3.fromRGB(11, 11, 11), -- Main background
		BackgroundSecondary = Color3.fromRGB(22, 22, 22), -- TopBar, TabContainer
		BackgroundTertiary = Color3.fromRGB(16, 16, 16), -- Section background
		BackgroundElement = Color3.fromRGB(20, 20, 20), -- Component background

		-- Interactive states
		BackgroundHover = Color3.fromRGB(26, 26, 26), -- Hover state
		BackgroundPress = Color3.fromRGB(16, 16, 16), -- Press state
		BackgroundActive = Color3.fromRGB(30, 30, 30), -- Active/focused state

		-- Borders and strokes
		Border = Color3.fromRGB(65, 65, 65), -- Stroke color
		BorderSubtle = Color3.fromRGB(40, 40, 40), -- Subtle borders
		BorderActive = Color3.fromRGB(50, 50, 50), -- Active borders

		-- Text colors
		Text = Color3.fromRGB(249, 249, 249), -- Primary text
		TextSecondary = Color3.fromRGB(212, 212, 212), -- Secondary text
		TextMuted = Color3.fromRGB(140, 140, 140), -- Muted/placeholder text
		TextDisabled = Color3.fromRGB(100, 100, 100), -- Disabled text

		-- Brand/Accent colors
		Primary = Color3.fromRGB(9, 156, 75), -- Green accent (main)
		PrimaryHover = Color3.fromRGB(11, 180, 87), -- Green hover
		PrimaryPress = Color3.fromRGB(7, 130, 62), -- Green press
		Distract = Color3.fromRGB(227, 29, 29), -- Red accent (destructive)
		DistractHover = Color3.fromRGB(245, 50, 50), -- Red hover
		DistractPress = Color3.fromRGB(190, 25, 25), -- Red press
		Accent = Color3.fromRGB(45, 45, 45), -- Scrollbar, borders

		-- Component-specific colors
		SwitchOff = Color3.fromRGB(40, 40, 40), -- Toggle off state
		SwitchKnobOff = Color3.fromRGB(180, 180, 180), -- Toggle knob off
		SwitchKnobOn = Color3.fromRGB(255, 255, 255), -- Toggle knob on
		SliderTrack = Color3.fromRGB(40, 40, 40), -- Slider background
		SliderFill = Color3.fromRGB(9, 156, 75), -- Slider filled portion
		DropdownOption = Color3.fromRGB(32, 32, 32), -- Dropdown option bg
		DropdownOptionHover = Color3.fromRGB(42, 42, 42), -- Dropdown option hover

		-- Semantic/Status colors
		Success = Color3.fromRGB(9, 156, 75),
		Warning = Color3.fromRGB(245, 158, 11),
		Error = Color3.fromRGB(227, 29, 29),
		Info = Color3.fromRGB(59, 130, 246),

		-- Overlay
		Overlay = Color3.fromRGB(0, 0, 0), -- Dialog/modal overlay
	},
	Fonts = {
		Regular = Enum.Font.Gotham,
		Medium = Enum.Font.GothamMedium,
		Bold = Enum.Font.GothamBold,
	},
	Sizes = {
		CornerRadius = 8,
		CornerRadiusSmall = 4,
		CornerRadiusLarge = 16,
		Padding = 8,
		PaddingSmall = 4,
		PaddingLarge = 12,
		FontSize = 14,
		FontSizeSmall = 12,
		FontSizeLarge = 16,
	},
}

--// Theme Module

local Theme = {
	Current = Dark,
	Themes = {
		Dark = Dark,
	},
}

--// Get current theme value
function Theme:Get(): Types.Theme
	return self.Current
end

--// Set active theme
function Theme:Set(theme: Types.Theme)
	self.Current = theme
end

--// Quick access to colors
function Theme:Colors(): Types.ThemeColors
	return self.Current.Colors
end

--// Quick access to fonts
function Theme:Fonts(): Types.ThemeFonts
	return self.Current.Fonts
end

--// Quick access to sizes
function Theme:Sizes(): Types.ThemeSizes
	return self.Current.Sizes
end

return Theme
