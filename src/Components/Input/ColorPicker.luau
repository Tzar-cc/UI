--[[
    Tzar UI Library - ColorPicker Component
    HSV Picker with preview and expandable panel
]]

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Utils = require("../../Core/Utils")
local Signal = require("../../Core/Signal")
local Component = require("../Base/Component")

local ColorPicker = setmetatable({}, Component)
ColorPicker.__index = ColorPicker

-- Tween presets
local TWEEN_FAST = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

-- Dimensions
local PREVIEW_SIZE = 24
local PICKER_HEIGHT = 100
local HUE_WIDTH = 20

-- Helper functions
local function hsvToRgb(h, s, v)
	local c = v * s
	local x = c * (1 - math.abs((h / 60) % 2 - 1))
	local m = v - c
	local r, g, b =
		(h < 60 and c or h < 120 and x or 0),
		(h < 60 and x or h < 120 and c or h < 180 and c or h < 240 and x or 0),
		(h < 120 and 0 or h < 180 and x or h < 240 and c or h < 300 and c or x)
	return Color3.new(r + m, g + m, b + m)
end

local function rgbToHsv(color)
	local r, g, b = color.R, color.G, color.B
	local max, min = math.max(r, g, b), math.min(r, g, b)
	local h, s, v = 0, 0, max
	local d = max - min
	s = max == 0 and 0 or d / max
	if max == min then
		h = 0
	else
		if max == r then
			h = (g - b) / d + (g < b and 6 or 0)
		elseif max == g then
			h = (b - r) / d + 2
		else
			h = (r - g) / d + 4
		end
		h = h / 6
	end
	return h * 360, s, v
end

function ColorPicker.new(options)
	local self = Component.new(options)
	setmetatable(self, ColorPicker)

	self._value = options.Default or Color3.new(1, 1, 1)
	self._h, self._s, self._v = rgbToHsv(self._value)
	self._callback = options.Callback
	self._expanded = false
	self._dragging = nil

	-- Main container (Frame, not TextButton to avoid click bubbling)
	self.Instance = Utils.create("Frame", {
		Name = "ColorPicker",
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = Color3.fromRGB(20, 20, 20),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 0),
		LayoutOrder = options.LayoutOrder or 0,
	})

	Utils.applyCorner(self.Instance, 12)
	Utils.applyPadding(self.Instance, 8, 12, 8, 12)
	Utils.applyListLayout(self.Instance, { Padding = 8 })

	-- Header (clickable to toggle)
	self._header = Utils.create("TextButton", {
		Name = "Header",
		Text = "",
		Size = UDim2.new(1, 0, 0, PREVIEW_SIZE),
		BackgroundTransparency = 1,
		AutoButtonColor = false,
		Parent = self.Instance,
	})

	-- Title
	self._title = Utils.create("TextLabel", {
		Name = "Title",
		Text = options.Title or "Color",
		Font = Enum.Font.Gotham,
		TextSize = 14,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextXAlignment = Enum.TextXAlignment.Left,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -(PREVIEW_SIZE + 10), 1, 0),
		Parent = self._header,
	})

	-- Preview box
	self._preview = Utils.create("Frame", {
		Name = "Preview",
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, 0, 0.5, 0),
		Size = UDim2.new(0, PREVIEW_SIZE, 0, PREVIEW_SIZE),
		BackgroundColor3 = self._value,
		BorderSizePixel = 0,
		Parent = self._header,
	})
	Utils.applyCorner(self._preview, 6)

	-- Content (hidden by default)
	self._content = Utils.create("Frame", {
		Name = "Content",
		Size = UDim2.new(1, 0, 0, PICKER_HEIGHT),
		BackgroundTransparency = 1,
		Visible = false,
		Parent = self.Instance,
	})

	-- Saturation/Value Picker
	self._svPicker = Utils.create("ImageLabel", {
		Name = "SVPicker",
		Image = "rbxassetid://4155801252",
		BackgroundColor3 = hsvToRgb(self._h, 1, 1),
		Size = UDim2.new(1, -(HUE_WIDTH + 10), 1, 0),
		BorderSizePixel = 0,
		Parent = self._content,
	})
	Utils.applyCorner(self._svPicker, 6)

	-- Black overlay for value
	-- Utils.create("ImageLabel", {
	-- 	Name = "ValueOverlay",
	-- 	Image = "rbxassetid://4155801252",
	-- 	ImageColor3 = Color3.new(0, 0, 0),
	-- 	BackgroundTransparency = 1,
	-- 	Size = UDim2.new(1, 0, 1, 0),
	-- 	Rotation = -90,
	-- 	Parent = self._svPicker,
	-- })

	-- SV Cursor
	self._svCursor = Utils.create("Frame", {
		Name = "Cursor",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Size = UDim2.new(0, 10, 0, 10),
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderSizePixel = 0,
		Parent = self._svPicker,
	})
	Utils.applyCorner(self._svCursor, 5)
	Utils.applyStroke(self._svCursor, { Color = Color3.new(0, 0, 0), Thickness = 1 })

	-- Hue Picker
	self._huePicker = Utils.create("Frame", {
		Name = "HuePicker",
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, 0, 0, 0),
		Size = UDim2.new(0, HUE_WIDTH, 1, 0),
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderSizePixel = 0,
		Parent = self._content,
	})
	Utils.applyCorner(self._huePicker, 6)

	Utils.create("UIGradient", {
		Name = "HueGradient",
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
			ColorSequenceKeypoint.new(0.167, Color3.fromRGB(255, 255, 0)),
			ColorSequenceKeypoint.new(0.333, Color3.fromRGB(0, 255, 0)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
			ColorSequenceKeypoint.new(0.667, Color3.fromRGB(0, 0, 255)),
			ColorSequenceKeypoint.new(0.833, Color3.fromRGB(255, 0, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0)),
		}),
		Rotation = 90,
		Parent = self._huePicker,
	})

	-- Hue Cursor
	self._hueCursor = Utils.create("Frame", {
		Name = "Cursor",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Size = UDim2.new(1, 4, 0, 6),
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderSizePixel = 0,
		Parent = self._huePicker,
	})
	Utils.applyCorner(self._hueCursor, 3)
	Utils.applyStroke(self._hueCursor, { Color = Color3.new(0, 0, 0), Thickness = 1 })

	-- Signal
	self.OnChanged = Signal.new()
	self.Changed = self.OnChanged -- Alias for Config system

	-- Click header to toggle (not the whole container)
	table.insert(
		self._connections,
		self._header.MouseButton1Click:Connect(function()
			self:Toggle()
		end)
	)

	-- Hover effects on header
	table.insert(
		self._connections,
		self._header.MouseEnter:Connect(function()
			TweenService:Create(
				self.Instance,
				TWEEN_FAST,
				{ BackgroundTransparency = 0, BackgroundColor3 = Color3.fromRGB(26, 26, 26) }
			):Play()
		end)
	)

	table.insert(
		self._connections,
		self._header.MouseLeave:Connect(function()
			if not self._expanded then
				TweenService:Create(
					self.Instance,
					TWEEN_FAST,
					{ BackgroundTransparency = 1, BackgroundColor3 = Color3.fromRGB(20, 20, 20) }
				):Play()
			end
		end)
	)

	-- Picker logic
	self:_setupPickerLogic()
	self:_updateVisuals()

	return self
