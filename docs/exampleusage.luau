--[[
    Tzar UI Library - Полный пример использования
    Демонстрирует все возможности библиотеки
]]

local Tzar = require("./src")

--[[ ============================================
    1. СОЗДАНИЕ ОКНА
============================================ ]]

local Window = Tzar.new({
	Title = "Tzar UI Demo",
	MinimizeKey = Enum.KeyCode.RightControl, -- Клавиша сворачивания
})

--[[ ============================================
    2. СОЗДАНИЕ ВКЛАДОК
============================================ ]]

local MainTab = Window:AddTab({
	Name = "Main",
	Icon = "home", -- Lucide иконка
})

local VisualsTab = Window:AddTab({
	Name = "Visuals",
	Icon = "eye",
})

local MiscTab = Window:AddTab({
	Name = "Misc",
	Icon = "settings",
})

--[[ ============================================
    3. MAIN TAB - Основные функции
============================================ ]]

-- Секция: Информация
local InfoSection = MainTab:AddSection({ Name = "Information" })

InfoSection:AddParagraph({
	Title = "Welcome to Tzar UI",
	Description = "This example demonstrates all available components and the Config system with Flags.",
})

-- Секция: Фарминг
local FarmSection = MainTab:AddSection({ Name = "Farming" })

-- Toggle с Flag (автосохранение)
local autoFarmToggle = FarmSection:AddToggle({
	Title = "Auto Farm",
	Flag = "AutoFarm", --> Доступ: Tzar.Flags["AutoFarm"]
	Description = "Enables automatic resource farming",
	Default = false,
	Callback = function(state)
		print("[AutoFarm]", state and "Enabled" or "Disabled")
	end,
})

-- Slider с Flag
local speedSlider = FarmSection:AddSlider({
	Title = "Farm Speed",
	Flag = "FarmSpeed",
	Description = "Speed multiplier for farming",
	Min = 1,
	Max = 10,
	Default = 5,
	Increment = 0.5,
	Suffix = "x",
	Callback = function(value)
		print("[FarmSpeed]", value)
	end,
})

-- Dropdown с Flag
local targetDropdown = FarmSection:AddDropdown({
	Title = "Target Type",
	Flag = "FarmTarget",
	Options = { "All", "Enemies", "Resources", "NPCs" },
	Default = "All",
	Multi = false,
	Callback = function(selected)
		print("[FarmTarget]", selected)
	end,
})

-- Группа кнопок
local actionGroup = FarmSection:AddButtonGroup()

actionGroup:AddButton({
	Name = "Start Farm",
	Variant = "Primary",
	Callback = function()
		Window:Notify({
			Title = "Farm Started",
			Message = "Auto farming has been started!",
			Duration = 3,
		})
	end,
})

actionGroup:AddButton({
	Name = "Stop Farm",
	Variant = "Destroy",
	Callback = function()
		Window:Notify({
			Title = "Farm Stopped",
			Message = "Auto farming has been stopped.",
			Duration = 3,
		})
	end,
})

--[[ ============================================
    4. VISUALS TAB - Визуальные настройки
============================================ ]]

local ESPSection = VisualsTab:AddSection({ Name = "ESP Settings" })

ESPSection:AddToggle({
	Title = "Player ESP",
	Flag = "PlayerESP",
	Description = "Show ESP boxes around players",
	Default = false,
	Callback = function(state)
		print("[PlayerESP]", state)
	end,
})

-- ColorPicker с Flag
local espColorPicker = ESPSection:AddColorPicker({
	Title = "ESP Color",
	Flag = "ESPColor",
	Default = Color3.fromRGB(255, 0, 128),
	Callback = function(color)
		print("[ESPColor]", color)
	end,
})

-- Multi-select Dropdown
ESPSection:AddDropdown({
	Title = "ESP Elements",
	Flag = "ESPElements",
	Options = { "Box", "Name", "Health", "Distance", "Weapon" },
	Default = { "Box", "Name" },
	Multi = true,
	Callback = function(selected)
		print("[ESPElements]", table.concat(selected, ", "))
	end,
})

ESPSection:AddSlider({
	Title = "Max Distance",
	Flag = "ESPMaxDistance",
	Min = 100,
	Max = 2000,
	Default = 500,
	Increment = 50,
	Suffix = " studs",
	Callback = function(value)
		print("[ESPMaxDistance]", value)
	end,
})

--[[ ============================================
    5. MISC TAB - Разное
============================================ ]]

local CharSection = MiscTab:AddSection({ Name = "Character" })

