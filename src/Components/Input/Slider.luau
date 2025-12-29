--[[
    Tzar UI Library - Slider Component
    Draggable slider with min/max values and increments
]]

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Utils = require("../../Core/Utils")
local Signal = require("../../Core/Signal")
local Component = require("../Base/Component")

local Slider = setmetatable({}, Component)
Slider.__index = Slider

-- Tween presets
local TWEEN_FAST = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

-- Slider dimensions
local TRACK_HEIGHT = 6
local KNOB_SIZE = 16
local SLIDER_HEIGHT = 24

function Slider.new(options)
	local self = Component.new(options)
	setmetatable(self, Slider)

	self._min = options.Min or 0
	self._max = options.Max or 100
	self._value = math.clamp(options.Default or self._min, self._min, self._max)
	self._increment = options.Increment or 1
	self._suffix = options.Suffix or ""
	self._dragging = false

	-- Main container
	self.Instance = Utils.create("TextButton", {
		Name = "Slider",
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = Color3.fromRGB(20, 20, 20),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 0),
		AutoButtonColor = false,
		Text = "",
		LayoutOrder = options.LayoutOrder or 0,
	})

	Utils.applyCorner(self.Instance, 12)
	Utils.applyListLayout(self.Instance, { Padding = 2 })
	Utils.applyPadding(self.Instance, 8, 12, 10, 12)

	-- Header container
	local headerContainer = Utils.create("Frame", {
		Name = "Header",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 18),
		Parent = self.Instance,
	})

	-- Title
	self._title = Utils.create("TextLabel", {
		Name = "Title",
		Text = options.Title or "Slider",
		Font = Enum.Font.Gotham,
		TextSize = 14,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextXAlignment = Enum.TextXAlignment.Left,
		BackgroundTransparency = 1,
		Size = UDim2.new(0.7, 0, 1, 0),
		Parent = headerContainer,
	})

	-- Value Label
	self._valueLabel = Utils.create("TextLabel", {
		Name = "Value",
		Text = tostring(self._value) .. self._suffix,
		Font = Enum.Font.GothamMedium,
		TextSize = 14,
		TextColor3 = Color3.fromRGB(140, 140, 140),
		TextXAlignment = Enum.TextXAlignment.Right,
		BackgroundTransparency = 1,
		Size = UDim2.new(0.3, 0, 1, 0),
		Position = UDim2.new(0.7, 0, 0, 0),
		Parent = headerContainer,
	})

	-- Description
	if options.Description then
		self._description = Utils.create("TextLabel", {
			Name = "Description",
			Text = options.Description,
			Font = Enum.Font.Gotham,
			TextSize = 12,
			TextColor3 = Color3.fromRGB(140, 140, 140),
			TextWrapped = true,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Top,
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 12),
			Parent = self.Instance,
		})
	end

	-- Slider area container
	local sliderContainer = Utils.create("Frame", {
		Name = "SliderContainer",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, SLIDER_HEIGHT),
		Parent = self.Instance,
	})

	-- Track Background
	self._track = Utils.create("Frame", {
		Name = "Track",
		BackgroundColor3 = Color3.fromRGB(35, 35, 35),
		Size = UDim2.new(1, 0, 0, TRACK_HEIGHT),
		Position = UDim2.new(0, 0, 0.5, 0),
		AnchorPoint = Vector2.new(0, 0.5),
		BorderSizePixel = 0,
		Parent = sliderContainer,
	})
	Utils.applyCorner(self._track, TRACK_HEIGHT / 2)

	-- Fill
	self._fill = Utils.create("Frame", {
		Name = "Fill",
		BackgroundColor3 = Color3.fromRGB(9, 156, 75),
		Size = UDim2.new(0, 0, 1, 0),
		BorderSizePixel = 0,
		Parent = self._track,
	})
	Utils.applyCorner(self._fill, TRACK_HEIGHT / 2)

	-- Knob
	self._knob = Utils.create("Frame", {
		Name = "Knob",
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		Size = UDim2.new(0, KNOB_SIZE, 0, KNOB_SIZE),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0, 0, 0.5, 0),
		BorderSizePixel = 0,
		Parent = self._track,
		ZIndex = 2,
	})
	Utils.applyCorner(self._knob, KNOB_SIZE / 2)

	-- Signal
	self.OnChanged = Signal.new()
	self.Changed = self.OnChanged -- Alias for Config system

	-- Hover animations
	table.insert(
		self._connections,
		self.Instance.MouseEnter:Connect(function()
			TweenService:Create(self.Instance, TWEEN_FAST, {
				BackgroundTransparency = 0,
				BackgroundColor3 = Color3.fromRGB(26, 26, 26),
			}):Play()
			TweenService:Create(self._knob, TWEEN_FAST, {
				Size = UDim2.new(0, KNOB_SIZE + 2, 0, KNOB_SIZE + 2),
			}):Play()
		end)
	)

	table.insert(
		self._connections,
		self.Instance.MouseLeave:Connect(function()
			if not self._dragging then
				TweenService:Create(self.Instance, TWEEN_FAST, {
					BackgroundTransparency = 1,
					BackgroundColor3 = Color3.fromRGB(20, 20, 20),
				}):Play()
				TweenService:Create(self._knob, TWEEN_FAST, {
					Size = UDim2.new(0, KNOB_SIZE, 0, KNOB_SIZE),
				}):Play()
			end
		end)
	)

	-- Input Handling
	local function updateValue(input)
		local absolutePos = self._track.AbsolutePosition
		local absoluteSize = self._track.AbsoluteSize

		local mouseX = input.Position.X
		local relativeX = math.clamp(mouseX - absolutePos.X, 0, absoluteSize.X)
		local alpha = relativeX / absoluteSize.X

		local newValue = self._min + (self._max - self._min) * alpha

		if self._increment > 0 then
			newValue = math.round(newValue / self._increment) * self._increment
		end

		newValue = math.clamp(newValue, self._min, self._max)

		if newValue ~= self._value then
			self:SetValue(newValue)
		end
	end

	table.insert(
		self._connections,
		self._track.InputBegan:Connect(function(input)
			if
				input.UserInputType == Enum.UserInputType.MouseButton1
				or input.UserInputType == Enum.UserInputType.Touch
			then
				self._dragging = true
				updateValue(input)
			end
		end)
	)

	table.insert(
		self._connections,
		self._knob.InputBegan:Connect(function(input)
			if
				input.UserInputType == Enum.UserInputType.MouseButton1
				or input.UserInputType == Enum.UserInputType.Touch
			then
				self._dragging = true
				updateValue(input)
			end
		end)
	)

	table.insert(
		self._connections,
		UserInputService.InputChanged:Connect(function(input)
			if
				self._dragging
				and (
					input.UserInputType == Enum.UserInputType.MouseMovement
					or input.UserInputType == Enum.UserInputType.Touch
				)
			then
				updateValue(input)
			end
		end)
	)

	table.insert(
		self._connections,
		UserInputService.InputEnded:Connect(function(input)
			if
				input.UserInputType == Enum.UserInputType.MouseButton1
				or input.UserInputType == Enum.UserInputType.Touch
			then
				self._dragging = false
			end
		end)
	)

	-- Set initial visual state
	self:_updateVisual(false)

	return self
