local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Shared = ReplicatedStorage:WaitForChild('Shared')
local Interfaces = Shared:WaitForChild('Interfaces')

local AbilityInterfaces = require(Interfaces:WaitForChild('AbilityInerfaces'))

local CFG: AbilityInterfaces.IAbilityConfig = {
	Type = 'Hold';

	Duration = 0;
	MinDuration = 0;

	Cooldown = 1;

	Key = Enum.KeyCode.E;

	Blacklist = 
		{
			'Click'
		};
}

return CFG