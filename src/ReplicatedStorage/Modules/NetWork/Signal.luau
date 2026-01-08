local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild('Shared')
local Modules = ReplicatedStorage:WaitForChild('Modules')
local Interfaces = Shared:WaitForChild('Interfaces')
local NetWork = Modules:WaitForChild('NetWork')

local SignalInerfaces = require(Interfaces:WaitForChild('SignalInterfaces'))

type Connection = SignalInerfaces.Connection
type ISignal = SignalInerfaces.ISignal

local Signal = {}
Signal.__index = Signal

function Signal.new(): Signal
	local self = setmetatable({}, Signal)
	self._connections = {} :: {[Connection]: (...any) -> ()}
	self._firing = false
	return self
end

function Signal:Connect(callback: (...any) -> ()): Connection
	assert(typeof(callback) == "function", "Signal:Connect expects a function")

	local connection = { Connected = true }
	
	function connection:Disconnect()
		if not self.Connected then return end
		self.Connected = false
		self._callback = nil
		self._owner._connections[self] = nil
	end

	connection._callback = callback
	connection._owner = self
	self._connections[connection] = callback

	return connection
end

function Signal:Once(callback: (...any) -> ()): Connection
	assert(typeof(callback) == "function", "Signal:Once expects a function")
	local connection
	connection = self:Connect(function(...)
		callback(...)
		connection:Disconnect()
	end)
	return connection
end

function Signal:Fire(...: any)
	self._firing = true
	for connection, callback in pairs(self._connections) do
		if connection.Connected then
			task.spawn(callback, ...)
		end
	end
	self._firing = false
end

function Signal:DisconnectAll()
	for connection in pairs(self._connections) do
		connection.Connected = false
	end
	table.clear(self._connections)
end


function Signal:Destroy()
	self:DisconnectAll()
	table.clear(self)
	setmetatable(self, nil)
end

return Signal
