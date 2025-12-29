--[[
    Tzar UI Library - Tooltip System
    Hover tooltips for UI elements
]]

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Utils = require("../../Core/Utils")

local Tooltip = {}
Tooltip._instance = nil
Tooltip._currentTarget = nil
Tooltip._showDelay = 0.5
Tooltip._hideDelay = nil

-- Tween presets
local TWEEN_FAST = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

-- Initialize tooltip UI (singleton)
function Tooltip:_init(screenGui)
	if self._instance then
		return
	end

	self._screenGui = screenGui

	self._instance = Utils.create("Frame", {
		Name = "Tooltip",
		AnchorPoint = Vector2.new(0, 0),
		AutomaticSize = Enum.AutomaticSize.XY,
		BackgroundColor3 = Color3.fromRGB(30, 30, 30),
		BorderSizePixel = 0,
		Visible = false,
		ZIndex = 1000,
		Parent = screenGui,
	})
	Utils.applyCorner(self._instance, 6)
	Utils.applyPadding(self._instance, 6, 10, 6, 10)
	Utils.applyStroke(self._instance, { Color = Color3.fromRGB(60, 60, 60), Thickness = 1 })

	self._label = Utils.create("TextLabel", {
		Name = "Text",
		Text = "",
		Font = Enum.Font.Gotham,
		TextSize = 12,
		TextColor3 = Color3.fromRGB(220, 220, 220),
		AutomaticSize = Enum.AutomaticSize.XY,
		BackgroundTransparency = 1,
		ZIndex = 1001,
		Parent = self._instance,
	})

	-- Track mouse movement
	UserInputService.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement and self._instance.Visible then
			self:_updatePosition(input.Position)
		end
	end)
end

function Tooltip:_updatePosition(mousePos)
	if not self._instance then
		return
	end

	local screenSize = self._screenGui.AbsoluteSize
	local tooltipSize = self._instance.AbsoluteSize

	local x = mousePos.X + 15
	local y = mousePos.Y + 15

	-- Keep on screen
	if x + tooltipSize.X > screenSize.X then
		x = mousePos.X - tooltipSize.X - 10
	end
	if y + tooltipSize.Y > screenSize.Y then
		y = mousePos.Y - tooltipSize.Y - 10
	end

	self._instance.Position = UDim2.new(0, x, 0, y)
end

-- Register tooltip for an element
function Tooltip:Register(element: GuiObject, text: string)
	if not self._instance then
		return
	end

	local showThread = nil

	element.MouseEnter:Connect(function()
		if showThread then
			task.cancel(showThread)
		end

		showThread = task.delay(self._showDelay, function()
			self._label.Text = text
			self._currentTarget = element
			self._instance.Visible = true
			self._instance.BackgroundTransparency = 1

			local mousePos = UserInputService:GetMouseLocation()
			self:_updatePosition(mousePos)

			TweenService:Create(self._instance, TWEEN_FAST, {
				BackgroundTransparency = 0,
			}):Play()
		end)
	end)

	element.MouseLeave:Connect(function()
		if showThread then
			task.cancel(showThread)
			showThread = nil
		end

		if self._currentTarget == element then
			TweenService:Create(self._instance, TWEEN_FAST, {
				BackgroundTransparency = 1,
			}):Play()

			task.delay(0.1, function()
				if self._currentTarget == element then
					self._instance.Visible = false
					self._currentTarget = nil
				end
			end)
		end
	end)
end

-- Update tooltip text for an element
function Tooltip:Update(element: GuiObject, text: string)
	if self._currentTarget == element then
		self._label.Text = text
	end
end

-- Hide current tooltip
function Tooltip:Hide()
	if self._instance then
		self._instance.Visible = false
		self._currentTarget = nil
	end
end

return Tooltip
