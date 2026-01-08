local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Shared = ReplicatedStorage:WaitForChild('Shared')
local Utilities = Shared:WaitForChild('Utilities')
local Modules = Utilities:WaitForChild('Modules')
local TableHelper = require(Modules:WaitForChild('TableHelper'))

local AbstractState = 
	{
		Name = '';
	}


function AbstractState.OnEnter() end
function AbstractState.OnExit() end
function AbstractState.OnChange() end
function AbstractState.OnUpdate() end



return function()
	return setmetatable(TableHelper:DeepTableClone(AbstractState) :: typeof(AbstractState), AbstractState)
end