local ReplicatedStorage = game:GetService('ReplicatedStorage')

local Shared = ReplicatedStorage:WaitForChild('Shared')
local Utilites = Shared:WaitForChild('Utilities')
local Modules = Utilites:WaitForChild('Modules')
local TableHelper = require(Modules:WaitForChild('TableHelper'))

local SpeedData = 
	{
		Character = {};
		Humanoid = {};
		Data= 
		{
			CurrentSpeed= 0;
			LastSpeed= 0;
			DefaultSpeed= 0;

			Cache = {}
		}
	}

return function(): typeof(SpeedData)
	return TableHelper:DeepTableClone(SpeedData)
end