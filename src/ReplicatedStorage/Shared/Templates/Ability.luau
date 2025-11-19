local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ServerScriptService = game:GetService('ServerScriptService')

local Shared = ReplicatedStorage:WaitForChild('Shared')
local Utilites = Shared:WaitForChild('Utilities')
local Modules = Utilites:WaitForChild('Modules')
local TableHelper = require(Modules:WaitForChild('TableHelper'))
local Interfaces = Shared:WaitForChild('Interfaces')

local PassiveInterfaces = require(Interfaces:WaitForChild('PassiveInterfaces'))

type IPassiveComponents = PassiveInterfaces.IPassive

local AbilityData = {
	
	Name = 'AbilityName';
	Key = Enum.KeyCode;
	
	StartTime = 0;
	LastUsed = os.clock();
	Cooldown = 1;
	
	Duration = 1;
	MinDuration = 1;
	
	OwnerId = "1";
	
	IsHolded = false;
	IsBypass = false;
	IsActive = false;
	
	Functions = {
		StartStatus = false;
		EndStatus = false;
		
		Start = function() end;
		SpecialStart = function() end;
		End = function() end;
		
	};
	Blacklist = {};
	Instances = {};
	Tasks = {};
	Threads = {};
	
}

return function(): typeof(AbilityData)
	return TableHelper:DeepTableClone(AbilityData)
end