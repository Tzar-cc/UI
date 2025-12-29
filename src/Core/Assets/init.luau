--[[
    Tzar UI Library - Assets
    Central asset management using Icons library
]]

local Assets = {}

-- Load Icons library (V2)
local Icons = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/Footagesus/Icons/main/Main-v2.lua"))()

-- Set default icon type to lucide
Icons.SetIconsType("lucide")

-- Expose Icons module for direct access if needed
Assets.Icons = Icons

-- Get icon image URL by name
-- Supports prefixed icons like "geist:house" or just "house" for default lucide
function Assets.GetIcon(name: string): string
	if not name or name == "" then
		return ""
	end

	-- Check for prefix (e.g., "geist:house", "craft:folder")
	local prefix, iconName = string.match(name, "^(%w+):(.+)$")

	if prefix then
		-- Temporarily switch icon type for this request
		local currentType = Icons.GetIconsType and Icons.GetIconsType() or "lucide"
		Icons.SetIconsType(prefix)
		local icon = Icons.GetIcon(iconName)
		Icons.SetIconsType(currentType)
		return icon or ""
	else
		-- Use default icon type (lucide)
		return Icons.GetIcon(name) or ""
	end
end

-- Create an ImageLabel with the icon (using Icons.Image)
function Assets.CreateIconImage(options: {
	Icon: string,
	Size: UDim2?,
	Colors: { any }?,
	Parent: Instance?,
})
	local iconData = Icons.Image({
		Icon = options.Icon,
		Colors = options.Colors,
		Size = options.Size or UDim2.new(0, 16, 0, 16),
	})

	if options.Parent and iconData and iconData.IconFrame then
		iconData.IconFrame.Parent = options.Parent
	end

	return iconData
end

-- Common icon names (for convenience)
Assets.CommonIcons = {
	Close = "x",
	Minimize = "minus",
	Search = "search",
	Check = "check",
	ChevronDown = "chevron-down",
	ChevronRight = "chevron-right",
	Settings = "settings",
	Info = "info",
	Warning = "alert-triangle",
	Error = "alert-circle",
	Home = "home",
	User = "user",
	Folder = "folder",
	File = "file",
	Star = "star",
	Heart = "heart",
	Trash = "trash",
	Edit = "edit",
	Plus = "plus",
	Menu = "menu",
}

return Assets
