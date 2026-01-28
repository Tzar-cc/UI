--[[
    Tzar UI Library - Command Menu
    Search/command palette with element navigation
]]

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Utils = require("../Core/Utils")
local Signal = require("../Core/Signal")
local Cleanup = require("../Core/Cleanup")

local CommandMenu = {}
CommandMenu.__index = CommandMenu

-- Tween presets
local TWEEN_FAST = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local TWEEN_SMOOTH = TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

-- Dimensions
local MENU_WIDTH = 400
local MENU_HEIGHT = 350
local RESULT_HEIGHT = 36

function CommandMenu.new(mainFrame)
	local self = setmetatable({}, CommandMenu)

	self._mainFrame = mainFrame
	self._elements = {} -- {element, tab, title, type}
	self._results = {}
	self._selectedIndex = 1
	self._visible = false
	self._cleanup = Cleanup.new()
	self._resultsCleanup = Cleanup.new()

	local holder = Utils.create("Folder", {
		Name = "CommandMenuHolder",
		Parent = mainFrame.Instance,
	})

	-- Overlay
	self._overlay = Utils.create("Frame", {
		Name = "CommandMenuOverlay",
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, 0),
		Visible = false,
		ZIndex = 200,
		Parent = holder,
	})
	Utils.applyCorner(self._overlay, 18)

	-- Menu container
	self._menu = Utils.create("Frame", {
		Name = "CommandMenu",
		AnchorPoint = Vector2.new(0.5, 0.3),
		Position = UDim2.new(0.5, 0, 0.3, 0),
		Size = UDim2.new(0, MENU_WIDTH, 0, 0),
		BackgroundColor3 = Color3.fromRGB(20, 20, 20),
		BorderSizePixel = 0,
		ClipsDescendants = true,
		ZIndex = 201,
		Parent = self._overlay,
	})
	Utils.applyCorner(self._menu, 12)
	Utils.applyStroke(self._menu, { Color = Color3.fromRGB(50, 50, 50), Thickness = 1 })

	-- Search input
	self._searchContainer = Utils.create("Frame", {
		Name = "SearchContainer",
		Size = UDim2.new(1, 0, 0, 50),
		BackgroundTransparency = 1,
		ZIndex = 202,
		Parent = self._menu,
	})
	Utils.applyPadding(self._searchContainer, 12, 12, 12, 12)

	-- Search icon
	Utils.create("ImageLabel", {
		Name = "SearchIcon",
		Image = "rbxassetid://6031154871", -- Search icon
		ImageColor3 = Color3.fromRGB(100, 100, 100),
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 0, 0.5, 0),
		Size = UDim2.new(0, 18, 0, 18),
		BackgroundTransparency = 1,
		ZIndex = 203,
		Parent = self._searchContainer,
	})

	self._searchInput = Utils.create("TextBox", {
		Name = "SearchInput",
		Text = "",
		PlaceholderText = "Search elements...",
		Font = Enum.Font.Gotham,
		TextSize = 14,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		PlaceholderColor3 = Color3.fromRGB(100, 100, 100),
		TextXAlignment = Enum.TextXAlignment.Left,
		Position = UDim2.new(0, 28, 0, 0),
		Size = UDim2.new(1, -28, 1, 0),
		BackgroundTransparency = 1,
		ClearTextOnFocus = false,
		ZIndex = 203,
		Parent = self._searchContainer,
	})

	-- Separator
	Utils.create("Frame", {
		Name = "Separator",
		Position = UDim2.new(0, 0, 0, 50),
		Size = UDim2.new(1, 0, 0, 1),
		BackgroundColor3 = Color3.fromRGB(40, 40, 40),
		BorderSizePixel = 0,
		ZIndex = 202,
		Parent = self._menu,
	})

	-- Results container
	self._resultsContainer = Utils.create("ScrollingFrame", {
		Name = "Results",
		Position = UDim2.new(0, 0, 0, 51),
		Size = UDim2.new(1, 0, 1, -51),
		CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollBarThickness = 3,
		ScrollBarImageColor3 = Color3.fromRGB(60, 60, 60),
		BackgroundTransparency = 1,
		ZIndex = 202,
		Parent = self._menu,
	})
	Utils.applyListLayout(self._resultsContainer, { Padding = 2 })
	Utils.applyPadding(self._resultsContainer, 4, 8, 8, 8)

	-- No results label
	self._noResults = Utils.create("TextLabel", {
		Name = "NoResults",
		Text = "No elements found (0 registered)",
		Font = Enum.Font.Gotham,
		TextSize = 13,
		TextColor3 = Color3.fromRGB(100, 100, 100),
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 40),
		Visible = false,
		ZIndex = 203,
		Parent = self._resultsContainer,
	})

	-- Signals
	self.OnSelect = Signal.new()

	-- Search input changes
	self._cleanup:Track(self._searchInput:GetPropertyChangedSignal("Text"):Connect(function()
		self:_updateResults()
	end))

	-- Keyboard navigation
	self._cleanup:Track(UserInputService.InputBegan:Connect(function(input, processed)
		if not self._visible then
			return
		end

		if input.KeyCode == Enum.KeyCode.Escape then
			self:Hide()
		elseif input.KeyCode == Enum.KeyCode.Up then
			self:_selectPrevious()
		elseif input.KeyCode == Enum.KeyCode.Down then
			self:_selectNext()
		elseif input.KeyCode == Enum.KeyCode.Return then
			self:_confirmSelection()
		end
	end))

	-- Click overlay to close
	self._cleanup:Track(self._overlay.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			local pos = input.Position
			local menuPos = self._menu.AbsolutePosition
			local menuSize = self._menu.AbsoluteSize

			if
				pos.X < menuPos.X
				or pos.X > menuPos.X + menuSize.X
				or pos.Y < menuPos.Y
				or pos.Y > menuPos.Y + menuSize.Y
			then
				self:Hide()
			end
		end
	end))

	return self
