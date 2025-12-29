--[[
    Tzar UI Library - Utilities
    Helper functions for UI creation
]]

local Theme = require("./Theme")

local Utils = {}

--// Create instance with properties
function Utils.create<T>(className: string, properties: { [string]: any }?): T
	local instance = Instance.new(className)

	if properties then
		for key, value in properties do
			if key == "Parent" then
				continue
			end
			(instance :: any)[key] = value
		end

		-- Set parent last to avoid property change events
		if properties.Parent then
			instance.Parent = properties.Parent
		end
	end

	return instance :: any
end

--// Apply UICorner
function Utils.applyCorner(instance: GuiObject, radius: number?): UICorner
	local sizes = Theme:Sizes()
	return Utils.create("UICorner", {
		CornerRadius = UDim.new(0, radius or sizes.CornerRadius),
		Parent = instance,
	})
end

--// Apply UIPadding
function Utils.applyPadding(
	instance: GuiObject,
	top: number?,
	right: number?,
	bottom: number?,
	left: number?
): UIPadding
	local sizes = Theme:Sizes()
	local defaultPadding = sizes.Padding

	return Utils.create("UIPadding", {
		PaddingTop = UDim.new(0, top or defaultPadding),
		PaddingRight = UDim.new(0, right or top or defaultPadding),
		PaddingBottom = UDim.new(0, bottom or top or defaultPadding),
		PaddingLeft = UDim.new(0, left or right or top or defaultPadding),
		Parent = instance,
	})
end

--// Apply UIListLayout
export type ListLayoutOptions = {
	Padding: number?,
	Direction: Enum.FillDirection?,
	HorizontalAlignment: Enum.HorizontalAlignment?,
	VerticalAlignment: Enum.VerticalAlignment?,
	SortOrder: Enum.SortOrder?,
	Wraps: boolean?,
}

function Utils.applyListLayout(instance: GuiObject, options: ListLayoutOptions?): UIListLayout
	local opts = options or {}
	return Utils.create("UIListLayout", {
		Padding = UDim.new(0, opts.Padding or 4),
		FillDirection = opts.Direction or Enum.FillDirection.Vertical,
		HorizontalAlignment = opts.HorizontalAlignment or Enum.HorizontalAlignment.Left,
		VerticalAlignment = opts.VerticalAlignment or Enum.VerticalAlignment.Top,
		SortOrder = opts.SortOrder or Enum.SortOrder.LayoutOrder,
		Wraps = opts.Wraps or false,
		Parent = instance,
	})
end

--// Apply UIStroke
export type StrokeOptions = {
	Color: Color3?,
	Thickness: number?,
	Mode: Enum.ApplyStrokeMode?,
}

function Utils.applyStroke(instance: GuiObject, options: StrokeOptions?): UIStroke
	local opts = options or {}
	local colors = Theme:Colors()

	return Utils.create("UIStroke", {
		Color = opts.Color or colors.Border,
		Thickness = opts.Thickness or 1,
		ApplyStrokeMode = opts.Mode or Enum.ApplyStrokeMode.Border,
		Parent = instance,
	})
end

--// Apply UIFlexItem
function Utils.applyFlex(instance: GuiObject, mode: Enum.UIFlexMode?): UIFlexItem
	return Utils.create("UIFlexItem", {
		FlexMode = mode or Enum.UIFlexMode.Fill,
		Parent = instance,
	})
end

--// Create text label with theme defaults
export type TextOptions = {
	Text: string?,
	Size: number?,
	Color: Color3?,
	Font: Enum.Font?,
	XAlignment: Enum.TextXAlignment?,
	YAlignment: Enum.TextYAlignment?,
	RichText: boolean?,
	Wrapped: boolean?,
	AutoSize: Enum.AutomaticSize?,
}

function Utils.createText(options: TextOptions): TextLabel
	local colors = Theme:Colors()
	local fonts = Theme:Fonts()
	local sizes = Theme:Sizes()

	return Utils.create("TextLabel", {
		Text = options.Text or "",
		TextSize = options.Size or sizes.FontSize,
		TextColor3 = options.Color or colors.Text,
		Font = options.Font or fonts.Regular,
		TextXAlignment = options.XAlignment or Enum.TextXAlignment.Left,
		TextYAlignment = options.YAlignment or Enum.TextYAlignment.Center,
		RichText = options.RichText or false,
		TextWrapped = options.Wrapped or false,
		AutomaticSize = options.AutoSize or Enum.AutomaticSize.None,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
	})
end

return Utils
