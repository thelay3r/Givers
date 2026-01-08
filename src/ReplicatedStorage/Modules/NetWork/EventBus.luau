

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Modules = ReplicatedStorage:WaitForChild('Modules')
local Shared = ReplicatedStorage:WaitForChild('Shared')
local Interfaces = Shared:WaitForChild('Interfaces')
local NetWork = Modules:WaitForChild('NetWork')
local Signal = require(NetWork:WaitForChild('Signal'))

local SignalInerfaces = require(Interfaces:WaitForChild('SignalInterfaces'))
local EventBusInterfaces = require(Interfaces:WaitForChild('EventBusInterfaces'))

type Connection = SignalInerfaces.Connection
type ISignal = SignalInerfaces.ISignal
type IEventBus = EventBusInterfaces.IEventBus

local Cache = {}

local EventBus = {}
EventBus.__index = EventBus

function EventBus.new(name: string): IEventBus
	if Cache[name] then return Cache[name] end
	local self = setmetatable({}, EventBus)
	self._events = {} :: {}
	Cache[name] = self
	return self
end


function EventBus:Subscribe(eventName: string, callback: (...any) -> ()): Connection
	assert(type(eventName) == "string", "Event name must be string")
	assert(type(callback) == "function", "Callback must be function")

	if not self._events[eventName] then
		self._events[eventName] = Signal.new()
	end
	return self._events[eventName]:Connect(callback)
end


function EventBus:Once(eventName: string, callback: (...any) -> ()): Connection
	assert(type(eventName) == "string", "Event name must be string")
	assert(type(callback) == "function", "Callback must be function")

	if not self._events[eventName] then
		self._events[eventName] = Signal.new()
	end
	return self._events[eventName]:Once(callback)
end


function EventBus:Fire(eventName: string, ...: any)
	local signal = self._events[eventName]
	if signal then
		signal:Fire(...)
	end
end


function EventBus:Unsubscribe(eventName: string, connection: Connection)
	if self._events[eventName] and connection then
		connection:Disconnect()
	end
end

function EventBus:Destroy()
	for _, signal in pairs(self._events) do
		signal:Destroy()
	end
	table.clear(self._events)
	setmetatable(self, nil)
end

return EventBus
