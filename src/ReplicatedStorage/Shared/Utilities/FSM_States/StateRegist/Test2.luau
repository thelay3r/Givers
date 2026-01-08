local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Shared = ReplicatedStorage:WaitForChild('Shared')
local Utilities = Shared:WaitForChild('Utilities')
local Modules = Utilities:WaitForChild('Modules')
local FsmState = Utilities:WaitForChild('FSM_States')
local Abstract = require(FsmState:WaitForChild('AbstractState'))

local State = Abstract()
State.Name = script.Name

State.OnEnter = function()
	--print('Test State Entered')
end

State.OnUpdate = function(dt,Vector)
	--print(dt,'Updated Test2')
	--print(Vector)
end

return State
