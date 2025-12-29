--[[
    Tzar UI Library - Paragraph Component
    Clickable element with title and description
]]

local TweenService = game:GetService("TweenService")

local Utils = require("../../Core/Utils")
local Signal = require("../../Core/Signal")
local Component = require("../Base/Component")

local Paragraph = setmetatable({}, Component)
Paragraph.__index = Paragraph

-- Tween presets
local TWEEN_FAST = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

function Paragraph.new(options)
	local self = Component.new(options)
	setmetatable(self, Paragraph)

	-- Main button container
	self.Instance = Utils.create("TextButton", {
		Name = "Paragraph",
		Text = "",
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = Color3.fromRGB(20, 20, 20),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 0),
		AutoButtonColor = false,
		LayoutOrder = options.LayoutOrder or 0,
	})

	Utils.applyCorner(self.Instance, 12)
	Utils.applyListLayout(self.Instance, { Padding = 4 })
	Utils.applyPadding(self.Instance, 8, 12, 8, 12)

	-- Title
	self._title = Utils.create("TextLabel", {
		Name = "Title",
		Text = options.Title or "Title",
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
		Parent = self.Instance,
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
			Parent = self.Instance,
		})
	end

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

	-- Hover animations
	table.insert(
		self._connections,
		self.Instance.MouseEnter:Connect(function()
			TweenService:Create(self.Instance, TWEEN_FAST, {
				BackgroundTransparency = 0,
			}):Play()
		end)
	)

	table.insert(
		self._connections,
		self.Instance.MouseLeave:Connect(function()
			TweenService:Create(self.Instance, TWEEN_FAST, {
				BackgroundTransparency = 1,
			}):Play()
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
			TweenService:Create(self.Instance, TWEEN_FAST, {
				BackgroundColor3 = Color3.fromRGB(26, 26, 26),
				BackgroundTransparency = 0,
			}):Play()
		end)
	)

	return self
end

-- Set title
function Paragraph:SetTitle(title: string)
	self._title.Text = title
	return self
end

-- Set description
function Paragraph:SetDescription(description: string)
	if self._description then
		self._description.Text = description
	end
	return self
end

-- Get title
function Paragraph:GetTitle(): string
	return self._title.Text
end

function Paragraph:Destroy()
	self.OnClick:Destroy()
	Component.Destroy(self)
end

return Paragraph
