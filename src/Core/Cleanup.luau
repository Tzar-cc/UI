--[[
    Tzar UI Library - Cleanup Helper
    Simple cleanup manager for connections, instances, tweens, and callbacks
]]

local Cleanup = {}
Cleanup.__index = Cleanup

function Cleanup.new()
	local self = setmetatable({}, Cleanup)
	self._tasks = {}
	return self
end

function Cleanup:Track(task)
	if task == nil then
		return task
	end
	table.insert(self._tasks, task)
	return task
end

function Cleanup:TrackAll(...)
	for i = 1, select("#", ...) do
		self:Track(select(i, ...))
	end
end

function Cleanup:Cleanup()
	for i = #self._tasks, 1, -1 do
		local taskItem = self._tasks[i]
		self._tasks[i] = nil

		local taskType = typeof(taskItem)
		if taskType == "RBXScriptConnection" then
			taskItem:Disconnect()
		elseif taskType == "Instance" then
			taskItem:Destroy()
		elseif taskType == "Tween" then
			taskItem:Cancel()
		elseif type(taskItem) == "function" then
			taskItem()
		elseif type(taskItem) == "thread" then
			task.cancel(taskItem)
		elseif type(taskItem) == "table" then
			if taskItem.Destroy then
				taskItem:Destroy()
			elseif taskItem.Disconnect then
				taskItem:Disconnect()
			end
		end
	end
end

return Cleanup
