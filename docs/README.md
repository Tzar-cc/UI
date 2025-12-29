# Tzar UI Library

Современная UI библиотека для Roblox с системой конфигов, профилей и
автосохранения.

## Установка

```lua
local Tzar = loadstring(game:HttpGet("URL_TO_TZAR"))()
-- или
local Tzar = require(path.to.Tzar)
```

---

## Быстрый старт

```lua
local Tzar = require("./src")

-- Создание окна
local Window = Tzar.new({
    Title = "My Script",
    MinimizeKey = Enum.KeyCode.RightControl,
})

-- Создание вкладки
local MainTab = Window:AddTab({
    Name = "Main",
    Icon = "home",
})

-- Создание секции
local Section = MainTab:AddSection({ Name = "Features" })

-- Добавление Toggle с Flag (автосохранение)
Section:AddToggle({
    Title = "Auto Farm",
    Flag = "AutoFarm",
    Default = false,
    Callback = function(state)
        print("AutoFarm:", state)
    end,
})

-- Доступ к значению через Flags
print(Tzar.Flags["AutoFarm"]:GetValue())
```

---

## Window (Окно)

```lua
local Window = Tzar.new({
    Title = "Application Title",
    MinimizeKey = Enum.KeyCode.RightControl, -- Клавиша сворачивания
})
```

### Методы Window

| Метод                     | Описание                |
| ------------------------- | ----------------------- |
| `Window:AddTab(options)`  | Создать вкладку         |
| `Window:SelectTab(index)` | Переключить на вкладку  |
| `Window:Notify(options)`  | Показать уведомление    |
| `Window:Minimize()`       | Свернуть в мини-бар     |
| `Window:Restore()`        | Развернуть из мини-бара |
| `Window:Toggle()`         | Переключить свёрнутость |
| `Window:Destroy()`        | Закрыть и уничтожить    |

---

## Tab (Вкладка)

```lua
local Tab = Window:AddTab({
    Name = "Tab Name",
    Icon = "home",           -- Название иконки (lucide/geist)
    LayoutOrder = 1,         -- Порядок в списке
})
```

### Иконки

Поддерживаются иконки из Lucide и Geist:

```lua
Icon = "home"          -- Lucide: home
Icon = "settings"      -- Lucide: settings
Icon = "geist:eye"     -- Geist: eye
Icon = "lucide:star"   -- Lucide: star (явное указание)
```

### Методы Tab

| Метод                     | Описание              |
| ------------------------- | --------------------- |
| `Tab:AddSection(options)` | Создать секцию        |
| `Tab:AddButtonGroup()`    | Создать группу кнопок |

---

## Section (Секция)

```lua
local Section = Tab:AddSection({
    Name = "Section Name",
    Collapsed = false,       -- Свёрнута по умолчанию
})
```

### Методы Section

Секция содержит все компоненты:

```lua
Section:AddParagraph(options)
Section:AddButton(options)
Section:AddToggle(options)
Section:AddSlider(options)
Section:AddDropdown(options)
Section:AddKeybind(options)
Section:AddTextBox(options)
Section:AddColorPicker(options)
Section:AddButtonGroup()
```

---

## Компоненты

### Paragraph (Текст)

```lua
Section:AddParagraph({
    Title = "Заголовок",
    Description = "Описание текста",
})
```

---

### Button (Кнопка)

```lua
Section:AddButton({
    Name = "Click Me",
    Variant = "Primary",     -- Primary, Secondary, Outline, Destroy
    Callback = function()
        print("Clicked!")
    end,
})
```

**Варианты стилей:** `Primary` (зелёный), `Secondary` (серый), `Outline`
(прозрачный), `Destroy` (красный)

---

### ButtonGroup (Группа кнопок)

```lua
local Group = Section:AddButtonGroup()

Group:AddButton({
    Name = "Save",
    Variant = "Primary",
    Callback = function() end,
})

Group:AddButton({
    Name = "Load",
    Callback = function() end,
})
```

---

### Toggle (Переключатель)

```lua
local toggle = Section:AddToggle({
    Title = "Enable Feature",
    Description = "Optional description",
    Flag = "FeatureEnabled",    -- ID для Config системы
    Default = false,
    Callback = function(state)
        print("State:", state)
    end,
})
```

