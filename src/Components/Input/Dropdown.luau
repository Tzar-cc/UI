--[[
    Tzar UI Library - Dropdown Component
    Selectable list with search and multi-select support
]]

local TweenService = game:GetService("TweenService")

local Utils = require("../../Core/Utils")
local Signal = require("../../Core/Signal")
local Component = require("../Base/Component")

local Dropdown = setmetatable({}, Component)
Dropdown.__index = Dropdown

-- Tween presets
local TWEEN_FAST = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

-- Constants
local HEADER_HEIGHT = 36
local OPTION_HEIGHT = 28
local MAX_LIST_HEIGHT = 180
local SEARCH_HEIGHT = 32
local ACTION_HEIGHT = 28

function Dropdown.new(options)
	local self = Component.new(options)
	setmetatable(self, Dropdown)

	self._titleText = options.Title or "Dropdown"
	self._options = options.Options or {}
	self._multi = options.Multi or false
	self._callback = options.Callback
	self._expanded = false

	-- Handle default value(s)
	self._selected = {}
	if self._multi then
		if type(options.Default) == "table" then
			for _, v in ipairs(options.Default) do
				self._selected[v] = true
			end
		elseif options.Default then
			self._selected[options.Default] = true
		end
	else
		self._singleSelected = options.Default
	end

	-- Main Container
	self.Instance = Utils.create("Frame", {
		Name = "Dropdown",
		BackgroundColor3 = Color3.fromRGB(20, 20, 20),
		BackgroundTransparency = 1,
		AutomaticSize = Enum.AutomaticSize.Y,
		Size = UDim2.new(1, 0, 0, HEADER_HEIGHT),
		LayoutOrder = options.LayoutOrder or 0,
		ClipsDescendants = true,
	})

	-- Background
	self._background = Utils.create("Frame", {
		Name = "Background",
		BackgroundColor3 = Color3.fromRGB(20, 20, 20),
		Size = UDim2.new(1, 0, 1, 0),
		Parent = self.Instance,
		ZIndex = 1,
	})
	Utils.applyCorner(self._background, 12)

	Utils.create("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 0),
		Parent = self._background,
	})

	-- Header (Clickable)
	self._header = Utils.create("TextButton", {
		Name = "Header",
		Text = "",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, HEADER_HEIGHT),
		LayoutOrder = 0,
		Parent = self._background,
		AutoButtonColor = false,
		ZIndex = 2,
	})

	Utils.applyPadding(self._header, 0, 12, 0, 12)

	-- Title
	self._titleLabel = Utils.create("TextLabel", {
		Name = "Title",
		Text = self._titleText,
		Font = Enum.Font.Gotham,
		TextSize = 14,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextXAlignment = Enum.TextXAlignment.Left,
		BackgroundTransparency = 1,
		Size = UDim2.new(0.5, 0, 1, 0),
		Parent = self._header,
		ZIndex = 3,
	})

	-- Right container
	local rightContainer = Utils.create("Frame", {
		Name = "RightContainer",
		BackgroundTransparency = 1,
		Size = UDim2.new(0.5, 0, 1, 0),
		Position = UDim2.new(0.5, 0, 0, 0),
		Parent = self._header,
		ZIndex = 3,
	})

	-- Status Label
	self._statusLabel = Utils.create("TextLabel", {
		Name = "Status",
		Text = self:_getStatusText(),
		Font = Enum.Font.Gotham,
		TextSize = 13,
		TextColor3 = Color3.fromRGB(140, 140, 140),
		TextXAlignment = Enum.TextXAlignment.Right,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -26, 1, 0),
		Parent = rightContainer,
		ZIndex = 3,
		TextTruncate = Enum.TextTruncate.AtEnd,
	})

	-- Arrow Icon
	self._arrow = Utils.create("ImageLabel", {
		Name = "Arrow",
		Image = "rbxassetid://6034818372",
		BackgroundTransparency = 1,
		Size = UDim2.new(0, 16, 0, 16),
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, 0, 0.5, 0),
		ImageColor3 = Color3.fromRGB(140, 140, 140),
		Parent = rightContainer,
		ZIndex = 3,
	})

	-- Content Container
	self._content = Utils.create("Frame", {
		Name = "Content",
		BackgroundColor3 = Color3.fromRGB(16, 16, 16),
		BackgroundTransparency = 0,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		LayoutOrder = 1,
		Parent = self._background,
		ClipsDescendants = true,
		Visible = false,
	})

	Utils.applyPadding(self._content, 8, 8, 8, 8)
	Utils.applyListLayout(self._content, { Padding = 6 })

	-- Search Bar
	self._searchBar = Utils.create("TextBox", {
		Name = "Search",
		PlaceholderText = "Search...",
		Text = "",
		Font = Enum.Font.Gotham,
		TextSize = 13,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		PlaceholderColor3 = Color3.fromRGB(100, 100, 100),
		BackgroundColor3 = Color3.fromRGB(30, 30, 30),
		Size = UDim2.new(1, 0, 0, SEARCH_HEIGHT),
		LayoutOrder = 0,
		Parent = self._content,
		TextXAlignment = Enum.TextXAlignment.Left,
	})
	Utils.applyCorner(self._searchBar, 8)
	Utils.applyPadding(self._searchBar, 0, 10, 0, 10)

	-- Multi-select Actions
	if self._multi then
		local actionFrame = Utils.create("Frame", {
			Name = "Actions",
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, ACTION_HEIGHT),
			LayoutOrder = 1,
			Parent = self._content,
		})
		Utils.applyListLayout(actionFrame, {
			Padding = 6,
			Direction = Enum.FillDirection.Horizontal,
			VerticalAlignment = Enum.VerticalAlignment.Center,
		})

		local function createActionBtn(text, callback)
			local btn = Utils.create("TextButton", {
				Name = text,
				Text = text,
				Font = Enum.Font.Gotham,
				TextSize = 14,
				TextColor3 = Color3.fromRGB(212, 212, 212),
				BackgroundColor3 = Color3.fromRGB(22, 22, 22),
				BackgroundTransparency = 0.05,
				Size = UDim2.new(0.5, -3, 1, 0),
				Parent = actionFrame,
				AutoButtonColor = false,
			})
			Utils.applyCorner(btn, 18)

			table.insert(
				self._connections,
				btn.MouseEnter:Connect(function()
					TweenService:Create(
						btn,
						TWEEN_FAST,
						{ BackgroundColor3 = Color3.fromRGB(30, 30, 30), BackgroundTransparency = 0 }
					):Play()
				end)
			)
			table.insert(
				self._connections,
				btn.MouseLeave:Connect(function()
					TweenService:Create(
						btn,
						TWEEN_FAST,
						{ BackgroundColor3 = Color3.fromRGB(22, 22, 22), BackgroundTransparency = 0.05 }
					):Play()
				end)
			)
			table.insert(self._connections, btn.MouseButton1Click:Connect(callback))
			return btn
		end

		createActionBtn("Select All", function()
			self:SelectAll()
		end)
		createActionBtn("Deselect All", function()
			self:DeselectAll()
		end)
	end

	-- Options List
	self._list = Utils.create("ScrollingFrame", {
		Name = "List",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 0),
		CanvasSize = UDim2.new(0, 0, 0, 0),
		ScrollBarThickness = 3,
		ScrollBarImageColor3 = Color3.fromRGB(60, 60, 60),
		LayoutOrder = 2,
		Parent = self._content,
		AutomaticSize = Enum.AutomaticSize.None,
	})

	Utils.create("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 3),
		Parent = self._list,
	})

	self._optionButtons = {}

	-- Signals
	self.OnChanged = Signal.new()
	self.Changed = self.OnChanged -- Alias for Config system

	-- Events
	table.insert(
		self._connections,
		self._header.MouseButton1Click:Connect(function()
			self:Toggle()
		end)
	)

	table.insert(
		self._connections,
		self._searchBar:GetPropertyChangedSignal("Text"):Connect(function()
			self:_filterOptions(self._searchBar.Text)
		end)
	)

	-- Initialize Options
	self:_refreshOptions()

	-- Hover animations
	table.insert(
		self._connections,
		self._header.MouseEnter:Connect(function()
			TweenService:Create(self._background, TWEEN_FAST, { BackgroundColor3 = Color3.fromRGB(26, 26, 26) }):Play()
			TweenService:Create(self._arrow, TWEEN_FAST, { ImageColor3 = Color3.fromRGB(200, 200, 200) }):Play()
		end)
	)

	table.insert(
		self._connections,
		self._header.MouseLeave:Connect(function()
			if not self._expanded then
				TweenService:Create(self._background, TWEEN_FAST, { BackgroundColor3 = Color3.fromRGB(20, 20, 20) })
					:Play()
				TweenService:Create(self._arrow, TWEEN_FAST, { ImageColor3 = Color3.fromRGB(140, 140, 140) }):Play()
			end
		end)
	)

	return self
