--[[
    Tzar UI Library - Type Definitions
    Centralized type definitions for type safety and intellisense
]]

export type ThemeColors = {
	Background: Color3,
	BackgroundSecondary: Color3,
	BackgroundTertiary: Color3,
	Border: Color3,
	Text: Color3,
	TextSecondary: Color3,
	Primary: Color3,
	Distract: Color3,
	Accent: Color3,
}

export type ThemeFonts = {
	Regular: Enum.Font,
	Medium: Enum.Font,
	Bold: Enum.Font,
}

export type ThemeSizes = {
	CornerRadius: number,
	CornerRadiusSmall: number,
	CornerRadiusLarge: number,
	Padding: number,
	PaddingSmall: number,
	PaddingLarge: number,
	FontSize: number,
	FontSizeSmall: number,
	FontSizeLarge: number,
}

export type Theme = {
	Colors: ThemeColors,
	Fonts: ThemeFonts,
	Sizes: ThemeSizes,
}

-- Button Options
export type ButtonVariant = "Primary" | "Secondary" | "Outline" | "Distract"

export type ButtonOptions = {
	Title: string,
	Description: string?,
	Variant: ButtonVariant?,
	Callback: (() -> ())?,
	LayoutOrder: number?,
}

-- Toggle Options
export type ToggleOptions = {
	Title: string,
	Description: string?,
	Default: boolean?,
	Callback: ((value: boolean) -> ())?,
	LayoutOrder: number?,
}

-- Slider Options
export type SliderOptions = {
	Title: string,
	Description: string?,
	Min: number?,
	Max: number?,
	Default: number?,
	Increment: number?,
	Suffix: string?,
	Callback: ((value: number) -> ())?,
	LayoutOrder: number?,
}

-- Dropdown Options
export type DropdownOptions = {
	Title: string,
	Description: string?,
	Options: { string },
	Default: string?,
	Callback: ((value: string) -> ())?,
	LayoutOrder: number?,
}

-- Input Options
export type InputOptions = {
	Title: string,
	Description: string?,
	Placeholder: string?,
	Default: string?,
	ClearOnFocus: boolean?,
	Callback: ((value: string) -> ())?,
	LayoutOrder: number?,
}

-- Keybind Options
export type KeybindOptions = {
	Title: string,
	Description: string?,
	Default: Enum.KeyCode?,
	Callback: ((key: Enum.KeyCode) -> ())?,
	LayoutOrder: number?,
}

-- Label Options
export type LabelOptions = {
	Text: string,
	Color: Color3?,
	Size: number?,
	RichText: boolean?,
	LayoutOrder: number?,
}

-- Colorpicker Options
export type ColorpickerOptions = {
	Title: string,
	Description: string?,
	Default: Color3?,
	Callback: ((color: Color3) -> ())?,
	LayoutOrder: number?,
}

-- Section Options
export type SectionOptions = {
	Name: string,
	Collapsed: boolean?,
	LayoutOrder: number?,
}

-- Tab Options
export type TabOptions = {
	Name: string,
	Icon: string?,
	LayoutOrder: number?,
}

-- Window Options
export type WindowOptions = {
	Title: string?,
	Size: UDim2?,
	Position: UDim2?,
	Draggable: boolean?,
	MinimizeKey: Enum.KeyCode?,
}

return nil
