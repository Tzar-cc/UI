--[[
    Tzar UI Library - Config System
    Global registry and profile management
]]

local HttpService = game:GetService("HttpService")

local Config = {}
Config.Flags = {} -- Global registry (Tzar.Flags)
Config.Profiles = {}
Config.ActiveProfile = "Default"
Config.Folder = "TzarConfigs"
Config.Extension = ".json"
Config.AutoSave = true -- Autosave configs on value change
Config.AutoLoad = true -- Autoload selected config on startup
Config._connections = {}

-- Safe file functions (exploit compatibility)
local writefile = writefile or function() end
local readfile = readfile or function() end
local isfile = isfile or function()
	return false
end
local listfiles = listfiles or function()
	return {}
end
local makefolder = makefolder or function() end
local isfolder = isfolder or function()
	return false
end
local delfile = delfile or function() end

function Config:Init()
	if not isfolder(self.Folder) then
		makefolder(self.Folder)
	end

	-- Load profiles
	self:RefreshProfiles()

	-- Load settings and last active profile from metrics
	if isfile(self.Folder .. "/metrics" .. self.Extension) then
		local success, data = pcall(function()
			return HttpService:JSONDecode(readfile(self.Folder .. "/metrics" .. self.Extension))
		end)
		if success and data then
			-- Load AutoSave/AutoLoad settings
			if data.AutoSave ~= nil then
				self.AutoSave = data.AutoSave
			end
			if data.AutoLoad ~= nil then
				self.AutoLoad = data.AutoLoad
			end

			-- Load last active profile if exists
			if data.LastProfile and isfile(self.Folder .. "/" .. data.LastProfile .. self.Extension) then
				self.ActiveProfile = data.LastProfile
			end
		end
	end

	-- Initial load (only if AutoLoad is enabled)
	if self.AutoLoad then
		self:Load(self.ActiveProfile)
	end
end

function Config:RefreshProfiles()
	self.Profiles = {}
	if not isfolder(self.Folder) then
		return
	end

	local files = listfiles(self.Folder)
	for _, file in ipairs(files) do
		if file:find(self.Extension .. "$") and not file:find("metrics" .. self.Extension) then
			local name = file:match("([^/\\]+)" .. self.Extension .. "$")
			if name then
				table.insert(self.Profiles, name)
			end
		end
	end

	-- Ensure default exists in list
	local hasDefault = false
	for _, p in ipairs(self.Profiles) do
		if p == "Default" then
			hasDefault = true
			break
		end
	end
	if not hasDefault then
		table.insert(self.Profiles, "Default")
	end
end

function Config:CreateProfile(name)
	if not name or name == "" then
		return
	end
	if not table.find(self.Profiles, name) then
		table.insert(self.Profiles, name)
		self:Save(name) -- Save empty or current state
	end
	self:SwitchProfile(name)
end

function Config:SwitchProfile(name)
	self.ActiveProfile = name
	self:Load(name)
	self:SaveMetrics()
end

function Config:DeleteProfile(name)
	if name == "Default" then
		return
	end -- Prevent deleting default

	local path = self.Folder .. "/" .. name .. self.Extension
	if isfile(path) then
		delfile(path)
	end

	local index = table.find(self.Profiles, name)
	if index then
		table.remove(self.Profiles, index)
	end

	if self.ActiveProfile == name then
		self:SwitchProfile("Default")
	end
end

function Config:Save(profileName)
	profileName = profileName or self.ActiveProfile
	local data = {}

	for id, element in pairs(self.Flags) do
		if element.GetValue then
			local success, value = pcall(function()
				return element:GetValue()
			end)
			if success then
				-- Convert Color3 to hex string for saving
				if typeof(value) == "Color3" then
					value = value:ToHex()
				end
				data[id] = value
			end
		end
	end

	local json = HttpService:JSONEncode(data)
	writefile(self.Folder .. "/" .. profileName .. self.Extension, json)
end

function Config:Load(profileName)
	profileName = profileName or self.ActiveProfile
	local path = self.Folder .. "/" .. profileName .. self.Extension

	if not isfile(path) then
		return
	end

	local success, data = pcall(function()
		return HttpService:JSONDecode(readfile(path))
	end)

	if not success then
		return
	end

	for id, value in pairs(data) do
		local element = self.Flags[id]
		if element and element.SetValue then
			-- Convert hex back to Color3 if needed
			if element.Type == "ColorPicker" and type(value) == "string" then
				value = Color3.fromHex(value)
			end
			-- Handle Enum.KeyCode for Keybinds
			if element.Type == "Keybind" and type(value) == "string" then
				local key = Enum.KeyCode[value]
				if key then
					value = key
				end
			elseif element.Type == "Keybind" and type(value) == "number" then
				-- Handle keycode saved as integer number
				local enums = Enum.KeyCode:GetEnumItems()
				for _, enum in ipairs(enums) do
					if enum.Value == value then
						value = enum
						break
					end
				end
			end

			element:SetValue(value)
		end
	end
end

function Config:SaveMetrics()
	local data = {
		LastProfile = self.ActiveProfile,
		AutoSave = self.AutoSave,
		AutoLoad = self.AutoLoad,
	}
	writefile(self.Folder .. "/metrics" .. self.Extension, HttpService:JSONEncode(data))
end

-- Global Registry Helper
function Config:Register(id, element)
	if not id then
		return
	end
	self.Flags[id] = element
	if self._connections[id] then
		self._connections[id]:Disconnect()
		self._connections[id] = nil
	end

	-- Setup autosave if enabled and element has Changed signal
	if self.AutoSave and element.Changed then
		local conn = element.Changed:Connect(function()
			self:Save()
		end)
		self._connections[id] = conn
	end
end

function Config:Unregister(id)
	if not id then
		return
	end
	if self._connections[id] then
		self._connections[id]:Disconnect()
		self._connections[id] = nil
	end
	self.Flags[id] = nil
end

return Config
