--[[
    Tzar UI Library - Section Component
    Collapsible section with header and content container
]]

local TweenService = game:GetService("TweenService")

local Utils = require("../../Core/Utils")
local Signal = require("../../Core/Signal")
local Component = require("../Base/Component")

-- Lazy load to avoid circular dependencies
local ButtonGroup
local Paragraph
local Button
local Toggle
local Slider
local Dropdown
local Keybind
local TextBox
local ColorPicker

local Section = setmetatable({}, Component)
Section.__index = Section

-- Tween presets - smooth animations
local TWEEN_SMOOTH = TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local TWEEN_FAST = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

-- Header height constant
local HEADER_HEIGHT = 40

function Section.new(options, parentTab)
	local self = Component.new(options)
	setmetatable(self, Section)

	self._expanded = not (options.Collapsed or false)
	self._contentHeight = 0
	self._parentTab = parentTab -- Reference to parent Tab for registration

	-- Main section container
	self.Instance = Utils.create("Frame", {
		Name = "Section",
		BackgroundColor3 = Color3.fromRGB(16, 16, 16),
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, HEADER_HEIGHT),
		LayoutOrder = options.LayoutOrder or 0,
		ClipsDescendants = true,
	})

	Utils.applyCorner(self.Instance, 16)

	-- Header (clickable)
	self._header = Utils.create("ImageButton", {
		Name = "Header",
		Image = "rbxassetid://116513646251702",
		ImageColor3 = Color3.fromRGB(22, 22, 22),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, HEADER_HEIGHT),
		AutoButtonColor = false,
		Parent = self.Instance,
	})

	-- Section name
	self._nameLabel = Utils.create("TextLabel", {
		Name = "Name",
		Text = options.Name or "Section",
		Font = Enum.Font.GothamMedium,
		TextSize = 16,
		TextColor3 = Color3.fromRGB(249, 249, 249),
		TextXAlignment = Enum.TextXAlignment.Left,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 12, 0, 0),
		Size = UDim2.new(1, -24, 1, 0),
		Parent = self._header,
	})

	-- Content container
	self._container = Utils.create("Frame", {
		Name = "Container",
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 0, 0, HEADER_HEIGHT),
		Size = UDim2.new(1, 0, 0, 0),
		Parent = self.Instance,
	})

	Utils.applyListLayout(self._container, { Padding = 4 })
	Utils.applyPadding(self._container, 4, 4, 8, 4)

	-- Track content size changes
	table.insert(
		self._connections,
		self._container:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
			self._contentHeight = self._container.AbsoluteSize.Y
			if self._expanded then
				self:_updateSize(false)
			end
		end)
	)

	-- Signals
	self.OnToggle = Signal.new()

	-- Header click to toggle
	table.insert(
		self._connections,
		self._header.MouseButton1Click:Connect(function()
			self:Toggle()
		end)
	)

	-- Hover effect on header
	table.insert(
		self._connections,
		self._header.MouseEnter:Connect(function()
			TweenService:Create(self._header, TWEEN_FAST, {
				ImageColor3 = Color3.fromRGB(26, 26, 26),
			}):Play()
		end)
	)

	table.insert(
		self._connections,
		self._header.MouseLeave:Connect(function()
			TweenService:Create(self._header, TWEEN_FAST, {
				ImageColor3 = Color3.fromRGB(22, 22, 22),
			}):Play()
		end)
	)

	-- Set initial size if expanded
	if self._expanded then
		task.defer(function()
			self:_updateSize(false)
		end)
	end

	return self
end

-- Update section size
function Section:_updateSize(animate: boolean)
	local targetHeight = HEADER_HEIGHT
	if self._expanded then
		targetHeight = HEADER_HEIGHT + self._contentHeight
	end

	if animate then
		TweenService:Create(self.Instance, TWEEN_SMOOTH, {
			Size = UDim2.new(1, 0, 0, targetHeight),
		}):Play()
	else
		self.Instance.Size = UDim2.new(1, 0, 0, targetHeight)
	end
end

