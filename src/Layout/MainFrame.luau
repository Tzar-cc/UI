--[[
    Tzar UI Library - MainFrame
    Main window based on trash/mainframe.lua
]]

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Utils = require("../Core/Utils")
local Signal = require("../Core/Signal")
local Config = require("../Core/Config")
local Cleanup = require("../Core/Cleanup")
local TabButton = require("./Elements/TabButton")
local Tooltip = require("./Overlays/Tooltip")
local Notification = require("./Overlays/Notification")
local Tab = require("./Tab")
local CommandMenu = require("./CommandMenu")

local MainFrame = {}
MainFrame.__index = MainFrame

-- Tween info presets
local TWEEN_FAST = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local TWEEN_NORMAL = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local TWEEN_SMOOTH = TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

-- Helper: animate button hover
local function setupButtonAnimations(
	button: TextButton,
	normalTransparency: number,
	hoverColor: Color3?,
	track: ((RBXScriptConnection) -> ())?
)
	local defaultBg = button.BackgroundColor3
	local hoverBg = hoverColor or defaultBg

	button.AutoButtonColor = false

	local function add(conn)
		if track then
			track(conn)
		end
	end

	add(button.MouseEnter:Connect(function()
		TweenService:Create(button, TWEEN_FAST, {
			BackgroundTransparency = 0,
			BackgroundColor3 = hoverBg,
		}):Play()
	end))

	add(button.MouseLeave:Connect(function()
		TweenService:Create(button, TWEEN_FAST, {
			BackgroundTransparency = normalTransparency,
			BackgroundColor3 = defaultBg,
		}):Play()
	end))

	add(button.MouseButton1Down:Connect(function()
		TweenService:Create(button, TWEEN_FAST, {
			BackgroundTransparency = 0,
			BackgroundColor3 = hoverBg:Lerp(Color3.new(0, 0, 0), 0.2),
		}):Play()
	end))

	add(button.MouseButton1Up:Connect(function()
		TweenService:Create(button, TWEEN_FAST, {
			BackgroundTransparency = 0,
			BackgroundColor3 = hoverBg,
		}):Play()
	end))
end

-- Helper: setup dragging
local function setupDragging(dragHandle: GuiObject, targetFrame: GuiObject, track: ((RBXScriptConnection) -> ())?)
	local dragging = false
	local dragStart = Vector2.zero
	local startPos = UDim2.new()

	local function add(conn)
		if track then
			track(conn)
		end
	end

	add(dragHandle.InputBegan:Connect(function(input)
		if
			input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch
		then
			dragging = true
			dragStart = Vector2.new(input.Position.X, input.Position.Y)
			startPos = targetFrame.Position
		end
	end))

	add(dragHandle.InputEnded:Connect(function(input)
		if
			input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch
		then
			dragging = false
		end
	end))

	add(UserInputService.InputChanged:Connect(function(input)
		if
			dragging
			and (
				input.UserInputType == Enum.UserInputType.MouseMovement
				or input.UserInputType == Enum.UserInputType.Touch
			)
		then
			local delta = Vector2.new(input.Position.X, input.Position.Y) - dragStart
			targetFrame.Position =
				UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end))
end