**Методы:**

- `toggle:GetValue()` → `boolean`
- `toggle:SetValue(bool)`
- `toggle:Toggle()`

---

### Slider (Ползунок)

```lua
local slider = Section:AddSlider({
    Title = "Walk Speed",
    Flag = "WalkSpeed",
    Min = 16,
    Max = 100,
    Default = 16,
    Increment = 1,              -- Шаг значения
    Suffix = " studs/s",        -- Суффикс после числа
    Callback = function(value)
        print("Speed:", value)
    end,
})
```

**Методы:**

- `slider:GetValue()` → `number`
- `slider:SetValue(number)`

---

### Dropdown (Выпадающий список)

```lua
-- Одиночный выбор
local dropdown = Section:AddDropdown({
    Title = "Select Team",
    Flag = "SelectedTeam",
    Options = {"Red", "Blue", "Green"},
    Default = "Red",
    Multi = false,
    Callback = function(selected)
        print("Selected:", selected)
    end,
})

-- Множественный выбор
Section:AddDropdown({
    Title = "Select Items",
    Flag = "SelectedItems",
    Options = {"Item1", "Item2", "Item3"},
    Default = {"Item1", "Item2"},
    Multi = true,
    Callback = function(selected)
        -- selected это таблица
        for _, item in ipairs(selected) do
            print(item)
        end
    end,
})
```

**Методы:**

- `dropdown:GetValue()` → `string` или `table` (для Multi)
- `dropdown:SetValue(value)`
- `dropdown:Refresh(options, default)` — обновить список
- `dropdown:SelectAll()` — выбрать все (Multi)
- `dropdown:DeselectAll()` — снять выбор (Multi)

---

### Keybind (Горячая клавиша)

```lua
local keybind = Section:AddKeybind({
    Title = "Toggle Key",
    Flag = "ToggleKey",
    Default = Enum.KeyCode.E,
    Callback = function(key)
        print("Key set to:", key.Name)
    end,
})
```

**Методы:**

- `keybind:GetValue()` / `keybind:GetKey()` → `Enum.KeyCode`
- `keybind:SetValue(key)` / `keybind:SetKey(key)`
- `keybind:IsPressed()` → `boolean`

**Управление:**

- Клик по кнопке — начать запись
- Нажать клавишу — установить
- `Escape` — отмена
- `Backspace` — очистить (None)

---

### TextBox (Текстовое поле)

```lua
local textbox = Section:AddTextBox({
    Title = "Player Name",
    Flag = "TargetPlayer",
    Placeholder = "Enter name...",
    Default = "",
    ClearOnFocus = false,
    Callback = function(text)
        print("Input:", text)
    end,
})
```

**Методы:**

- `textbox:GetValue()` → `string`
- `textbox:SetValue(string)`

---

### ColorPicker (Выбор цвета)

```lua
local colorpicker = Section:AddColorPicker({
    Title = "ESP Color",
    Flag = "ESPColor",
    Default = Color3.fromRGB(255, 0, 0),
    Callback = function(color)
        print("Color:", color)
    end,
})
```

**Методы:**

- `colorpicker:GetValue()` → `Color3`
- `colorpicker:SetValue(Color3)`
- `colorpicker:Toggle()` — открыть/закрыть пикер

---

## Notifications (Уведомления)

```lua
Window:Notify({
    Title = "Success",
    Message = "Operation completed!",
    Duration = 5,                    -- Секунд (по умолчанию 5)
    Action = "Undo",                 -- Опциональная кнопка
    ActionCallback = function()
        print("Undo clicked")
    end,
})
```

---

## Config System (Система конфигов)

Tzar автоматически создаёт вкладку **Settings** с управлением конфигами.

### Flags (Флаги)

Любой компонент с параметром `Flag` регистрируется в глобальном реестре:

```lua
-- Создание с Flag
Section:AddToggle({
    Title = "Feature",
    Flag = "MyFeature",  -- ← ID флага
    Default = false,
})

-- Доступ к значению откуда угодно
local value = Tzar.Flags["MyFeature"]:GetValue()

-- Изменение значения
Tzar.Flags["MyFeature"]:SetValue(true)
```

### AutoSave / AutoLoad