end

function ColorPicker:_setupPickerLogic()
	table.insert(
		self._connections,
		self._svPicker.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				self._dragging = "sv"
				self:_updateSV(input)
			end
		end)
	)

	table.insert(
		self._connections,
		self._huePicker.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				self._dragging = "hue"
				self:_updateHue(input)
			end
		end)
	)

	table.insert(
		self._connections,
		UserInputService.InputChanged:Connect(function(input)
			if self._dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
				if self._dragging == "sv" then
					self:_updateSV(input)
				else
					self:_updateHue(input)
				end
			end
		end)
	)

	table.insert(
		self._connections,
		UserInputService.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				self._dragging = nil
			end
		end)
	)
end

function ColorPicker:_updateSV(input)
	local pos = self._svPicker.AbsolutePosition
	local size = self._svPicker.AbsoluteSize
	self._s = math.clamp((input.Position.X - pos.X) / size.X, 0, 1)
	self._v = 1 - math.clamp((input.Position.Y - pos.Y) / size.Y, 0, 1)
	self:_applyColor()
end

function ColorPicker:_updateHue(input)
	local pos = self._huePicker.AbsolutePosition
	local size = self._huePicker.AbsoluteSize
	self._h = math.clamp((input.Position.Y - pos.Y) / size.Y, 0, 1) * 360
	self._svPicker.BackgroundColor3 = hsvToRgb(self._h, 1, 1)
	self:_applyColor()
end

function ColorPicker:_applyColor()
	self._value = hsvToRgb(self._h, self._s, self._v)
	self._preview.BackgroundColor3 = self._value
	self._svCursor.Position = UDim2.new(self._s, 0, 1 - self._v, 0)
	self._hueCursor.Position = UDim2.new(0.5, 0, self._h / 360, 0)

	self.OnChanged:Fire(self._value)
	if self._callback then
		self._callback(self._value)
	end
end

function ColorPicker:_updateVisuals()
	self._svCursor.Position = UDim2.new(self._s, 0, 1 - self._v, 0)
	self._hueCursor.Position = UDim2.new(0.5, 0, self._h / 360, 0)
	self._svPicker.BackgroundColor3 = hsvToRgb(self._h, 1, 1)
end

function ColorPicker:Toggle()
	self._expanded = not self._expanded
	self._content.Visible = self._expanded

	if self._expanded then
		TweenService:Create(
			self.Instance,
			TWEEN_FAST,
			{ BackgroundTransparency = 0, BackgroundColor3 = Color3.fromRGB(26, 26, 26) }
		):Play()
	else
		TweenService:Create(
			self.Instance,
			TWEEN_FAST,
			{ BackgroundTransparency = 1, BackgroundColor3 = Color3.fromRGB(20, 20, 20) }
		):Play()
	end
end

function ColorPicker:GetValue(): Color3
	return self._value
end

function ColorPicker:SetValue(color: Color3)
	self._value = color
	self._h, self._s, self._v = rgbToHsv(color)
	self._preview.BackgroundColor3 = color
	self:_updateVisuals()
	self.OnChanged:Fire(self._value)
	return self
end

function ColorPicker:SetTitle(title: string)
	self._title.Text = title
	return self
end

function ColorPicker:Destroy()
	self.OnChanged:Destroy()
	Component.Destroy(self)
end

return ColorPicker