function MainFrame.new(options)
	local self = setmetatable({}, MainFrame)
	options = options or {}
	self._cleanup = Cleanup.new()

	-- Tab management
	self._tabs = {}
	self._activeTab = nil
	self._minimized = false
	self._dialogOpen = false
	self._minimizeKey = options.MinimizeKey

	local ProtectGui = protectgui or (syn and syn.protect_gui) or function() end
	-- ScreenGui
	self.ScreenGui = Utils.create("ScreenGui", {
		Name = "TzarUI",
		IgnoreGuiInset = false,
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		Parent = game:GetService("CoreGui"),
	})
	ProtectGui(self.ScreenGui)

	-- Main Frame
	self.Instance = Utils.create("Frame", {
		Name = "Main",
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Color3.fromRGB(11, 11, 11),
		BorderSizePixel = 0,
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(0, 616, 0, 444),
		Parent = self.ScreenGui,
	})

	Utils.applyCorner(self.Instance, 18)
	Utils.applyStroke(self.Instance, { Color = Color3.fromRGB(65, 65, 65) })
	Utils.applyPadding(self.Instance, 2, 2, 2, 2)
	Utils.applyListLayout(self.Instance, { Padding = 2 })

	-- TopBar
	self._topBar = Utils.create("ImageLabel", {
		Name = "TopBar",
		Image = "rbxassetid://81315260945695",
		ImageColor3 = Color3.fromRGB(22, 22, 22),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 48),
		Active = true, -- Required for input events
		Parent = self.Instance,
	})

	-- Setup dragging on topbar
	setupDragging(self._topBar, self.Instance, function(conn)
		self._cleanup:Track(conn)
	end)

	-- Logo
	self._logo = Utils.create("ImageLabel", {
		Name = "Logo",
		Image = "rbxassetid://136939379308753",
		AnchorPoint = Vector2.new(0, 0.5),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 18, 0.5, 0),
		Size = UDim2.new(0, 29, 0, 22),
		Parent = self._topBar,
	})

	-- Title
	self._title = Utils.create("TextLabel", {
		Name = "Title",
		Text = 'TZAR<font size="18" color="rgb(128,128,128)">.cc</font>',
		RichText = true,
		Font = Enum.Font.GothamBold,
		TextSize = 22,
		TextColor3 = Color3.fromRGB(249, 249, 249),
		TextXAlignment = Enum.TextXAlignment.Left,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 56, 0, 0),
		Size = UDim2.new(0, 200, 1, 0),
		Parent = self._topBar,
	})

	-- Buttons container
	self._buttonsFrame = Utils.create("Frame", {
		Name = "Buttons",
		AnchorPoint = Vector2.new(1, 0.5),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.new(1, -8, 0.5, 0),
		Size = UDim2.new(0, 0, 1, 0),
		Parent = self._topBar,
	})

	Utils.applyListLayout(self._buttonsFrame, {
		Padding = 8,
		Direction = Enum.FillDirection.Horizontal,
		HorizontalAlignment = Enum.HorizontalAlignment.Right,
		VerticalAlignment = Enum.VerticalAlignment.Center,
	})

	-- Search button
	self._searchBtn = Utils.create("TextButton", {
		Name = "Search",
		Text = "",
		AutomaticSize = Enum.AutomaticSize.XY,
		BackgroundColor3 = Color3.fromRGB(26, 26, 26),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		LayoutOrder = -1,
		Parent = self._buttonsFrame,
	})
	Utils.applyCorner(self._searchBtn)
	Utils.applyPadding(self._searchBtn, 8, 8, 8, 8)

	Utils.create("ImageLabel", {
		Name = "Icon",
		Image = "rbxassetid://6031154871",
		BackgroundTransparency = 1,
		Size = UDim2.new(0, 16, 0, 16),
		Parent = self._searchBtn,
	})

	setupButtonAnimations(self._searchBtn, 1, Color3.fromRGB(26, 26, 26), function(conn)
		self._cleanup:Track(conn)
	end)

	-- Minimize button
	self._minimizeBtn = Utils.create("TextButton", {
		Name = "Minimize",
		Text = "",
		AutomaticSize = Enum.AutomaticSize.XY,
		BackgroundColor3 = Color3.fromRGB(26, 26, 26),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Parent = self._buttonsFrame,
	})
	Utils.applyCorner(self._minimizeBtn)
	Utils.applyPadding(self._minimizeBtn, 8, 8, 8, 8)

	self._minimizeIcon = Utils.create("ImageLabel", {
		Name = "Icon",
		Image = "rbxassetid://15269257100",
		ImageRectOffset = Vector2.new(514, 257),
		ImageRectSize = Vector2.new(256, 256),
		BackgroundTransparency = 1,
		Size = UDim2.new(0, 16, 0, 16),
		Parent = self._minimizeBtn,
	})

	-- Close button
	self._closeBtn = Utils.create("TextButton", {
		Name = "Close",
		Text = "",
		AutomaticSize = Enum.AutomaticSize.XY,
		BackgroundColor3 = Color3.fromRGB(26, 26, 26),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		LayoutOrder = 1,
		Parent = self._buttonsFrame,
	})
	Utils.applyCorner(self._closeBtn)
	Utils.applyPadding(self._closeBtn, 8, 8, 8, 8)

	self._closeIcon = Utils.create("ImageLabel", {
		Name = "Icon",
		Image = "rbxassetid://15269329696",
		ImageRectOffset = Vector2.new(0, 514),
		ImageRectSize = Vector2.new(256, 256),
		BackgroundTransparency = 1,
		Size = UDim2.new(0, 16, 0, 16),
		Parent = self._closeBtn,
	})

	-- Setup button animations
	setupButtonAnimations(self._minimizeBtn, 1, Color3.fromRGB(26, 26, 26), function(conn)
		self._cleanup:Track(conn)
	end)
	setupButtonAnimations(self._closeBtn, 1, Color3.fromRGB(180, 50, 50), function(conn)
		self._cleanup:Track(conn)
	end)

	-- MainSection (TabContainer + Content)
	self._mainSection = Utils.create("Frame", {
		Name = "MainSection",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 1, -50),
		Parent = self.Instance,
	})

	Utils.applyListLayout(self._mainSection, {
		Padding = 2,
		Direction = Enum.FillDirection.Horizontal,
	})

	-- TabContainer
	self._tabContainer = Utils.create("ImageLabel", {
		Name = "TabContainer",
		Image = "rbxassetid://113165827406336",
		ImageColor3 = Color3.fromRGB(22, 22, 22),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(0, 200, 1, 0),
		Parent = self._mainSection,
	})

	-- Tabs scroll
	self._tabsScroll = Utils.create("ScrollingFrame", {
		Name = "TabsIn",
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		ScrollBarImageColor3 = Color3.fromRGB(128, 128, 128),
		ScrollBarThickness = 2,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 1, 0),
		Parent = self._tabContainer,
	})
	Utils.applyListLayout(self._tabsScroll, { Padding = 2 })
	Utils.applyPadding(self._tabsScroll, 2, 2, 2, 2)

	-- Content Container
	self._container = Utils.create("Frame", {
		Name = "Container",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 1, 0),
		Parent = self._mainSection,
		ClipsDescendants = true,
	})
	Utils.applyFlex(self._container)

	-- Page layout for content with smooth transitions
	self._pageLayout = Utils.create("UIPageLayout", {
		Name = "PageLayout",
		SortOrder = Enum.SortOrder.LayoutOrder,
		Animated = true,
		TweenTime = 0.3,
		EasingStyle = Enum.EasingStyle.Quint,
		EasingDirection = Enum.EasingDirection.Out,
		Parent = self._container,
	})

	-- Create Mini-bar (shown when minimized)
	self:_createMiniBar()

	-- Create Close Dialog
	self:_createCloseDialog()

	-- Create notification container
	self:_createNotificationContainer()

	-- Initialize Tooltip system
	Tooltip:_init(self.ScreenGui)

	-- Create Command Menu
	self._commandMenu = CommandMenu.new(self)

	-- Signals
	self.OnClose = Signal.new()
	self.OnMinimize = Signal.new()

	-- Search button click
	self._cleanup:Track(self._searchBtn.MouseButton1Click:Connect(function()
		self._commandMenu:Toggle()
	end))

	-- Close: show confirmation dialog
	self._cleanup:Track(self._closeBtn.MouseButton1Click:Connect(function()
		self:_showCloseDialog()
	end))

	-- Minimize: show mini-bar
	self._cleanup:Track(self._minimizeBtn.MouseButton1Click:Connect(function()
		self.OnMinimize:Fire()
		self:Minimize()
	end))

	-- Global keyboard listener for MinimizeKey (works even when minimized)
	if self._minimizeKey then
		self._cleanup:Track(UserInputService.InputBegan:Connect(function(input, gameProcessed)
			if gameProcessed then
				return
			end
			if input.KeyCode == self._minimizeKey then
				self:Toggle()
			end
		end))
	end

	-- Create Settings tab
	self:_createSettingsTab()

	-- Animate in on creation
	self:AnimateOpen()

	return self
