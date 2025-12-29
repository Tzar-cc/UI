local Module = {}

local API_URL = "https://www.tzar.cc/api/generate"
local CACHE_FOLDER = "Tzar/ui_cache/"

-- 1. Безопасное создание папок
if not isfolder(CACHE_FOLDER) then
	pcall(makefolder, CACHE_FOLDER)
end

-- 2. Универсальный запрос (Wave/Solara/Macsploit)
local function getBinaryData(url)
	local requestFunc = (syn and syn.request) or (http and http.request) or http_request or request
	if requestFunc then
		local success, response = pcall(function()
			return requestFunc({ Url = url, Method = "GET" })
		end)
		if success and response and response.Success then
			return response.Body
		end
	end
	-- Если request не сработал, пробуем HttpGet
	local s, r = pcall(function()
		return game:HttpGet(url)
	end)
	return s and r or nil
end

local function toHex(color)
	return string.format(
		"%02X%02X%02X",
		math.round(color.R * 255),
		math.round(color.G * 255),
		math.round(color.B * 255)
	)
end

local function CreateCustomFrame(config)
	local templateSize = 100
	local radii = config.Radii or { tl = 0, tr = 0, bl = 0, br = 0 }
	local color = config.Color or Color3.new(1, 1, 1)
	local sWidth = config.StrokeWidth or 0
	local sColor = config.StrokeColor or Color3.new(0, 0, 0)

	-- Ключ кэша
	local cacheKey = string.format(
		"f_%d%d%d%d_%s_%d_%s.png",
		radii.tl,
		radii.tr,
		radii.bl,
		radii.br,
		toHex(color),
		sWidth,
		toHex(sColor)
	)
	local filePath = CACHE_FOLDER .. cacheKey

	local imageAsset = ""

	-- Загрузка
	if isfile(filePath) then
		imageAsset = getcustomasset(filePath)
	else
		local query = string.format(
			"?w=%d&h=%d&tl=%d&tr=%d&bl=%d&br=%d&bg=%s&sWidth=%d&sColor=%s",
			templateSize,
			templateSize,
			radii.tl,
			radii.tr,
			radii.bl,
			radii.br,
			toHex(color),
			sWidth,
			toHex(sColor)
		)

		local data = getBinaryData(API_URL .. query)
		if data and #data > 500 then -- PNG не может быть слишком маленьким
			writefile(filePath, data)
			imageAsset = getcustomasset(filePath)
		end
	end

	-- Создаем объект (всегда, даже если сервер сдох)
	local img = Instance.new("ImageLabel")
	img.Name = "CustomCSSFrame"
	img.Size = config.Size or UDim2.new(0, 200, 0, 100)
	img.Position = config.Position or UDim2.new(0.5, 0, 0.5, 0)
	img.BackgroundTransparency = 1
	img.ImageTransparency = config.Transparency or 0

	if imageAsset ~= "" then
		img.Image = imageAsset
		-- Настройка 9-Slice
		local maxR = math.max(radii.tl, radii.tr, radii.bl, radii.br)
		local margin = math.clamp(maxR + sWidth + 5, 1, 49) -- защита от выхода за пределы 100px
		img.ScaleType = Enum.ScaleType.Slice
		img.SliceCenter = Rect.new(margin, margin, templateSize - margin, templateSize - margin)
	else
		-- ФОЛБЕК: если сервер не ответил, рисуем обычный фрейм, чтобы скрипт не падал
		warn("UI Server Offline: Using standard fallback")
	end

	return img
end
return Module
-- ---------------------------------------------------------
-- -- БЕЗОПАСНЫЙ ЗАПУСК
-- ---------------------------------------------------------

-- local success, myFrame = pcall(function()
-- 	return CreateCustomFrame({
-- 		Size = UDim2.new(0, 400, 0, 200),
-- 		Position = UDim2.new(0.5, -200, 0.5, -100),
-- 		Radii = { tl = 2, tr = 8, bl = 8, br = 8 },
-- 		Color = Color3.fromRGB(30, 31, 34),
-- 		StrokeWidth = 2,
-- 		StrokeColor = Color3.fromRGB(255, 255, 255),
-- 		Transparency = 0,
-- 	})
-- end)

-- if success and myFrame then
-- 	-- Ищем CoreGui максимально надежно
-- 	local sg = CoreGui:FindFirstChild("TzarUI") or Instance.new("ScreenGui")
-- 	sg.Name = "TzarUI"
-- 	sg.Parent = CoreGui
-- 	myFrame.Parent = sg
-- else
-- 	warn("Critical Error: Frame creation failed: " .. tostring(myFrame))
-- end