end

-- Register an element for search
function CommandMenu:RegisterElement(element, tab, title: string, elementType: string)
	table.insert(self._elements, {
		Element = element,
		Tab = tab,
		Title = title,
		Type = elementType or "Element",
	})
end

-- Update search results
function CommandMenu:_updateResults()
	self._resultsCleanup:Cleanup()

	-- Clear existing results
	for _, child in ipairs(self._resultsContainer:GetChildren()) do
		if child:IsA("TextButton") then
			child:Destroy()
		end
	end
	self._results = {}

	local query = self._searchInput.Text:lower()

	-- Filter elements
	local matches = {}
	for _, entry in ipairs(self._elements) do
		if query == "" or entry.Title:lower():find(query, 1, true) then
			table.insert(matches, entry)
		end
	end

	-- Show no results message if needed
	self._noResults.Text = "No elements found (" .. #self._elements .. " registered)"
	self._noResults.Visible = #matches == 0

	-- Create result items
	for i, entry in ipairs(matches) do
		local resultBtn = Utils.create("TextButton", {
			Name = "Result_" .. i,
			Text = "",
			Size = UDim2.new(1, 0, 0, RESULT_HEIGHT),
			BackgroundColor3 = Color3.fromRGB(30, 30, 30),
			BackgroundTransparency = i == 1 and 0 or 1,
			AutoButtonColor = false,
			LayoutOrder = i,
			ZIndex = 203,
			Parent = self._resultsContainer,
		})
		Utils.applyCorner(resultBtn, 6)

		-- Type badge
		local badge = Utils.create("TextLabel", {
			Name = "Badge",
			Text = entry.Type,
			Font = Enum.Font.GothamMedium,
			TextSize = 10,
			TextColor3 = Color3.fromRGB(9, 156, 75),
			BackgroundColor3 = Color3.fromRGB(9, 156, 75),
			BackgroundTransparency = 0.85,
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, 8, 0.5, 0),
			AutomaticSize = Enum.AutomaticSize.X,
			Size = UDim2.new(0, 0, 0, 18),
			ZIndex = 204,
			Parent = resultBtn,
		})
		Utils.applyCorner(badge, 4)
		Utils.applyPadding(badge, 0, 6, 0, 6)

		-- Title
		Utils.create("TextLabel", {
			Name = "Title",
			Text = entry.Title,
			Font = Enum.Font.Gotham,
			TextSize = 13,
			TextColor3 = Color3.fromRGB(220, 220, 220),
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
			BackgroundTransparency = 1,
			Position = UDim2.new(0, 80, 0, 0),
			Size = UDim2.new(1, -130, 1, 0),
			ZIndex = 204,
			Parent = resultBtn,
		})

		-- Tab name
		local tabName = entry.Tab and entry.Tab.Name or ""
		Utils.create("TextLabel", {
			Name = "Tab",
			Text = tabName,
			Font = Enum.Font.Gotham,
			TextSize = 11,
			TextColor3 = Color3.fromRGB(100, 100, 100),
			TextXAlignment = Enum.TextXAlignment.Right,
			BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -8, 0.5, 0),
			Size = UDim2.new(0, 60, 1, 0),
			ZIndex = 204,
			Parent = resultBtn,
		})

		-- Hover
		self._resultsCleanup:Track(resultBtn.MouseEnter:Connect(function()
			self:_selectIndex(i)
		end))

		-- Click
		self._resultsCleanup:Track(resultBtn.MouseButton1Click:Connect(function()
			self:_selectIndex(i)
			self:_confirmSelection()
		end))

		table.insert(self._results, { Button = resultBtn, Entry = entry })
	end

	self._selectedIndex = math.min(1, #self._results)
	self:_updateSelection()
end

function CommandMenu:_selectIndex(index: number)
	self._selectedIndex = math.clamp(index, 1, math.max(1, #self._results))
	self:_updateSelection()
end

function CommandMenu:_selectNext()
	self:_selectIndex(self._selectedIndex + 1)
end

function CommandMenu:_selectPrevious()
	self:_selectIndex(self._selectedIndex - 1)
end

function CommandMenu:_updateSelection()
	for i, result in ipairs(self._results) do
		local isSelected = i == self._selectedIndex
		TweenService:Create(result.Button, TWEEN_FAST, {
			BackgroundTransparency = isSelected and 0 or 1,
		}):Play()
	end
end

function CommandMenu:_confirmSelection()
	local result = self._results[self._selectedIndex]
	if not result then
		return
	end

	local entry = result.Entry
	self:Hide()

	-- Navigate to element
	if entry.Tab and self._mainFrame then
		-- Find tab index
		for i, tab in ipairs(self._mainFrame._tabs) do
			if tab == entry.Tab then
				self._mainFrame:SelectTab(i)
				break
			end
		end

		-- Scroll to element and highlight
		task.defer(function()
			if entry.Element and entry.Element.Instance then
				local element = entry.Element.Instance
				local scrollFrame = element:FindFirstAncestorWhichIsA("ScrollingFrame")
				if scrollFrame then
					-- Scroll to element
					local elementPos = element.AbsolutePosition
					local scrollPos = scrollFrame.AbsolutePosition
					local offset = elementPos.Y - scrollPos.Y
					scrollFrame.CanvasPosition = Vector2.new(0, offset - 50)
				end

				-- Highlight effect
				local originalColor = element.BackgroundColor3
				TweenService:Create(element, TWEEN_FAST, {
					BackgroundColor3 = Color3.fromRGB(9, 156, 75),
					BackgroundTransparency = 0,
				}):Play()

				task.delay(0.5, function()
					TweenService:Create(element, TWEEN_FAST, {
						BackgroundColor3 = originalColor,
						BackgroundTransparency = 1,
					}):Play()
				end)
			end
		end)
	end

	self.OnSelect:Fire(entry)
end

function CommandMenu:Show()
	if self._visible then
		return
	end
	self._visible = true

	self._overlay.Visible = true
	self._overlay.BackgroundTransparency = 1
	self._menu.Size = UDim2.new(0, MENU_WIDTH, 0, 0)
	self._searchInput.Text = ""

	TweenService:Create(self._overlay, TWEEN_FAST, {
		BackgroundTransparency = 0.5,
	}):Play()

	TweenService:Create(self._menu, TWEEN_SMOOTH, {
		Size = UDim2.new(0, MENU_WIDTH, 0, MENU_HEIGHT),
	}):Play()

	-- Focus search
	task.delay(0.1, function()
		self._searchInput:CaptureFocus()
	end)

	self:_updateResults()
end

function CommandMenu:Hide()
	if not self._visible then
		return
	end
	self._visible = false

	self._searchInput:ReleaseFocus()

	TweenService:Create(self._overlay, TWEEN_FAST, {
		BackgroundTransparency = 1,
	}):Play()

	local tween = TweenService:Create(self._menu, TWEEN_FAST, {
		Size = UDim2.new(0, MENU_WIDTH, 0, 0),
	})
	tween:Play()
	tween.Completed:Wait()

	self._overlay.Visible = false
end

function CommandMenu:Toggle()
	if self._visible then
		self:Hide()
	else
		self:Show()
	end
end

function CommandMenu:Destroy()
	self.OnSelect:Destroy()
	self._resultsCleanup:Cleanup()
	self._cleanup:Cleanup()
	self._overlay:Destroy()
end

return CommandMenu