end

-- Create the mini-bar that shows when minimized
function MainFrame:_createMiniBar()
	self._miniBar = Utils.create("Frame", {
		Name = "MiniBar",
		AnchorPoint = Vector2.new(0.5, 0),
		BackgroundColor3 = Color3.fromRGB(11, 11, 11),
		Position = UDim2.new(0.5, 0, 0, 10),
		Size = UDim2.new(0, 140, 0, 40),
		Visible = false,
		Parent = self.ScreenGui,
	})
	Utils.applyCorner(self._miniBar, 12)
	Utils.applyStroke(self._miniBar, { Color = Color3.fromRGB(65, 65, 65) })

	-- Make mini-bar draggable
	setupDragging(self._miniBar, self._miniBar, function(conn)
		self._cleanup:Track(conn)
	end)

	-- Mini logo
	Utils.create("ImageLabel", {
		Name = "Logo",
		Image = "rbxassetid://136939379308753",
		AnchorPoint = Vector2.new(0, 0.5),
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 12, 0.5, 0),
		Size = UDim2.new(0, 22, 0, 17),
		Parent = self._miniBar,
	})

	-- Mini title
	Utils.create("TextLabel", {
		Name = "Title",
		Text = "TZAR",
		Font = Enum.Font.GothamBold,
		TextSize = 14,
		TextColor3 = Color3.fromRGB(200, 200, 200),
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 40, 0, 0),
		Size = UDim2.new(0, 50, 1, 0),
		Parent = self._miniBar,
	})

	-- Restore button
	local restoreBtn = Utils.create("TextButton", {
		Name = "Restore",
		Text = "",
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -8, 0.5, 0),
		Size = UDim2.new(0, 28, 0, 28),
		BackgroundColor3 = Color3.fromRGB(9, 156, 75),
		BackgroundTransparency = 0.1,
		BorderSizePixel = 0,
		Parent = self._miniBar,
	})
	Utils.applyCorner(restoreBtn, 6)

	-- Restore icon (expand)
	Utils.create("ImageLabel", {
		Name = "Icon",
		Image = "rbxassetid://6035047409", -- Expand icon
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		BackgroundTransparency = 1,
		Size = UDim2.new(0, 14, 0, 14),
		Parent = restoreBtn,
	})

	-- Restore button click
	self._cleanup:Track(restoreBtn.MouseButton1Click:Connect(function()
		self:Restore()
	end))

	-- Hover effect
	self._cleanup:Track(restoreBtn.MouseEnter:Connect(function()
		TweenService:Create(restoreBtn, TWEEN_FAST, {
			BackgroundColor3 = Color3.fromRGB(11, 180, 87),
			BackgroundTransparency = 0,
		}):Play()
	end))
	self._cleanup:Track(restoreBtn.MouseLeave:Connect(function()
		TweenService:Create(restoreBtn, TWEEN_FAST, {
			BackgroundColor3 = Color3.fromRGB(9, 156, 75),
			BackgroundTransparency = 0.1,
		}):Play()
	end))