-- Toggle expand/collapse
function Section:Toggle()
	if self._expanded then
		self:Collapse()
	else
		self:Expand()
	end
end

-- Expand section
function Section:Expand()
	self._expanded = true
	self:_updateSize(true)
	self.OnToggle:Fire(true)
end

-- Collapse section
function Section:Collapse()
	self._expanded = false
	self:_updateSize(true)
	self.OnToggle:Fire(false)
end

-- Check if expanded
function Section:IsExpanded(): boolean
	return self._expanded
end

-- Set section name
function Section:SetName(name: string)
	self._nameLabel.Text = name
	return self
end

-- Get the content container
function Section:GetContainer(): Frame
	return self._container
end

-- Helper to register element with CommandMenu
function Section:_registerElement(element, title, elementType)
	if self._parentTab and self._parentTab._window and self._parentTab._window.RegisterElement then
		self._parentTab._window:RegisterElement(element, self._parentTab, title, elementType)
	end
end

-- Add a button group
function Section:AddButtonGroup(options)
	if not ButtonGroup then
		ButtonGroup = require("../Action/ButtonGroup")
	end
	local group = ButtonGroup.new(options or {})
	group:Mount(self._container)
	return group
end

-- Add a paragraph
function Section:AddParagraph(options)
	if not Paragraph then
		Paragraph = require("./Paragraph")
	end
	local para = Paragraph.new(options)
	para:Mount(self._container)
	self:_registerElement(para, options.Title or "Paragraph", "Paragraph")
	return para
end

-- Add a button
function Section:AddButton(options)
	if not Button then
		Button = require("../Action/Button")
	end
	local btn = Button.new(options)
	btn:Mount(self._container)
	self:_registerElement(btn, options.Name or "Button", "Button")
	return btn
end

-- Add a toggle
function Section:AddToggle(options)
	if not Toggle then
		Toggle = require("../Input/Toggle")
	end
	local toggle = Toggle.new(options)
	if options.Callback then
		toggle.OnToggle:Connect(options.Callback)
	end
	toggle:Mount(self._container)
	self:_registerElement(toggle, options.Title or "Toggle", "Toggle")
	return toggle
end

-- Add a slider
function Section:AddSlider(options)
	if not Slider then
		Slider = require("../Input/Slider")
	end
	local slider = Slider.new(options)
	if options.Callback then
		slider.OnChanged:Connect(options.Callback)
	end
	slider:Mount(self._container)
	self:_registerElement(slider, options.Title or "Slider", "Slider")
	return slider
end

-- Add a dropdown
function Section:AddDropdown(options)
	if not Dropdown then
		Dropdown = require("../Input/Dropdown")
	end
	local dropdown = Dropdown.new(options)
	if options.Callback then
		dropdown.OnChanged:Connect(options.Callback)
	end
	dropdown:Mount(self._container)
	self:_registerElement(dropdown, options.Title or "Dropdown", "Dropdown")
	return dropdown
end

-- Add a keybind
function Section:AddKeybind(options)
	if not Keybind then
		Keybind = require("../Input/Keybind")
	end
	local keybind = Keybind.new(options)
	keybind:Mount(self._container)
	self:_registerElement(keybind, options.Title or "Keybind", "Keybind")
	return keybind
end

-- Add a textbox
function Section:AddTextBox(options)
	if not TextBox then
		TextBox = require("../Input/TextBox")
	end
	local textbox = TextBox.new(options)
	textbox:Mount(self._container)
	self:_registerElement(textbox, options.Title or "TextBox", "TextBox")
	return textbox
end

-- Add a colorpicker
function Section:AddColorPicker(options)
	if not ColorPicker then
		ColorPicker = require("../Input/ColorPicker")
	end
	local colorpicker = ColorPicker.new(options)
	colorpicker:Mount(self._container)
	self:_registerElement(colorpicker, options.Title or "Color", "ColorPicker")
	return colorpicker
end

function Section:Destroy()
	self.OnToggle:Destroy()
	Component.Destroy(self)
end

return Section
