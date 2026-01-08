local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Modules = ReplicatedStorage:WaitForChild('Modules')
local Utilities = Modules:WaitForChild('Utilities')
local FsmState = Utilities:WaitForChild('FSM_States')
local Abstract = require(FsmState:WaitForChild('AbstractState'))

local State = Abstract()
State.Name = script.Name

State.OnEnter = function()
	--print('Test State Entered')
end

State.OnUpdate = function(dt)
	--print(dt,'Updated Test')
end

return State
