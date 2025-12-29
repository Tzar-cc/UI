--[[
    Tzar UI Library - Tab Class
    Represents a tab content area with methods to add components
]]

-- Lazy load to avoid circular dependencies
local Section
local ButtonGroup
local Paragraph
local Button
local Toggle
local Slider
local Dropdown
local Keybind
local TextBox
local ColorPicker

local Tab = {}
Tab.__index = Tab

function Tab.new(contentScroll, tabBtn, tabIndex, window, name)
	local self = setmetatable({}, Tab)

	self.Instance = contentScroll
	self.Button = tabBtn
	self.Index = tabIndex
	self.Name = name or ("Tab" .. tabIndex)
	self._window = window

	return self
end

-- Add a section to this tab
function Tab:AddSection(options)
	if not Section then
		Section = require("../Components/Display/Section")
	end

	local sectionObj = Section.new({
		Name = options.Name or "Section",
		Flag = options.Flag or options.Name,
		Collapsed = options.Collapsed,
		LayoutOrder = options.LayoutOrder,
	}, self) -- Pass self (Tab) as parent for registration
	sectionObj.Instance.Parent = self.Instance
	return sectionObj
end

-- Add a button group to this tab
function Tab:AddButtonGroup(options)
	if not ButtonGroup then
		ButtonGroup = require("../Components/Action/ButtonGroup")
	end

	local group = ButtonGroup.new({
		LayoutOrder = options and options.LayoutOrder or nil,
	})
	group.Instance.Parent = self.Instance
	return group
end

-- Add a paragraph to this tab
function Tab:AddParagraph(options)
	if not Paragraph then
		Paragraph = require("../Components/Display/Paragraph")
	end

	local para = Paragraph.new({
		Title = options.Title or "Title",
		Description = options.Description,
		Callback = options.Callback,
		LayoutOrder = options.LayoutOrder,
	})
	para.Instance.Parent = self.Instance

	-- Register for search
	if self._window and self._window.RegisterElement then
		self._window:RegisterElement(para, self, options.Title or "Title", "Paragraph")
	end

	return para
end

-- Add a button to this tab
function Tab:AddButton(options)
	if not Button then
		Button = require("../Components/Action/Button")
	end

	local btn = Button.new({
		Name = options.Name or "Button",
		Flag = options.Flag or options.Name,
		Variant = options.Variant or "Secondary",
		Callback = options.Callback,
		LayoutOrder = options.LayoutOrder,
	})
	btn.Instance.Parent = self.Instance

	-- Register for search
	if self._window and self._window.RegisterElement then
		self._window:RegisterElement(btn, self, options.Name or "Button", "Button")
	end

	return btn
end

-- Add a toggle to this tab
function Tab:AddToggle(options)
	if not Toggle then
		Toggle = require("../Components/Input/Toggle")
	end

	local toggle = Toggle.new({
		Title = options.Title or "Toggle",
		Flag = options.Flag or options.Name or (self.Name .. options.Title),
		Description = options.Description,
		Default = options.Default,
		LayoutOrder = options.LayoutOrder,
	})

	if options.Callback then
		toggle.OnToggle:Connect(options.Callback)
	end

	toggle.Instance.Parent = self.Instance

	-- Register for search
	if self._window and self._window.RegisterElement then
		self._window:RegisterElement(toggle, self, options.Title or "Toggle", "Toggle")
	end

	return toggle
end

-- Add a slider to this tab
function Tab:AddSlider(options)
	if not Slider then
		Slider = require("../Components/Input/Slider")
	end

	local slider = Slider.new({
		Title = options.Title or "Slider",
		Flag = options.Flag or options.Name or (self.Name .. options.Title),
		Description = options.Description,
		Min = options.Min,
		Max = options.Max,
		Default = options.Default,
		Increment = options.Increment,
		Suffix = options.Suffix,
		LayoutOrder = options.LayoutOrder,
	})

	if options.Callback then
		slider.OnChanged:Connect(options.Callback)
	end

	slider.Instance.Parent = self.Instance

	-- Register for search
	if self._window and self._window.RegisterElement then
		self._window:RegisterElement(slider, self, options.Title or "Slider", "Slider")
	end

	return slider
end

-- Add a dropdown to this tab
function Tab:AddDropdown(options)
	if not Dropdown then
		Dropdown = require("../Components/Input/Dropdown")
	end

	local dropdown = Dropdown.new({
		Title = options.Title or "Dropdown",
		Flag = options.Flag or options.Name or (self.Name .. options.Title),
		Options = options.Options,
		Default = options.Default,
		Multi = options.Multi,
		Callback = options.Callback,
		LayoutOrder = options.LayoutOrder,
	})

	if options.Callback then
		dropdown.OnChanged:Connect(options.Callback)
	end

	dropdown.Instance.Parent = self.Instance

	-- Register for search
	if self._window and self._window.RegisterElement then
		self._window:RegisterElement(dropdown, self, options.Title or "Dropdown", "Dropdown")
	end

	return dropdown
end

-- Add a keybind to this tab
function Tab:AddKeybind(options)
	if not Keybind then
		Keybind = require("../Components/Input/Keybind")
	end

	local keybind = Keybind.new({
		Title = options.Title or "Keybind",
		Flag = options.Flag or options.Name or (self.Name .. options.Title),
		Description = options.Description,
		Default = options.Default,
		Callback = options.Callback,
		LayoutOrder = options.LayoutOrder,
	})

	keybind.Instance.Parent = self.Instance

	-- Register for search
	if self._window and self._window.RegisterElement then
		self._window:RegisterElement(keybind, self, options.Title or "Keybind", "Keybind")
	end

	return keybind
end

-- Add a textbox to this tab
function Tab:AddTextBox(options)
	if not TextBox then
		TextBox = require("../Components/Input/TextBox")
	end

	local textbox = TextBox.new({
		Title = options.Title or "TextBox",
		Flag = options.Flag or options.Name or (self.Name .. options.Title),
		Description = options.Description,
		Placeholder = options.Placeholder,
		Default = options.Default,
		ClearOnFocus = options.ClearOnFocus,
		Callback = options.Callback,
		LayoutOrder = options.LayoutOrder,
	})

	textbox.Instance.Parent = self.Instance

	if self._window and self._window.RegisterElement then
		self._window:RegisterElement(textbox, self, options.Title or "TextBox", "TextBox")
	end

	return textbox
end

-- Add a color picker to this tab
function Tab:AddColorPicker(options)
	if not ColorPicker then
		ColorPicker = require("../Components/Input/ColorPicker")
	end

	local colorpicker = ColorPicker.new({
		Title = options.Title or "Color",
		Flag = options.Flag or options.Name or (self.Name .. options.Title),
		Default = options.Default,
		Callback = options.Callback,
		LayoutOrder = options.LayoutOrder,
	})

	colorpicker.Instance.Parent = self.Instance

	if self._window and self._window.RegisterElement then
		self._window:RegisterElement(colorpicker, self, options.Title or "Color", "ColorPicker")
	end

	return colorpicker
end

return Tab
