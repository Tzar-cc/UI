--[[
    Tzar UI Library - Signal System
    Simple event/callback system for component communication
]]

export type Connection = {
	Disconnect: (self: Connection) -> (),
}

export type Signal<T...> = {
	Connect: (self: Signal<T...>, callback: (T...) -> ()) -> Connection,
	Once: (self: Signal<T...>, callback: (T...) -> ()) -> Connection,
	Fire: (self: Signal<T...>, T...) -> (),
	Wait: (self: Signal<T...>) -> T...,
	Destroy: (self: Signal<T...>) -> (),
}

--// Signal Implementation

local Signal = {}
Signal.__index = Signal

function Signal.new<T...>(): Signal<T...>
	local self = setmetatable({}, Signal)
	self._connections = {}
	self._waiting = {}
	return self :: any
end

function Signal:Connect(callback: (...any) -> ()): Connection
	local connection = {
		_callback = callback,
		_connected = true,
	}

	function connection:Disconnect()
		self._connected = false
	end

	table.insert(self._connections, connection)
	return connection
end

function Signal:Once(callback: (...any) -> ()): Connection
	local connection
	connection = self:Connect(function(...)
		connection:Disconnect()
		callback(...)
	end)
	return connection
end

function Signal:Fire(...)
	-- Resume waiting threads
	for _, thread in self._waiting do
		task.spawn(thread, ...)
	end
	table.clear(self._waiting)

	-- Call connected callbacks
	for i = #self._connections, 1, -1 do
		local connection = self._connections[i]
		if connection._connected then
			task.spawn(connection._callback, ...)
		else
			table.remove(self._connections, i)
		end
	end
end

function Signal:Wait()
	table.insert(self._waiting, coroutine.running())
	return coroutine.yield()
end

function Signal:Destroy()
	table.clear(self._connections)
	table.clear(self._waiting)
end

return Signal
