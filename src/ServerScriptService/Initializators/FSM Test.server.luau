local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ServerScriptService = game:GetService('ServerScriptService')

local Shared = ReplicatedStorage:WaitForChild('Shared')
local Utilities = Shared:WaitForChild('Utilities')
local Modules = Utilities:WaitForChild('Modules')
local NetWork = Utilities:WaitForChild('NetWork')
local Components = ServerScriptService:WaitForChild('Components')

local Replicator = require(NetWork:WaitForChild('Replicator'))
local NPCComponents = require(Components:WaitForChild('NPCComponent'))
local EntitiesComponent = require(Components:WaitForChild('EntitiesStorage'))

local FSM = require(Modules:WaitForChild('FSM'))
local States = require(Utilities:WaitForChild('FSM_States').StateRegist)


local test = {}

task.wait(3)

local t = FSM.new(test,'Test')
local tz = States.Regist('Test')
local t2 = States.Regist('Test2')

tz.Name = '123'

t:AddState(States.Regist('Test'))
t:AddState(States.Regist('Test2'))

print(tz)
print(t)



for i=1,30 do
	
	t:Update(i,Vector3.one * math.random(-5,5))
	if i == 15 then
		t:ChangeState('Test2')
	end
	task.wait(1/10)
end

