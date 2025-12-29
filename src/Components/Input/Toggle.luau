--[[
    Tzar UI Library - Toggle Component
    Element with title, description, and switch on top right
]]

local TweenService = game:GetService("TweenService")

local Utils = require("../../Core/Utils")
local Signal = require("../../Core/Signal")
local Component = require("../Base/Component")

local Toggle = setmetatable({}, Component)
Toggle.__index = Toggle

-- Tween presets
local TWEEN_FAST = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

-- Switch dimensions
local SWITCH_WIDTH = 28
local SWITCH_HEIGHT = 14
local SWITCH_KNOB_SIZE = 10
local SWITCH_PADDING = 2

function Toggle.new(options)
	local self = Component.new(options)
	setmetatable(self, Toggle)

	self._value = options.Default or false

	-- Main container
	self.Instance = Utils.create("TextButton", {
		Name = "Toggle",
		Text = "",
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = Color3.fromRGB(20, 20, 20),
		BorderSizePixel = 0,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 0),
		AutoButtonColor = false,
		LayoutOrder = options.LayoutOrder or 0,
	})

	Utils.applyCorner(self.Instance, 12)
	Utils.applyPadding(self.Instance, 8, 12, 8, 12)

	-- Content container
	local contentContainer = Utils.create("Frame", {
		Name = "Content",
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, -(SWITCH_WIDTH + 12), 0, 0),
		Parent = self.Instance,
	})

	Utils.applyListLayout(contentContainer, { Padding = 4 })

	-- Title
	self._title = Utils.create("TextLabel", {
		Name = "Title",
		Text = options.Title or "Toggle",
		Font = Enum.Font.Gotham,
		TextSize = 14,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 14),
		Parent = contentContainer,
	})

	-- Description (optional)
	if options.Description then
		self._description = Utils.create("TextLabel", {
			Name = "Description",
			Text = options.Description,
			Font = Enum.Font.Gotham,
			TextSize = 12,
			TextColor3 = Color3.fromRGB(215, 215, 215),
			TextWrapped = true,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Top,
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 12),
			LayoutOrder = 1,
			Parent = contentContainer,
		})
	end

	local switchHold = Utils.create("Folder", {
		Name = "SwitchHold",
		Parent = self.Instance,
	})

	-- Switch container
	self._switch = Utils.create("Frame", {
		Name = "Switch",
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, 0, 0, 0),
		Size = UDim2.new(0, SWITCH_WIDTH, 0, SWITCH_HEIGHT),
		BackgroundColor3 = Color3.fromRGB(40, 40, 40),
		BorderSizePixel = 0,
		Parent = switchHold,
	})

	Utils.applyCorner(self._switch, SWITCH_HEIGHT / 2)

	-- Switch knob
	self._knob = Utils.create("Frame", {
		Name = "Knob",
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, SWITCH_PADDING, 0.5, 0),
		Size = UDim2.new(0, SWITCH_KNOB_SIZE, 0, SWITCH_KNOB_SIZE),
		BackgroundColor3 = Color3.fromRGB(180, 180, 180),
		BorderSizePixel = 0,
		Parent = self._switch,
	})

	Utils.applyCorner(self._knob, SWITCH_KNOB_SIZE / 2)

	-- Signal
	self.OnToggle = Signal.new()
	self.Changed = self.OnToggle -- Alias for Config system

	-- Click handler
	table.insert(
		self._connections,
		self.Instance.MouseButton1Click:Connect(function()
			self:Toggle()
		end)
	)

	-- Hover animations
	table.insert(
		self._connections,
		self.Instance.MouseEnter:Connect(function()
			if not self._value then
				TweenService:Create(self.Instance, TWEEN_FAST, {
					BackgroundTransparency = 0,
					BackgroundColor3 = Color3.fromRGB(26, 26, 26),
				}):Play()
			end
		end)
	)

	table.insert(
		self._connections,
		self.Instance.MouseLeave:Connect(function()
			if not self._value then
				TweenService:Create(self.Instance, TWEEN_FAST, {
					BackgroundTransparency = 1,
					BackgroundColor3 = Color3.fromRGB(20, 20, 20),
				}):Play()
			end
		end)
	)

	-- Press animation
	table.insert(
		self._connections,
		self.Instance.MouseButton1Down:Connect(function()
			TweenService:Create(self.Instance, TWEEN_FAST, {
				BackgroundColor3 = Color3.fromRGB(16, 16, 16),
				BackgroundTransparency = 0,
			}):Play()
		end)
	)

	table.insert(
		self._connections,
		self.Instance.MouseButton1Up:Connect(function()
			local targetColor = self._value and Color3.fromRGB(20, 20, 20) or Color3.fromRGB(26, 26, 26)
			TweenService:Create(self.Instance, TWEEN_FAST, {
				BackgroundColor3 = targetColor,
				BackgroundTransparency = 0,
			}):Play()
		end)
	)

	-- Set initial state
	if self._value then
		self:_updateVisual(false)
	end

	return self
end

-- Update switch visual
function Toggle:_updateVisual(animate: boolean)
	local knobX = self._value and (SWITCH_WIDTH - SWITCH_KNOB_SIZE - SWITCH_PADDING) or SWITCH_PADDING
	local switchColor = self._value and Color3.fromRGB(9, 156, 75) or Color3.fromRGB(40, 40, 40)
	local knobColor = self._value and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(180, 180, 180)

	if animate then
		TweenService:Create(self._knob, TWEEN_FAST, {
			Position = UDim2.new(0, knobX, 0.5, 0),
			BackgroundColor3 = knobColor,
		}):Play()
		TweenService:Create(self._switch, TWEEN_FAST, {
			BackgroundColor3 = switchColor,
		}):Play()
		if self._value then
			TweenService:Create(self.Instance, TWEEN_FAST, {
				BackgroundTransparency = 0,
				BackgroundColor3 = Color3.fromRGB(20, 20, 20),
			}):Play()
		else
			TweenService:Create(self.Instance, TWEEN_FAST, {
				BackgroundTransparency = 0,
				BackgroundColor3 = Color3.fromRGB(26, 26, 26),
			}):Play()
		end
	else
		self._knob.Position = UDim2.new(0, knobX, 0.5, 0)
		self._knob.BackgroundColor3 = knobColor
		self._switch.BackgroundColor3 = switchColor

		if self._value then
			self.Instance.BackgroundTransparency = 0
			self.Instance.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
		else
			self.Instance.BackgroundTransparency = 1
		end
	end
end

-- Toggle the value
function Toggle:Toggle()
	self._value = not self._value
	self:_updateVisual(true)
	self.OnToggle:Fire(self._value)
end

-- Set value
function Toggle:SetValue(value: boolean)
	if self._value ~= value then
		self._value = value
		self:_updateVisual(true)
		self.OnToggle:Fire(self._value)
	end
	return self
end

-- Get value
function Toggle:GetValue(): boolean
	return self._value
end

-- Set title
function Toggle:SetTitle(title: string)
	self._title.Text = title
	return self
end

-- Set description
function Toggle:SetDescription(description: string)
	if self._description then
		self._description.Text = description
	end
	return self
end

function Toggle:Destroy()
	self.OnToggle:Destroy()
	Component.Destroy(self)
end

return Toggle
