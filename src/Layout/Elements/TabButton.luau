--[[
    Tzar UI Library - TabButton Component
    Tab navigation button with icon and name
]]

local TweenService = game:GetService("TweenService")

local Utils = require("../../Core/Utils")
local Signal = require("../../Core/Signal")
local Assets = require("../../Core/Assets")
local Cleanup = require("../../Core/Cleanup")

local TabButton = {}
TabButton.__index = TabButton

-- Colors
local COLOR_ENABLED = Color3.fromRGB(30, 30, 30) -- Active tab
local COLOR_HOVER = Color3.fromRGB(26, 26, 26) -- Hover when not active
local COLOR_DEFAULT = Color3.fromRGB(22, 22, 22) -- Default/inactive

local TWEEN_FAST = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

-- Helper to resolve icon (name or rbxassetid)
local function resolveIcon(icon)
	if not icon or icon == "" then
		return ""
	end
	-- If it's already an asset ID, return as-is
	if string.match(icon, "^rbxassetid://") then
		return icon
	end
	-- Otherwise, resolve via Icons library
	return Assets.GetIcon(icon)
end

function TabButton.new(options)
	local self = setmetatable({}, TabButton)

	self._active = false
	self._iconName = options.Icon or ""
	self._cleanup = Cleanup.new()

	-- Main button
	self.Instance = Utils.create("TextButton", {
		Name = "TabBtn",
		Text = "",
		Font = Enum.Font.GothamMedium,
		TextSize = 14,
		TextColor3 = Color3.fromRGB(212, 212, 212),
		TextXAlignment = Enum.TextXAlignment.Left,
		BackgroundColor3 = COLOR_DEFAULT,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 36),
		AutoButtonColor = false,
		LayoutOrder = options.LayoutOrder or 0,
	})

	Utils.applyCorner(self.Instance)
	Utils.applyPadding(self.Instance, 8, 12, 8, 12)
	Utils.applyListLayout(self.Instance, {
		Padding = 6,
		Direction = Enum.FillDirection.Horizontal,
		VerticalAlignment = Enum.VerticalAlignment.Center,
	})

	-- Icon (resolve name to URL via Icons library)
	self._icon = Utils.create("ImageLabel", {
		Name = "Icon",
		Image = resolveIcon(options.Icon),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(0, 14, 0, 14),
		Parent = self.Instance,
	})

	-- Name label
	self._nameLabel = Utils.create("TextLabel", {
		Name = "Name",
		Text = options.Name or "Tab",
		Font = Enum.Font.GothamMedium,
		TextSize = 14,
		TextColor3 = Color3.fromRGB(212, 212, 212),
		TextXAlignment = Enum.TextXAlignment.Left,
		RichText = true,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(0, 0, 0, 14),
		Parent = self.Instance,
	})

	-- Signal
	self.OnClick = Signal.new()

	-- Click handler
	self._cleanup:Track(self.Instance.MouseButton1Click:Connect(function()
		self.OnClick:Fire()
	end))

	-- Hover animations (only when not active)
	self._cleanup:Track(self.Instance.MouseEnter:Connect(function()
		if not self._active then
			TweenService:Create(self.Instance, TWEEN_FAST, {
				BackgroundColor3 = COLOR_HOVER,
			}):Play()
		end
	end))

	self._cleanup:Track(self.Instance.MouseLeave:Connect(function()
		if not self._active then
			TweenService:Create(self.Instance, TWEEN_FAST, {
				BackgroundColor3 = COLOR_DEFAULT,
			}):Play()
		end
	end))

	return self
end

function TabButton:SetActive(active: boolean)
	self._active = active

	local targetColor = active and COLOR_ENABLED or COLOR_DEFAULT
	TweenService:Create(self.Instance, TWEEN_FAST, {
		BackgroundColor3 = targetColor,
	}):Play()

	return self
end

function TabButton:IsActive(): boolean
	return self._active
end

function TabButton:SetName(name: string)
	self._nameLabel.Text = name
	return self
end

function TabButton:SetIcon(iconOrId: string, offset: Vector2?, size: Vector2?)
	self._iconName = iconOrId
	-- Resolve icon name to URL if not already an asset ID
	if string.match(iconOrId, "^rbxassetid://") then
		self._icon.Image = iconOrId
	else
		self._icon.Image = Assets.GetIcon(iconOrId)
	end
	if offset then
		self._icon.ImageRectOffset = offset
	end
	if size then
		self._icon.ImageRectSize = size
	end
	return self
end

function TabButton:Destroy()
	self.OnClick:Destroy()
	self._cleanup:Cleanup()
	self.Instance:Destroy()
end

return TabButton
