local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ServerScriptService = game:GetService('ServerScriptService')
local RunService = game:GetService('RunService')

local Shared = ReplicatedStorage:WaitForChild('Shared')
local Utilites = Shared:WaitForChild('Utilities')
local Modules = Utilites:WaitForChild('Modules')
local TableHelper = require(Modules:WaitForChild('TableHelper'))
local ServerComponents = ServerScriptService:WaitForChild('Components')
local Interfaces = Shared:WaitForChild('Interfaces')

local FSMInterfaces = require(Interfaces:WaitForChild('FSMInterfaces'))

local FSMData = {
	
	Owner = {};
	CurrentState = 'none';
	States = {};
	Listeners = {};
	
}

return function(): typeof(FSMData)
	return TableHelper:DeepTableClone(FSMData)
end