end

-- Create close confirmation dialog
function MainFrame:_createCloseDialog()
	-- Dialog overlay (inside MainFrame)
	local huy = Utils.create("Folder", {
		Name = "DialogOverlay",
		Parent = self.Instance,
	})
	self._dialogOverlay = Utils.create("Frame", {
		Name = "DialogOverlay",
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, 0),
		Visible = false,
		ZIndex = 100,
		Parent = huy,
	})
	Utils.applyCorner(self._dialogOverlay, 18)

	-- Dialog frame
	self._dialog = Utils.create("Frame", {
		Name = "CloseDialog",
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Color3.fromRGB(18, 18, 18),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(0, 280, 0, 140),
		ZIndex = 101,
		Parent = self._dialogOverlay,
	})
	Utils.applyCorner(self._dialog, 12)
	Utils.applyStroke(self._dialog, { Color = Color3.fromRGB(50, 50, 50) })
	Utils.applyPadding(self._dialog, 16, 16, 16, 16)

	-- Dialog title
	Utils.create("TextLabel", {
		Name = "Title",
		Text = "Close Application?",
		Font = Enum.Font.GothamBold,
		TextSize = 16,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 20),
		ZIndex = 102,
		Parent = self._dialog,
	})

	-- Dialog description
	Utils.create("TextLabel", {
		Name = "Description",
		Text = "Are you sure you want to close? All unsaved changes will be lost.",
		Font = Enum.Font.Gotham,
		TextSize = 13,
		TextColor3 = Color3.fromRGB(150, 150, 150),
		TextWrapped = true,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 0, 0, 28),
		Size = UDim2.new(1, 0, 0, 40),
		ZIndex = 102,
		Parent = self._dialog,
	})

	-- Button container
	local buttonContainer = Utils.create("Frame", {
		Name = "Buttons",
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.new(0, 0, 1, 0),
		Size = UDim2.new(1, 0, 0, 32),
		ZIndex = 102,
		Parent = self._dialog,
	})
	Utils.applyListLayout(buttonContainer, {
		Padding = 10,
		Direction = Enum.FillDirection.Horizontal,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
	})

	-- Cancel button
	local cancelBtn = Utils.create("TextButton", {
		Name = "Cancel",
		Text = "Cancel",
		Font = Enum.Font.GothamMedium,
		TextSize = 14,
		TextColor3 = Color3.fromRGB(200, 200, 200),
		BackgroundColor3 = Color3.fromRGB(35, 35, 35),
		Size = UDim2.new(0, 100, 0, 32),
		ZIndex = 103,
		AutoButtonColor = false,
		Parent = buttonContainer,
	})
	Utils.applyCorner(cancelBtn, 8)

	-- Close button
	local confirmBtn = Utils.create("TextButton", {
		Name = "Confirm",
		Text = "Close",
		Font = Enum.Font.GothamMedium,
		TextSize = 14,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundColor3 = Color3.fromRGB(180, 50, 50),
		Size = UDim2.new(0, 100, 0, 32),
		ZIndex = 103,
		AutoButtonColor = false,
		Parent = buttonContainer,
	})
	Utils.applyCorner(confirmBtn, 8)

	-- Cancel click
	self._cleanup:Track(cancelBtn.MouseButton1Click:Connect(function()
		self:_hideCloseDialog()
	end))

	-- Confirm click
	self._cleanup:Track(confirmBtn.MouseButton1Click:Connect(function()
		self:_hideCloseDialog()
		self.OnClose:Fire()
		self:AnimateClose()
	end))

	-- Button hover effects
	self._cleanup:Track(cancelBtn.MouseEnter:Connect(function()
		TweenService:Create(cancelBtn, TWEEN_FAST, { BackgroundColor3 = Color3.fromRGB(45, 45, 45) }):Play()
	end))
	self._cleanup:Track(cancelBtn.MouseLeave:Connect(function()
		TweenService:Create(cancelBtn, TWEEN_FAST, { BackgroundColor3 = Color3.fromRGB(35, 35, 35) }):Play()
	end))

	self._cleanup:Track(confirmBtn.MouseEnter:Connect(function()
		TweenService:Create(confirmBtn, TWEEN_FAST, { BackgroundColor3 = Color3.fromRGB(200, 60, 60) }):Play()
	end))
	self._cleanup:Track(confirmBtn.MouseLeave:Connect(function()
		TweenService:Create(confirmBtn, TWEEN_FAST, { BackgroundColor3 = Color3.fromRGB(180, 50, 50) }):Play()
	end))

	-- Click overlay to cancel
	self._cleanup:Track(self._dialogOverlay.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			-- Check if click is outside dialog
			local pos = input.Position
			local dialogPos = self._dialog.AbsolutePosition
			local dialogSize = self._dialog.AbsoluteSize

			if
				pos.X < dialogPos.X
				or pos.X > dialogPos.X + dialogSize.X
				or pos.Y < dialogPos.Y
				or pos.Y > dialogPos.Y + dialogSize.Y
			then
				self:_hideCloseDialog()
			end
		end
	end))