end

function Slider:_updateVisual(animate: boolean)
	local alpha = (self._value - self._min) / (self._max - self._min)
	alpha = math.clamp(alpha, 0, 1)

	self._valueLabel.Text = string.format("%.2f", self._value):gsub("%.?0+$", "") .. self._suffix

	local targetSize = UDim2.new(alpha, 0, 1, 0)
	local targetPos = UDim2.new(alpha, 0, 0.5, 0)

	if animate then
		TweenService:Create(self._fill, TWEEN_FAST, { Size = targetSize }):Play()
		TweenService:Create(self._knob, TWEEN_FAST, { Position = targetPos }):Play()
	else
		self._fill.Size = targetSize
		self._knob.Position = targetPos
	end
end

-- Set value
function Slider:SetValue(value: number)
	local clamped = math.clamp(value, self._min, self._max)
	if self._increment > 0 then
		clamped = math.round(clamped / self._increment) * self._increment
	end

	if self._value ~= clamped then
		self._value = clamped
		self:_updateVisual(true)
		self.OnChanged:Fire(self._value)
	end
	return self
end

-- Get value
function Slider:GetValue(): number
	return self._value
end

-- Set title
function Slider:SetTitle(title: string)
	self._title.Text = title
	return self
end

-- Set description
function Slider:SetDescription(description: string)
	if self._description then
		self._description.Text = description
	end
	return self
end

function Slider:Destroy()
	self.OnChanged:Destroy()
	Component.Destroy(self)
end

return Slider
