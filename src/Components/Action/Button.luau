--[[
    Tzar UI Library - Button Component
    Button with variants: Primary, Secondary, Outline, Distract
]]

local TweenService = game:GetService("TweenService")

local Utils = require("../../Core/Utils")
local Signal = require("../../Core/Signal")
local Component = require("../Base/Component")

local Button = setmetatable({}, Component)
Button.__index = Button

-- Tween presets
local TWEEN_FAST = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

-- Variant colors
local VARIANTS = {
	Primary = {
		Background = Color3.fromRGB(9, 156, 75),
		BackgroundHover = Color3.fromRGB(11, 180, 87),
		BackgroundPress = Color3.fromRGB(7, 130, 62),
		Text = Color3.fromRGB(255, 255, 255),
	},
	Secondary = {
		Background = Color3.fromRGB(22, 22, 22),
		BackgroundHover = Color3.fromRGB(30, 30, 30),
		BackgroundPress = Color3.fromRGB(18, 18, 18),
		Text = Color3.fromRGB(212, 212, 212),
	},
	Distract = {
		Background = Color3.fromRGB(227, 29, 29),
		BackgroundHover = Color3.fromRGB(245, 50, 50),
		BackgroundPress = Color3.fromRGB(190, 25, 25),
		Text = Color3.fromRGB(255, 255, 255),
	},
	Outline = {
		Background = Color3.fromRGB(22, 22, 22),
		BackgroundHover = Color3.fromRGB(30, 30, 30),
		BackgroundPress = Color3.fromRGB(18, 18, 18),
		Text = Color3.fromRGB(212, 212, 212),
		Stroke = Color3.fromRGB(40, 40, 40),
	},
}

function Button.new(options)
	local self = Component.new(options)
	setmetatable(self, Button)

	local variant = options.Variant or "Secondary"
	local colors = VARIANTS[variant] or VARIANTS.Secondary

	-- Main button
	self.Instance = Utils.create("TextButton", {
		Name = "Button",
		Text = "",
		AutomaticSize = Enum.AutomaticSize.XY,
		BackgroundColor3 = colors.Background,
		BackgroundTransparency = 0.05,
		BorderSizePixel = 0,
		Size = UDim2.new(0, 0, 0, 30),
		AutoButtonColor = false,
		LayoutOrder = options.LayoutOrder or 0,
	})

	Utils.applyCorner(self.Instance, 18)
	Utils.applyPadding(self.Instance, 8, 12, 8, 12)
	Utils.applyListLayout(self.Instance, {
		Padding = 6,
		Direction = Enum.FillDirection.Horizontal,
		VerticalAlignment = Enum.VerticalAlignment.Center,
	})

	-- Add stroke for Outline variant
	if colors.Stroke then
		Utils.applyStroke(self.Instance, {
			Color = colors.Stroke,
			Thickness = 1,
			Mode = Enum.ApplyStrokeMode.Border,
		})
	end

	-- Name label
	self._nameLabel = Utils.create("TextLabel", {
		Name = "Name",
		Text = options.Name or "Button",
		Font = Enum.Font.Gotham,
		TextSize = 14,
		TextColor3 = colors.Text,
		TextXAlignment = Enum.TextXAlignment.Left,
		AutomaticSize = Enum.AutomaticSize.XY,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(0, 0, 0, 14),
		Parent = self.Instance,
	})

	-- Signal
	self.OnClick = Signal.new()

	-- Click handler
	table.insert(
		self._connections,
		self.Instance.MouseButton1Click:Connect(function()
			self.OnClick:Fire()
			if options.Callback then
				options.Callback()
			end
		end)
	)

	-- Hover animation
	table.insert(
		self._connections,
		self.Instance.MouseEnter:Connect(function()
			TweenService:Create(self.Instance, TWEEN_FAST, {
				BackgroundColor3 = colors.BackgroundHover,
				BackgroundTransparency = 0,
			}):Play()
		end)
	)

	table.insert(
		self._connections,
		self.Instance.MouseLeave:Connect(function()
			TweenService:Create(self.Instance, TWEEN_FAST, {
				BackgroundColor3 = colors.Background,
				BackgroundTransparency = 0.05,
			}):Play()
		end)
	)

	-- Press animation
	table.insert(
		self._connections,
		self.Instance.MouseButton1Down:Connect(function()
			TweenService:Create(self.Instance, TWEEN_FAST, {
				BackgroundColor3 = colors.BackgroundPress,
			}):Play()
		end)
	)

	table.insert(
		self._connections,
		self.Instance.MouseButton1Up:Connect(function()
			TweenService:Create(self.Instance, TWEEN_FAST, {
				BackgroundColor3 = colors.BackgroundHover,
			}):Play()
		end)
	)

	return self
end

-- Set button text
function Button:SetName(name: string)
	self._nameLabel.Text = name
	return self
end

function Button:Destroy()
	self.OnClick:Destroy()
	Component.Destroy(self)
end

return Button