end

function MainFrame:_showCloseDialog()
	if self._dialogOpen then
		return
	end
	self._dialogOpen = true

	self._dialogOverlay.Visible = true
	self._dialogOverlay.BackgroundTransparency = 1
	self._dialog.Size = UDim2.new(0, 280, 0, 0)

	TweenService:Create(self._dialogOverlay, TWEEN_FAST, {
		BackgroundTransparency = 0.5,
	}):Play()

	TweenService:Create(self._dialog, TWEEN_SMOOTH, {
		Size = UDim2.new(0, 280, 0, 140),
	}):Play()
end

function MainFrame:_hideCloseDialog()
	if not self._dialogOpen then
		return
	end
	self._dialogOpen = false

	TweenService:Create(self._dialogOverlay, TWEEN_FAST, {
		BackgroundTransparency = 1,
	}):Play()

	local tween = TweenService:Create(self._dialog, TWEEN_FAST, {
		Size = UDim2.new(0, 280, 0, 0),
	})
	tween:Play()
	tween.Completed:Wait()
	self._dialogOverlay.Visible = false
end

-- Add a new tab
function MainFrame:AddTab(options)
	local tabIndex = #self._tabs + 1

	-- Create tab button
	local tabBtn = TabButton.new({
		Name = options.Name or "Tab " .. tabIndex,
		Icon = options.Icon,
		IconOffset = options.IconOffset,
		IconSize = options.IconSize,
		LayoutOrder = options.LayoutOrder or tabIndex,
	})
	tabBtn.Instance.Parent = self._tabsScroll

	-- Create content scroll frame for this tab
	local contentScroll = Utils.create("ScrollingFrame", {
		Name = options.Name or "Tab" .. tabIndex,
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		ScrollBarImageColor3 = Color3.fromRGB(45, 45, 45),
		ScrollBarThickness = 0,
		Active = true,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 1, 0),
		LayoutOrder = tabIndex,
		Parent = self._container,
		ClipsDescendants = true,
	})
	Utils.applyPadding(contentScroll, 0, 4, 4, 4)
	Utils.applyListLayout(contentScroll, { Padding = 4 })

	-- Create Tab object
	local tab = Tab.new(contentScroll, tabBtn, tabIndex, self, options.Name)

	-- Store tab info
	table.insert(self._tabs, tab)

	-- Tab click handler
	tabBtn.OnClick:Connect(function()
		self:SelectTab(tabIndex)
	end)

	-- Auto-select first tab
	if tabIndex == 1 then
		self:SelectTab(1)
	end

	-- Return Tab object
	return tab
