--[[
    Tzar UI Library - Keybind Component
    Element with title, description, and key binding button
]]

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Utils = require("../../Core/Utils")
local Signal = require("../../Core/Signal")
local Component = require("../Base/Component")

local Keybind = setmetatable({}, Component)
Keybind.__index = Keybind

-- Tween presets
local TWEEN_FAST = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

-- Keybind button dimensions
local BUTTON_HEIGHT = 24
local BUTTON_MIN_WIDTH = 50

-- Blacklisted keys
local BLACKLIST = {
	[Enum.KeyCode.Unknown] = true,
	[Enum.KeyCode.Escape] = true,
	[Enum.KeyCode.Return] = true,
	[Enum.KeyCode.Backspace] = true,
}

local function formatKeyName(keyCode: Enum.KeyCode): string
	local name = keyCode.Name
	name = name:gsub("^Left", "L"):gsub("^Right", "R"):gsub("Control", "Ctrl")
	return name
end

function Keybind.new(options)
	local self = Component.new(options)
	setmetatable(self, Keybind)

	self._key = options.Default or Enum.KeyCode.Unknown
	self._listening = false
	self._callback = options.Callback
	self._inputConnection = nil

	-- Main container
	self.Instance = Utils.create("TextButton", {
		Name = "Keybind",
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
		Size = UDim2.new(1, -(BUTTON_MIN_WIDTH + 20), 0, 0),
		Parent = self.Instance,
	})

	Utils.applyListLayout(contentContainer, { Padding = 4 })

	-- Title
	self._title = Utils.create("TextLabel", {
		Name = "Title",
		Text = options.Title or "Keybind",
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
			TextColor3 = Color3.fromRGB(140, 140, 140),
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

	local buttonHolder = Utils.create("Folder", { Name = "ButtonHolder", Parent = self.Instance })

	-- Keybind button
	self._button = Utils.create("TextButton", {
		Name = "KeyButton",
		Text = self._key == Enum.KeyCode.Unknown and "None" or formatKeyName(self._key),
		Font = Enum.Font.GothamMedium,
		TextSize = 12,
		TextColor3 = Color3.fromRGB(200, 200, 200),
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.X,
		Size = UDim2.new(0, BUTTON_MIN_WIDTH, 0, BUTTON_HEIGHT),
		BackgroundColor3 = Color3.fromRGB(30, 30, 30),
		BorderSizePixel = 0,
		AutoButtonColor = false,
		Parent = buttonHolder,
	})

	Utils.applyCorner(self._button, 6)
	Utils.applyPadding(self._button, 0, 10, 0, 10)

	-- Signal
	self.OnChanged = Signal.new()
	self.Changed = self.OnChanged -- Alias for Config system

	-- Click handlers
	table.insert(
		self._connections,
		self._button.MouseButton1Click:Connect(function()
			self:_startListening()
		end)
	)

	table.insert(
		self._connections,
		self.Instance.MouseButton1Click:Connect(function()
			self:_startListening()
		end)
	)

	-- Hover animations
	table.insert(
		self._connections,
		self.Instance.MouseEnter:Connect(function()
			TweenService:Create(
				self.Instance,
				TWEEN_FAST,
				{ BackgroundTransparency = 0, BackgroundColor3 = Color3.fromRGB(26, 26, 26) }
			):Play()
		end)
	)

	table.insert(
		self._connections,
		self.Instance.MouseLeave:Connect(function()
			if not self._listening then
				TweenService:Create(
					self.Instance,
					TWEEN_FAST,
					{ BackgroundTransparency = 1, BackgroundColor3 = Color3.fromRGB(20, 20, 20) }
				):Play()
			end
		end)
	)

	table.insert(
		self._connections,
		self._button.MouseEnter:Connect(function()
			if not self._listening then
				TweenService:Create(self._button, TWEEN_FAST, { BackgroundColor3 = Color3.fromRGB(40, 40, 40) }):Play()
			end
		end)
	)

	table.insert(
		self._connections,
		self._button.MouseLeave:Connect(function()
			if not self._listening then
				TweenService:Create(self._button, TWEEN_FAST, { BackgroundColor3 = Color3.fromRGB(30, 30, 30) }):Play()
			end
		end)
	)

	return self
end

function Keybind:_startListening()
	if self._listening then
		return
	end

	self._listening = true
	self._button.Text = "..."

	TweenService:Create(
		self._button,
		TWEEN_FAST,
		{ BackgroundColor3 = Color3.fromRGB(9, 156, 75), TextColor3 = Color3.fromRGB(255, 255, 255) }
	):Play()
	TweenService
		:Create(
			self.Instance,
			TWEEN_FAST,
			{ BackgroundTransparency = 0, BackgroundColor3 = Color3.fromRGB(26, 26, 26) }
		)
		:Play()

	self._inputConnection = UserInputService.InputBegan:Connect(function(input, _)
		if input.UserInputType == Enum.UserInputType.Keyboard then
			local keyCode = input.KeyCode

			if keyCode == Enum.KeyCode.Escape then
				self:_stopListening(false)
				return
			end

			if keyCode == Enum.KeyCode.Backspace then
				self._key = Enum.KeyCode.Unknown
				self:_stopListening(true)
				return
			end

			if BLACKLIST[keyCode] then
				return
			end

			self._key = keyCode
			self:_stopListening(true)
		elseif
			input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.MouseButton2
		then
			task.delay(0.1, function()
				if self._listening then
					self:_stopListening(false)
				end
			end)
		end
	end)
end

function Keybind:_stopListening(changed: boolean)
	self._listening = false

	if self._inputConnection then
		self._inputConnection:Disconnect()
		self._inputConnection = nil
	end

	self._button.Text = self._key == Enum.KeyCode.Unknown and "None" or formatKeyName(self._key)

	TweenService:Create(
		self._button,
		TWEEN_FAST,
		{ BackgroundColor3 = Color3.fromRGB(30, 30, 30), TextColor3 = Color3.fromRGB(200, 200, 200) }
	):Play()
	TweenService
		:Create(
			self.Instance,
			TWEEN_FAST,
			{ BackgroundTransparency = 1, BackgroundColor3 = Color3.fromRGB(20, 20, 20) }
		)
		:Play()

	if changed then
		self.OnChanged:Fire(self._key)
		if self._callback then
			self._callback(self._key)
		end
	end
end

function Keybind:GetKey(): Enum.KeyCode
	return self._key
end

function Keybind:SetKey(key: Enum.KeyCode)
	self._key = key
	self._button.Text = key == Enum.KeyCode.Unknown and "None" or formatKeyName(key)
	self.OnChanged:Fire(self._key)
	return self
end

-- Aliases for Config system
function Keybind:GetValue()
	return self._key
end

function Keybind:SetValue(key)
	return self:SetKey(key)
end

function Keybind:SetTitle(title: string)
	self._title.Text = title
	return self
end

function Keybind:SetDescription(description: string)
	if self._description then
		self._description.Text = description
	end
	return self
end

function Keybind:IsPressed(): boolean
	if self._key == Enum.KeyCode.Unknown then
		return false
	end
	return UserInputService:IsKeyDown(self._key)
end

function Keybind:Destroy()
	if self._inputConnection then
		self._inputConnection:Disconnect()
	end
	self.OnChanged:Destroy()
	Component.Destroy(self)
end

return Keybind