CharSection:AddSlider({
	Title = "Walk Speed",
	Flag = "WalkSpeed",
	Min = 16,
	Max = 200,
	Default = 16,
	Suffix = " studs/s",
	Callback = function(value)
		pcall(function()
			game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = value
		end)
	end,
})

CharSection:AddSlider({
	Title = "Jump Power",
	Flag = "JumpPower",
	Min = 50,
	Max = 200,
	Default = 50,
	Callback = function(value)
		pcall(function()
			game.Players.LocalPlayer.Character.Humanoid.JumpPower = value
		end)
	end,
})

-- Keybind с Flag
CharSection:AddKeybind({
	Title = "Fly Toggle Key",
	Flag = "FlyKey",
	Default = Enum.KeyCode.F,
	Callback = function(key)
		print("[FlyKey] Set to:", key.Name)
	end,
})

-- TextBox с Flag
local UtilSection = MiscTab:AddSection({ Name = "Utilities" })

UtilSection:AddTextBox({
	Title = "Target Player",
	Flag = "TargetPlayer",
	Placeholder = "Enter player name...",
	Default = "",
	ClearOnFocus = false,
	Callback = function(text)
		print("[TargetPlayer]", text)
	end,
})

UtilSection:AddButton({
	Name = "Teleport to Target",
	Variant = "Primary",
	Callback = function()
		local targetName = Tzar.Flags["TargetPlayer"]:GetValue()
		if targetName and targetName ~= "" then
			Window:Notify({
				Title = "Teleporting",
				Message = "Teleporting to " .. targetName .. "...",
				Duration = 3,
			})
		else
			Window:Notify({
				Title = "Error",
				Message = "Please enter a player name first!",
				Duration = 3,
			})
		end
	end,
})

--[[ ============================================
    6. ИСПОЛЬЗОВАНИЕ FLAGS
============================================ ]]

-- Кнопка для демонстрации доступа к Flags
UtilSection:AddButton({
	Name = "Print All Config Values",
	Variant = "Secondary",
	Callback = function()
		print("\n=== Current Config Values ===")

		-- Доступ к значениям через Tzar.Flags
		print("AutoFarm:", Tzar.Flags["AutoFarm"]:GetValue())
		print("FarmSpeed:", Tzar.Flags["FarmSpeed"]:GetValue())
		print("FarmTarget:", Tzar.Flags["FarmTarget"]:GetValue())
		print("PlayerESP:", Tzar.Flags["PlayerESP"]:GetValue())
		print("ESPColor:", Tzar.Flags["ESPColor"]:GetValue())
		print("WalkSpeed:", Tzar.Flags["WalkSpeed"]:GetValue())
		print("FlyKey:", Tzar.Flags["FlyKey"]:GetValue())

		print("==============================\n")

		Window:Notify({
			Title = "Config Printed",
			Message = "Check console for all config values",
			Duration = 3,
		})
	end,
})

-- Программное изменение значений
UtilSection:AddButton({
	Name = "Set Random Values",
	Callback = function()
		-- Программное изменение через SetValue
		Tzar.Flags["FarmSpeed"]:SetValue(math.random(1, 10))
		Tzar.Flags["WalkSpeed"]:SetValue(math.random(16, 100))
		Tzar.Flags["ESPColor"]:SetValue(Color3.fromRGB(math.random(0, 255), math.random(0, 255), math.random(0, 255)))

		Window:Notify({
			Title = "Values Updated",
			Message = "Random values have been set!",
			Duration = 3,
		})
	end,
})

--[[ ============================================
    7. УВЕДОМЛЕНИЕ О ЗАГРУЗКЕ
============================================ ]]

Window:Notify({
	Title = "Tzar UI Loaded",
	Message = "All components initialized successfully!",
	Duration = 5,
	Action = "View Config",
	ActionCallback = function()
		-- Переключение на Settings tab (автоматически создан)
		Window:SelectTab(#Window._tabs) -- Last tab = Settings
	end,
})

--[[ ============================================
    АВТОСОХРАНЕНИЕ И ПРОФИЛИ
    
    Вкладка Settings создаётся автоматически!
    Там доступно:
    - Auto Save (вкл/выкл)
    - Auto Load (вкл/выкл)  
    - Выбор профиля
    - Создание нового профиля
    - Кнопки Save/Load
    - Удаление профиля
    
    Все элементы с Flag автоматически:
    - Сохраняются при изменении (если AutoSave = true)
    - Загружаются при старте (если AutoLoad = true)
============================================ ]]

return Window
