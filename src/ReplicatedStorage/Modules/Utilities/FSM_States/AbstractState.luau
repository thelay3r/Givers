local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Modules = ReplicatedStorage:WaitForChild('Modules')
local Utilities = Modules:WaitForChild('Utilities')
local TableHelper = require(Utilities:WaitForChild('TableHelper'))

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