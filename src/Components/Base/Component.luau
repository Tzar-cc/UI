--[[
    Tzar UI Library - Base Component
    Abstract base class for all UI components
]]

local TweenService = game:GetService("TweenService")

local Config = require("../../Core/Config")
local Utils = require("../../Core/Utils")
local Animation = require("../../Core/Animation")
local Constants = require("../../Core/Constants")
local Theme = require("../../Core/Theme")
local Types = require("../../Core/Types")
local Cleanup = require("../../Core/Cleanup")

local Component = {}
Component.__index = Component

function Component.new(props)
	local self = setmetatable({}, Component)

	self.Props = props or {}
	self.Instance = nil
	self._connections = {}
	self._cleanup = Cleanup.new()

	-- Register with Config system if Flag or Name is present
	local flagId = props.Flag or props.Name
	if flagId then
		Config:Register(flagId, self)
		self._flagId = flagId
	end

	return self
end

function Component:Mount(parent: Instance)
	if self.Instance then
		self.Instance.Parent = parent
	end
end

function Component:Unmount()
	if self.Instance then
		self.Instance.Parent = nil
	end
end

function Component:SetVisible(visible: boolean)
	if self.Instance then
		self.Instance.Visible = visible
	end
end

function Component:Destroy()
	for _, conn in ipairs(self._connections) do
		conn:Disconnect()
	end
	self._connections = {}
	self._cleanup:Cleanup()

	-- Unregister from config
	if self._flagId then
		Config:Unregister(self._flagId)
	end

	if self.Instance then
		self.Instance:Destroy()
	end
end

-- Helper to add hover effects
function Component:AddHoverEffect(instance: GuiObject, hoverColor: Color3, normalColor: Color3)
	table.insert(
		self._connections,
		instance.MouseEnter:Connect(function()
			Animation.Color(instance, hoverColor)
		end)
	)

	table.insert(
		self._connections,
		instance.MouseLeave:Connect(function()
			Animation.Color(instance, normalColor)
		end)
	)
end

function Component:_track(task)
	return self._cleanup:Track(task)
end

return Component