end

-- Select tab by index
function MainFrame:SelectTab(index: number)
	local tab = self._tabs[index]
	if not tab then
		return
	end

	-- Deselect previous tab
	if self._activeTab then
		self._activeTab.Button:SetActive(false)
	end

	-- Select new tab
	self._activeTab = tab
	tab.Button:SetActive(true)

	-- Switch page
	self._pageLayout:JumpTo(tab.Instance)
end

-- Animate window open
function MainFrame:AnimateOpen()
	self.Instance.Size = UDim2.new(0, 616, 0, 0)
	self.Instance.BackgroundTransparency = 1

	local tween = TweenService:Create(self.Instance, TWEEN_SMOOTH, {
		Size = UDim2.new(0, 616, 0, 444),
		BackgroundTransparency = 0,
	})
	tween:Play()
end

-- Animate window close
function MainFrame:AnimateClose()
	local tween = TweenService:Create(self.Instance, TWEEN_NORMAL, {
		Size = UDim2.new(0, 616, 0, 0),
		BackgroundTransparency = 1,
	})
	tween:Play()
	tween.Completed:Wait()
	self:Destroy()
end

-- Minimize to mini-bar
function MainFrame:Minimize()
	if self._minimized then
		return
	end
	self._minimized = true

	-- Animate main window out
	local tween = TweenService:Create(self.Instance, TWEEN_NORMAL, {
		Size = UDim2.new(0, 616, 0, 0),
		BackgroundTransparency = 1,
	})
	tween:Play()
	tween.Completed:Wait()
	self.Instance.Visible = false

	-- Show mini-bar
	self._miniBar.Visible = true
	self._miniBar.Size = UDim2.new(0, 0, 0, 40)
	TweenService:Create(self._miniBar, TWEEN_SMOOTH, {
		Size = UDim2.new(0, 140, 0, 40),
	}):Play()
