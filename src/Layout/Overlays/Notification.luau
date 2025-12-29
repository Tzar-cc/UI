--[[
    Tzar UI Library - Notification Component
    Sonner/Shadcn-style toast notifications
]]

local TweenService = game:GetService("TweenService")

local Utils = require("../../Core/Utils")

local Notification = {}
Notification.__index = Notification

-- Tween presets
local TWEEN_SLIDE = TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local TWEEN_FADE = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

-- Dimensions - Sonner style (wider, shorter)
local NOTIFICATION_WIDTH = 356
local NOTIFICATION_HEIGHT = 64

function Notification.new(options)
	local self = setmetatable({}, Notification)

	local duration = options.Duration or 5

	-- Main container - Sonner dark style
	self.Instance = Utils.create("Frame", {
		Name = "Notification",
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, NOTIFICATION_WIDTH + 20, 0, 0),
		Size = UDim2.new(0, NOTIFICATION_WIDTH, 0, NOTIFICATION_HEIGHT),
		BackgroundColor3 = Color3.fromRGB(24, 24, 24),
		BorderSizePixel = 0,
		ClipsDescendants = true,
	})
	Utils.applyCorner(self.Instance, 10)
	Utils.applyStroke(self.Instance, { Color = Color3.fromRGB(45, 45, 45), Thickness = 1 })

	-- Content container with padding
	local content = Utils.create("Frame", {
		Name = "Content",
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		Parent = self.Instance,
	})
	Utils.applyPadding(content, 14, 16, 14, 16)

	-- Text container (left side)
	local textContainer = Utils.create("Frame", {
		Name = "Text",
		Size = UDim2.new(1, -80, 1, 0),
		BackgroundTransparency = 1,
		Parent = content,
	})
	Utils.applyListLayout(textContainer, { Padding = 2, VerticalAlignment = Enum.VerticalAlignment.Center })

	-- Title - Bold, clean
	Utils.create("TextLabel", {
		Name = "Title",
		Text = options.Title or "Notification",
		Font = Enum.Font.GothamMedium,
		TextSize = 14,
		TextColor3 = Color3.fromRGB(250, 250, 250),
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 18),
		LayoutOrder = 1,
		Parent = textContainer,
	})

	-- Description/Message
	if options.Message or options.Description then
		Utils.create("TextLabel", {
			Name = "Description",
			Text = options.Message or options.Description or "",
			Font = Enum.Font.Gotham,
			TextSize = 13,
			TextColor3 = Color3.fromRGB(160, 160, 160),
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 16),
			LayoutOrder = 2,
			Parent = textContainer,
		})
	end

	-- Action button container (right side) - Sonner "Undo" style
	local actionContainer = Utils.create("Frame", {
		Name = "Actions",
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, 0, 0.5, 0),
		Size = UDim2.new(0, 60, 1, 0),
		BackgroundTransparency = 1,
		Parent = content,
	})

	-- Action button if callback provided
	if options.Action and options.ActionCallback then
		local actionBtn = Utils.create("TextButton", {
			Name = "ActionButton",
			Text = options.Action,
			Font = Enum.Font.GothamMedium,
			TextSize = 13,
			TextColor3 = Color3.fromRGB(30, 30, 30),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			Size = UDim2.new(0, 56, 0, 32),
			BackgroundColor3 = Color3.fromRGB(250, 250, 250),
			AutoButtonColor = false,
			Parent = actionContainer,
		})
		Utils.applyCorner(actionBtn, 6)

		-- Hover effect
		actionBtn.MouseEnter:Connect(function()
			TweenService:Create(actionBtn, TWEEN_FADE, {
				BackgroundColor3 = Color3.fromRGB(230, 230, 230),
			}):Play()
		end)

		actionBtn.MouseLeave:Connect(function()
			TweenService:Create(actionBtn, TWEEN_FADE, {
				BackgroundColor3 = Color3.fromRGB(250, 250, 250),
			}):Play()
		end)

		actionBtn.MouseButton1Click:Connect(function()
			if options.ActionCallback then
				options.ActionCallback()
			end
			self:Dismiss()
		end)
	else
		-- Dismiss button (X) if no action
		local closeBtn = Utils.create("TextButton", {
			Name = "Close",
			Text = "",
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			Size = UDim2.new(0, 28, 0, 28),
			BackgroundColor3 = Color3.fromRGB(40, 40, 40),
			BackgroundTransparency = 1,
			AutoButtonColor = false,
			Parent = actionContainer,
		})
		Utils.applyCorner(closeBtn, 6)

		Utils.create("ImageLabel", {
			Name = "Icon",
			Image = "rbxassetid://6031094670",
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			Size = UDim2.new(0, 14, 0, 14),
			ImageColor3 = Color3.fromRGB(120, 120, 120),
			BackgroundTransparency = 1,
			Parent = closeBtn,
		})

		closeBtn.MouseEnter:Connect(function()
			TweenService:Create(closeBtn, TWEEN_FADE, { BackgroundTransparency = 0 }):Play()
			TweenService:Create(closeBtn.Icon, TWEEN_FADE, { ImageColor3 = Color3.fromRGB(200, 200, 200) }):Play()
		end)

		closeBtn.MouseLeave:Connect(function()
			TweenService:Create(closeBtn, TWEEN_FADE, { BackgroundTransparency = 1 }):Play()
			TweenService:Create(closeBtn.Icon, TWEEN_FADE, { ImageColor3 = Color3.fromRGB(120, 120, 120) }):Play()
		end)

		closeBtn.MouseButton1Click:Connect(function()
			self:Dismiss()
		end)
	end

	-- Auto-dismiss timer
	self._dismissed = false
	if duration > 0 then
		task.delay(duration, function()
			if not self._dismissed then
				self:Dismiss()
			end
		end)
	end

	return self
end

function Notification:Show(targetY: number)
	self.Instance.Position = UDim2.new(1, NOTIFICATION_WIDTH + 20, 0, targetY)

	TweenService:Create(self.Instance, TWEEN_SLIDE, {
		Position = UDim2.new(1, -10, 0, targetY),
	}):Play()
end

function Notification:UpdatePosition(targetY: number)
	TweenService:Create(self.Instance, TWEEN_SLIDE, {
		Position = UDim2.new(1, -10, 0, targetY),
	}):Play()
end

function Notification:Dismiss()
	if self._dismissed then
		return
	end
	self._dismissed = true

	local tween = TweenService:Create(self.Instance, TWEEN_SLIDE, {
		Position = UDim2.new(1, NOTIFICATION_WIDTH + 20, 0, self.Instance.Position.Y.Offset),
	})
	tween:Play()
	tween.Completed:Wait()

	self.Instance:Destroy()
end

function Notification:IsDismissed(): boolean
	return self._dismissed
end

return Notification