end

function Dropdown:_getStatusText()
	if self._multi then
		local count = 0
		for _ in pairs(self._selected) do
			count = count + 1
		end
		if count == 0 then
			return "None"
		end
		if count == #self._options then
			return "All"
		end
		return tostring(count) .. " Selected"
	else
		return self._singleSelected or "None"
	end
end

function Dropdown:_refreshOptions()
	for _, btn in pairs(self._optionButtons) do
		btn:Destroy()
	end
	self._optionButtons = {}

	for i, option in ipairs(self._options) do
		local isSelected = self._multi and self._selected[option]
			or (not self._multi and self._singleSelected == option)

		local btn = Utils.create("TextButton", {
			Name = option,
			Text = "",
			BackgroundColor3 = isSelected and Color3.fromRGB(9, 156, 75) or Color3.fromRGB(32, 32, 32),
			Size = UDim2.new(1, 0, 0, OPTION_HEIGHT),
			Parent = self._list,
			LayoutOrder = i,
			AutoButtonColor = false,
		})
		Utils.applyCorner(btn, 6)

		Utils.create("TextLabel", {
			Name = "Label",
			Text = option,
			Font = Enum.Font.Gotham,
			TextSize = 13,
			TextColor3 = isSelected and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(190, 190, 190),
			TextXAlignment = Enum.TextXAlignment.Left,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, -20, 1, 0),
			Position = UDim2.new(0, 10, 0, 0),
			Parent = btn,
		})

		table.insert(
			self._connections,
			btn.MouseEnter:Connect(function()
				if
					not (self._multi and self._selected[option] or (not self._multi and self._singleSelected == option))
				then
					TweenService:Create(btn, TWEEN_FAST, { BackgroundColor3 = Color3.fromRGB(42, 42, 42) }):Play()
				end
			end)
		)

		table.insert(
			self._connections,
			btn.MouseLeave:Connect(function()
				local selected = self._multi and self._selected[option]
					or (not self._multi and self._singleSelected == option)
				if not selected then
					TweenService:Create(btn, TWEEN_FAST, { BackgroundColor3 = Color3.fromRGB(32, 32, 32) }):Play()
				end
			end)
		)

		table.insert(
			self._connections,
			btn.MouseButton1Click:Connect(function()
				self:Select(option)
			end)
		)

		self._optionButtons[option] = btn
	end

	self:_updateListHeight()
