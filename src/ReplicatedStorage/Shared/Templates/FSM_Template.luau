local ReplicatedStorage = game:GetService('ReplicatedStorage')

local Shared = ReplicatedStorage:WaitForChild('Shared')
local Utilites = Shared:WaitForChild('Utilities')
local Modules = Utilites:WaitForChild('Modules')
local TableHelper = require(Modules:WaitForChild('TableHelper'))


local FSMData = {
	
	Owner = {};
	CurrentState = 'none';
	States = {};
	Listeners = {};
	
}

return function(): typeof(FSMData)
	return TableHelper:DeepTableClone(FSMData)
end