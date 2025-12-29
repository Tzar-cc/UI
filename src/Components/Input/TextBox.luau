--[[
    Tzar UI Library - TextBox Component
    Text input with title and description
]]

local TweenService = game:GetService("TweenService")

local Utils = require("../../Core/Utils")
local Signal = require("../../Core/Signal")
local Component = require("../Base/Component")

local TextBox = setmetatable({}, Component)
TextBox.__index = TextBox

-- Tween presets
local TWEEN_FAST = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

-- Input dimensions
local INPUT_WIDTH = 120
local INPUT_HEIGHT = 28

function TextBox.new(options)
	local self = Component.new(options)
	setmetatable(self, TextBox)

	self._value = options.Default or ""
	self._placeholder = options.Placeholder or "Enter text..."
	self._clearOnFocus = options.ClearOnFocus or false
	self._callback = options.Callback

	-- Main container
	self.Instance = Utils.create("TextButton", {
		Name = "TextBox",
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
	Utils.applyPadding(self.Instance, 8, 12, 8, 12)

	-- Content container
	local contentContainer = Utils.create("Frame", {
		Name = "Content",
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, -(INPUT_WIDTH + 12), 0, 0),
		Parent = self.Instance,
	})

	Utils.applyListLayout(contentContainer, { Padding = 4 })

	-- Title
	self._title = Utils.create("TextLabel", {
		Name = "Title",
		Text = options.Title or "TextBox",
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

	local inputHolder = Utils.create("Folder", { Name = "InputHolder", Parent = self.Instance })

	-- Input container
	self._inputContainer = Utils.create("Frame", {
		Name = "InputContainer",
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, 0, 0, 0),
		Size = UDim2.new(0, INPUT_WIDTH, 0, INPUT_HEIGHT),
		BackgroundColor3 = Color3.fromRGB(30, 30, 30),
		BorderSizePixel = 0,
		Parent = inputHolder,
	})
	Utils.applyCorner(self._inputContainer, 6)

	-- Actual TextBox
	self._input = Utils.create("TextBox", {
		Name = "Input",
		Text = self._value,
		PlaceholderText = self._placeholder,
		Font = Enum.Font.Gotham,
		TextSize = 13,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		PlaceholderColor3 = Color3.fromRGB(100, 100, 100),
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		ClearTextOnFocus = self._clearOnFocus,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, 0),
		Parent = self._inputContainer,
	})
	Utils.applyPadding(self._input, 0, 8, 0, 8)

	-- Signal
	self.OnChanged = Signal.new()
	self.Changed = self.OnChanged -- Alias for Config system

	-- Focus states
	table.insert(
		self._connections,
		self._input.Focused:Connect(function()
			TweenService:Create(self._inputContainer, TWEEN_FAST, { BackgroundColor3 = Color3.fromRGB(40, 40, 40) })
				:Play()
			TweenService:Create(
				self.Instance,
				TWEEN_FAST,
				{ BackgroundTransparency = 0, BackgroundColor3 = Color3.fromRGB(26, 26, 26) }
			):Play()
		end)
	)

	table.insert(
		self._connections,
		self._input.FocusLost:Connect(function(_)
			TweenService:Create(self._inputContainer, TWEEN_FAST, { BackgroundColor3 = Color3.fromRGB(30, 30, 30) })
				:Play()
			TweenService:Create(
				self.Instance,
				TWEEN_FAST,
				{ BackgroundTransparency = 1, BackgroundColor3 = Color3.fromRGB(20, 20, 20) }
			):Play()

			local newValue = self._input.Text
			if newValue ~= self._value then
				self._value = newValue
				self.OnChanged:Fire(self._value)
				if self._callback then
					self._callback(self._value)
				end
			end
		end)
	)

	-- Hover effects
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
			if not self._input:IsFocused() then
				TweenService:Create(
					self.Instance,
					TWEEN_FAST,
					{ BackgroundTransparency = 1, BackgroundColor3 = Color3.fromRGB(20, 20, 20) }
				):Play()
			end
		end)
	)

	-- Click to focus
	table.insert(
		self._connections,
		self.Instance.MouseButton1Click:Connect(function()
			self._input:CaptureFocus()
		end)
	)

	return self
end

function TextBox:GetValue(): string
	return self._value
end

function TextBox:SetValue(val: string)
	self._value = val
	self._input.Text = val
	self.OnChanged:Fire(self._value)
	return self
end

function TextBox:SetTitle(title: string)
	self._title.Text = title
	return self
end

function TextBox:SetDescription(description: string)
	if self._description then
		self._description.Text = description
	end
	return self
end

function TextBox:Destroy()
	self.OnChanged:Destroy()
	Component.Destroy(self)
end

return TextBox
