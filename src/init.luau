--[[
    Tzar UI Library
    Main entry point with fluent API
]]

local Config = require("./Core/Config")
local MainFrame = require("./Layout/MainFrame")
local Section = require("./Components/Display/Section")
local ButtonGroup = require("./Components/Action/ButtonGroup")
local Button = require("./Components/Action/Button")
local Paragraph = require("./Components/Display/Paragraph")
local Toggle = require("./Components/Input/Toggle")
local Slider = require("./Components/Input/Slider")
local Dropdown = require("./Components/Input/Dropdown")
local Keybind = require("./Components/Input/Keybind")
local TextBox = require("./Components/Input/TextBox")
local ColorPicker = require("./Components/Input/ColorPicker")
local Tooltip = require("./Layout/Overlays/Tooltip")
local Notification = require("./Layout/Overlays/Notification")
local TabButton = require("./Layout/Elements/TabButton")

--// Tzar Library
local Tzar = {}
Tzar.Flags = Config.Flags
Config:Init()

--// Create new window
function Tzar.new(options)
	return MainFrame.new(options)
end

--// Expose components for direct access
Tzar.Components = {
	MainFrame = MainFrame,
	Section = Section,
	ButtonGroup = ButtonGroup,
	Button = Button,
	Paragraph = Paragraph,
	Toggle = Toggle,
	Slider = Slider,
	Dropdown = Dropdown,
	Keybind = Keybind,
	TextBox = TextBox,
	ColorPicker = ColorPicker,
	Tooltip = Tooltip,
	Notification = Notification,
	TabButton = TabButton,
}

--// Shorthand constructors
function Tzar.CreateButton(options)
	return Button.new(options)
end

function Tzar.CreateParagraph(options)
	return Paragraph.new(options)
end

function Tzar.CreateToggle(options)
	return Toggle.new(options)
end

function Tzar.CreateSlider(options)
	return Slider.new(options)
end

function Tzar.CreateSection(options)
	return Section.new(options)
end

function Tzar.CreateButtonGroup(options)
	return ButtonGroup.new(options)
end

function Tzar.CreateDropdown(options)
	return Dropdown.new(options)
end

function Tzar.CreateKeybind(options)
	return Keybind.new(options)
end

function Tzar.CreateTextBox(options)
	return TextBox.new(options)
end

function Tzar.CreateColorPicker(options)
	return ColorPicker.new(options)
end

return Tzar