end

function Dropdown:_filterOptions(text)
	local lowerText = text:lower()
	for option, btn in pairs(self._optionButtons) do
		btn.Visible = text == "" or option:lower():find(lowerText, 1, true) ~= nil
	end
	self:_updateListHeight()
end

function Dropdown:_updateListHeight()
	local layout = self._list:FindFirstChildWhichIsA("UIListLayout")
	local padding = layout and layout.Padding.Offset or 3

	local visibleCount = 0
	for _, child in ipairs(self._list:GetChildren()) do
		if child:IsA("GuiObject") and child.Visible then
			visibleCount = visibleCount + 1
		end
	end

	local contentHeight = visibleCount * (OPTION_HEIGHT + padding)
	local listHeight = math.min(contentHeight, MAX_LIST_HEIGHT)

	self._list.CanvasSize = UDim2.new(0, 0, 0, contentHeight)
	self._list.Size = UDim2.new(1, 0, 0, listHeight)
end

function Dropdown:Select(option)
	if self._multi then
		self._selected[option] = not self._selected[option] or nil
	else
		self._singleSelected = option
		self:Toggle()
	end

	self:_updateVisuals()

	if self._multi then
		local list = {}
		for k in pairs(self._selected) do
			table.insert(list, k)
		end
		self.OnChanged:Fire(list)
		if self._callback then
			self._callback(list)
		end
	else
		self.OnChanged:Fire(self._singleSelected)
		if self._callback then
			self._callback(self._singleSelected)
		end
	end