| Настройка | По умолчанию | Описание                              |
| --------- | ------------ | ------------------------------------- |
| AutoSave  | `true`       | Автоматически сохранять при изменении |
| AutoLoad  | `true`       | Автоматически загружать при запуске   |

Настройки доступны в **Settings → Configuration**.

### Профили

- **Default** — профиль по умолчанию (нельзя удалить)
- Можно создавать неограниченное количество профилей
- Переключение профилей мгновенно применяет все значения

### Структура файлов

```
TzarConfigs/
├── Default.json      -- Профиль
├── MyProfile.json    -- Кастомный профиль
└── metrics.json      -- Настройки (AutoSave, AutoLoad, LastProfile)
```

---

## API Reference

### Tzar

```lua
Tzar.new(options)           -- Создать окно
Tzar.Flags                  -- Таблица всех зарегистрированных элементов
Tzar.Components             -- Доступ к классам компонентов
```

### Общие методы компонентов

Все input-компоненты имеют единый интерфейс:

| Метод                    | Описание                  |
| ------------------------ | ------------------------- |
| `GetValue()`             | Получить текущее значение |
| `SetValue(value)`        | Установить значение       |
| `SetTitle(string)`       | Изменить заголовок        |
| `SetDescription(string)` | Изменить описание         |
| `SetVisible(bool)`       | Показать/скрыть           |
| `Destroy()`              | Уничтожить элемент        |

### Сигналы

```lua
-- Toggle
toggle.OnToggle:Connect(function(state) end)
toggle.Changed:Connect(function(state) end)  -- Алиас

-- Slider, Dropdown, TextBox, ColorPicker, Keybind
element.OnChanged:Connect(function(value) end)
element.Changed:Connect(function(value) end)  -- Алиас
```

---

## Пример полного скрипта

```lua
local Tzar = require("./src")

-- Окно
local Window = Tzar.new({
    Title = "My Script v1.0",
    MinimizeKey = Enum.KeyCode.RightControl,
})

-- Вкладки
local MainTab = Window:AddTab({ Name = "Main", Icon = "home" })
local VisualsTab = Window:AddTab({ Name = "Visuals", Icon = "eye" })
local MiscTab = Window:AddTab({ Name = "Misc", Icon = "settings" })

-- Main Tab
local FarmSection = MainTab:AddSection({ Name = "Farming" })

FarmSection:AddToggle({
    Title = "Auto Farm",
    Flag = "AutoFarm",
    Description = "Automatically farms resources",
    Default = false,
    Callback = function(state)
        -- Логика авто-фарма
    end,
})

FarmSection:AddSlider({
    Title = "Farm Speed",
    Flag = "FarmSpeed",
    Min = 1,
    Max = 10,
    Default = 5,
    Callback = function(value)
        -- Изменить скорость
    end,
})

-- Visuals Tab
local ESPSection = VisualsTab:AddSection({ Name = "ESP" })

ESPSection:AddToggle({
    Title = "Player ESP",
    Flag = "PlayerESP",
    Default = false,
})

ESPSection:AddColorPicker({
    Title = "ESP Color",
    Flag = "ESPColor",
    Default = Color3.fromRGB(255, 0, 0),
})

ESPSection:AddDropdown({
    Title = "ESP Type",
    Flag = "ESPType",
    Options = {"Box", "Corner", "Highlight"},
    Default = "Box",
})

-- Misc Tab
local SettingsSection = MiscTab:AddSection({ Name = "Character" })

SettingsSection:AddSlider({
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

SettingsSection:AddSlider({
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

-- Уведомление при загрузке
Window:Notify({
    Title = "Loaded",
    Message = "Script loaded successfully!",
    Duration = 3,
})

return Window
```

---

## Горячие клавиши

| Клавиша       | Действие                     |
| ------------- | ---------------------------- |
| `MinimizeKey` | Свернуть/развернуть UI       |
| `Ctrl+K`      | Открыть Command Menu (поиск) |

---

## Совместимость

UI библиотека совместима со всеми популярными эксплойтами:

- Synapse X
- Script-Ware
- Fluxus
- Solara
- Wave
- И другие

Файловые функции (`writefile`, `readfile`, и т.д.) автоматически определяются.
