--[[
    Tzar UI Library - ButtonGroup Component
    Container for grouping elements horizontally with wrapping
]]

local Utils = require("../../Core/Utils")
local Component = require("../Base/Component")

-- Lazy load to avoid circular dependencies
local Button
local Paragraph
local Slider
local Dropdown

local ButtonGroup = setmetatable({}, Component)
ButtonGroup.__index = ButtonGroup

function ButtonGroup.new(options)
	local self = Component.new(options or {})
	setmetatable(self, ButtonGroup)

	-- Container frame
	self.Instance = Utils.create("Frame", {
		Name = "ButtonGroup",
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 0),
		LayoutOrder = (options or {}).LayoutOrder or 0,
	})

	-- Horizontal layout with wrapping
	Utils.applyListLayout(self.Instance, {
		Padding = 4,
		Direction = Enum.FillDirection.Horizontal,
		Wraps = true,
		VerticalAlignment = Enum.VerticalAlignment.Center,
	})

	-- Store padding reference for auto-detection
	self._padding = Utils.applyPadding(self.Instance, 0, 6, 0, 6)

	-- Auto-detect parent and adjust padding
	table.insert(
		self._connections,
		self.Instance:GetPropertyChangedSignal("Parent"):Connect(function()
			local parent = self.Instance.Parent
			if parent then
				if parent:IsA("ScrollingFrame") then
					self._padding.PaddingLeft = UDim.new(0, 0)
					self._padding.PaddingRight = UDim.new(0, 0)
				else
					self._padding.PaddingLeft = UDim.new(0, 6)
					self._padding.PaddingRight = UDim.new(0, 6)
				end
			end
		end)
	)

	self._items = {}

	return self
end

-- Add a button to this group
function ButtonGroup:AddButton(options)
	if not Button then
		Button = require("./Button")
	end

	local btn = Button.new({
		Name = options.Name or "Button",
		Variant = options.Variant or "Secondary",
		Callback = options.Callback,
		LayoutOrder = options.LayoutOrder or #self._items + 1,
	})
	btn:Mount(self.Instance)
	table.insert(self._items, btn)
	return btn
end

-- Add a paragraph to this group
function ButtonGroup:AddParagraph(options)
	if not Paragraph then
		Paragraph = require("../Display/Paragraph")
	end

	local para = Paragraph.new({
		Title = options.Title or "Title",
		Description = options.Description,
		Callback = options.Callback,
		LayoutOrder = options.LayoutOrder or #self._items + 1,
	})
	para:Mount(self.Instance)
	table.insert(self._items, para)
	return para
end

-- Add a slider to this group
function ButtonGroup:AddSlider(options)
	if not Slider then
		Slider = require("../Input/Slider")
	end

	local slider = Slider.new({
		Title = options.Title or "Slider",
		Description = options.Description,
		Min = options.Min,
		Max = options.Max,
		Default = options.Default,
		Increment = options.Increment,
		Suffix = options.Suffix,
		LayoutOrder = options.LayoutOrder or #self._items + 1,
	})

	if options.Callback then
		slider.OnChanged:Connect(options.Callback)
	end

	slider:Mount(self.Instance)
	table.insert(self._items, slider)
	return slider
end

-- Add a dropdown to this group
function ButtonGroup:AddDropdown(options)
	if not Dropdown then
		Dropdown = require("../Input/Dropdown")
	end

	local dropdown = Dropdown.new({
		Title = options.Title or "Dropdown",
		Options = options.Options,
		Default = options.Default,
		Multi = options.Multi,
		Callback = options.Callback,
		LayoutOrder = options.LayoutOrder or #self._items + 1,
	})

	if options.Callback then
		dropdown.OnChanged:Connect(options.Callback)
	end

	dropdown:Mount(self.Instance)
	table.insert(self._items, dropdown)
	return dropdown
end

function ButtonGroup:Destroy()
	for _, item in self._items do
		item:Destroy()
	end
	Component.Destroy(self)
end

return ButtonGroup