end

function Dropdown:SelectAll()
	if not self._multi then
		return
	end
	for _, option in ipairs(self._options) do
		self._selected[option] = true
	end
	self:_updateVisuals()
	local list = {}
	for k in pairs(self._selected) do
		table.insert(list, k)
	end
	self.OnChanged:Fire(list)
	if self._callback then
		self._callback(list)
	end
end

function Dropdown:DeselectAll()
	if not self._multi then
		return
	end
	self._selected = {}
	self:_updateVisuals()
	self.OnChanged:Fire({})
	if self._callback then
		self._callback({})
	end
end

function Dropdown:_updateVisuals()
	self._statusLabel.Text = self:_getStatusText()

	for option, btn in pairs(self._optionButtons) do
		local isSelected = self._multi and self._selected[option]
			or (not self._multi and self._singleSelected == option)
		local color = isSelected and Color3.fromRGB(9, 156, 75) or Color3.fromRGB(32, 32, 32)
		local textColor = isSelected and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(190, 190, 190)

		TweenService:Create(btn, TWEEN_FAST, { BackgroundColor3 = color }):Play()
		local label = btn:FindFirstChild("Label")
		if label then
			TweenService:Create(label, TWEEN_FAST, { TextColor3 = textColor }):Play()
		end
	end
end

function Dropdown:Toggle()
	self._expanded = not self._expanded
	self._content.Visible = self._expanded

	if self._expanded then
		TweenService:Create(self._arrow, TWEEN_FAST, { Rotation = 180 }):Play()
		TweenService:Create(self._background, TWEEN_FAST, { BackgroundColor3 = Color3.fromRGB(26, 26, 26) }):Play()
	else
		TweenService:Create(self._arrow, TWEEN_FAST, { Rotation = 0 }):Play()
		TweenService:Create(self._background, TWEEN_FAST, { BackgroundColor3 = Color3.fromRGB(20, 20, 20) }):Play()
		self._content.Visible = false
	end
end

-- Get value (for Config system)
function Dropdown:GetValue()
	if self._multi then
		local list = {}
		for k in pairs(self._selected) do
			table.insert(list, k)
		end
		return list
	else
		return self._singleSelected
	end
end

-- Set value (for Config system)
function Dropdown:SetValue(value)
	if self._multi then
		self._selected = {}
		if type(value) == "table" then
			for _, v in ipairs(value) do
				self._selected[v] = true
			end
		elseif value then
			self._selected[value] = true
		end
	else
		self._singleSelected = value
	end
	self:_updateVisuals()
	self.OnChanged:Fire(self:GetValue())
	return self
end

function Dropdown:Refresh(options, default)
	self._options = options or {}
	if default then
		self._selected = {}
		if self._multi and type(default) == "table" then
			for _, v in ipairs(default) do
				self._selected[v] = true
			end
		else
			self._singleSelected = default
		end
	end
	self:_refreshOptions()
	self:_updateVisuals()
end

function Dropdown:Destroy()
	self.OnChanged:Destroy()
	Component.Destroy(self)
end

return Dropdown