end

-- Restore from mini-bar
function MainFrame:Restore()
	if not self._minimized then
		return
	end
	self._minimized = false

	-- Hide mini-bar
	local miniTween = TweenService:Create(self._miniBar, TWEEN_FAST, {
		Size = UDim2.new(0, 0, 0, 40),
	})
	miniTween:Play()
	miniTween.Completed:Wait()
	self._miniBar.Visible = false

	-- Show main window
	self.Instance.Visible = true
	self.Instance.Size = UDim2.new(0, 616, 0, 0)
	self.Instance.BackgroundTransparency = 1

	TweenService:Create(self.Instance, TWEEN_SMOOTH, {
		Size = UDim2.new(0, 616, 0, 444),
		BackgroundTransparency = 0,
	}):Play()
end

-- Toggle minimize/restore
function MainFrame:Toggle()
	if self._minimized then
		self:Restore()
	else
		self:Minimize()
	end
end

function MainFrame:Destroy()
	self.OnClose:Destroy()
	self.OnMinimize:Destroy()
	if self._commandMenu then
		self._commandMenu:Destroy()
	end
	Tooltip:Destroy()
	self._cleanup:Cleanup()
	self.ScreenGui:Destroy()
end

-- Create notification container
function MainFrame:_createNotificationContainer()
	self._notifContainer = Utils.create("Frame", {
		Name = "Notifications",
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, 0, 0, 10),
		Size = UDim2.new(0, 320, 1, -20),
		BackgroundTransparency = 1,
		Parent = self.ScreenGui,
	})
	self._notifications = {}
end

-- Show notification
function MainFrame:Notify(options)
	local notif = Notification.new({
		Title = options.Title or "Notification",
		Message = options.Message or options.Description,
		Duration = options.Duration or 5,
		Action = options.Action,
		ActionCallback = options.ActionCallback,
	})
	notif.Instance.Parent = self._notifContainer

	-- Calculate position
	local yOffset = 0
	for _, n in ipairs(self._notifications) do
		if not n:IsDismissed() then
			yOffset = yOffset + 80
		end
	end

	notif:Show(yOffset)
	table.insert(self._notifications, notif)

	-- Clean up dismissed notifications periodically
	task.delay(6, function()
		self:_cleanupNotifications()
	end)

	return notif
end

function MainFrame:_cleanupNotifications()
	local activeNotifs = {}
	local yOffset = 0

	for _, notif in ipairs(self._notifications) do
		if not notif:IsDismissed() then
			notif:UpdatePosition(yOffset)
			yOffset = yOffset + 80
			table.insert(activeNotifs, notif)
		end
	end

	self._notifications = activeNotifs
end

-- Register element for search
function MainFrame:RegisterElement(element, tab, title: string, elementType: string)
	if self._commandMenu then
		self._commandMenu:RegisterElement(element, tab, title, elementType)
	end
end

-- Get command menu
function MainFrame:GetCommandMenu()
	return self._commandMenu
end

-- Create Settings tab
function MainFrame:_createSettingsTab()
	local settingsTab = self:AddTab({
		Name = "Settings",
		Icon = "settings", -- Uses new icons system
		LayoutOrder = 9999,
	})

	local configSection = settingsTab:AddSection({
		Name = "Configuration",
	})

	-- AutoSave toggle
	configSection:AddToggle({
		Title = "Auto Save",
		Description = "Automatically save config when values change",
		Default = Config.AutoSave,
		Callback = function(value)
			Config.AutoSave = value
			Config:SaveMetrics()
		end,
	})

	-- AutoLoad toggle
	configSection:AddToggle({
		Title = "Auto Load",
		Description = "Automatically load selected config on startup",
		Default = Config.AutoLoad,
		Callback = function(value)
			Config.AutoLoad = value
			Config:SaveMetrics()
		end,
	})

	-- Profile selection
	local profileDropdown = configSection:AddDropdown({
		Title = "Profile",
		Options = Config.Profiles,
		Default = Config.ActiveProfile,
		Callback = function(value)
			Config:SwitchProfile(value)
		end,
	})

	-- Create new profile
	local nameInput = configSection:AddTextBox({
		Title = "New Profile Name",
		Placeholder = "Enter name...",
		ClearOnFocus = true,
	})

	configSection:AddButton({
		Name = "Create Profile",
		Callback = function()
			local name = nameInput:GetValue()
			if name and name ~= "" then
				Config:CreateProfile(name)
				profileDropdown:Refresh(Config.Profiles, Config.ActiveProfile)
				nameInput:SetValue("")
			end
		end,
	})

	-- Config actions
	local group = settingsTab:AddButtonGroup()

	group:AddButton({
		Name = "Save Config",
		Variant = "Primary",
		Callback = function()
			Config:Save()
			-- Show notification
			if self.ScreenGui then
				local NotificationObj = require("./Overlays/Notification").new({
					Title = "Success",
					Description = "Configuration saved successfully!",
					Icon = "check",
					Duration = 3,
				})
				NotificationObj:Show(self.ScreenGui)
			end
		end,
	})

	group:AddButton({
		Name = "Load Config",
		Callback = function()
			Config:Load()
			-- Refresh values in UI if needed (components auto-update via SetValue)
			if self.ScreenGui then
				local NotificationObj = require("./Overlays/Notification").new({
					Title = "Loaded",
					Description = "Configuration loaded successfully!",
					Icon = "check",
					Duration = 3,
				})
				NotificationObj:Show(self.ScreenGui)
			end
		end,
	})

	configSection:AddButton({
		Name = "Delete Profile",
		Variant = "Destroy",
		Callback = function()
			if Config.ActiveProfile == "Default" then
				return
			end
			Config:DeleteProfile(Config.ActiveProfile)
			profileDropdown:Refresh(Config.Profiles, Config.ActiveProfile)
		end,
	})

	local uiSection = settingsTab:AddSection({
		Name = "Interface",
	})

	uiSection:AddButton({
		Name = "Unload UI",
		Variant = "Destroy",
		Callback = function()
			self:AnimateClose()
		end,
	})
end

return MainFrame
