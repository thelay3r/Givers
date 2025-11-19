local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Shared = ReplicatedStorage:WaitForChild('Shared')
local Interfaces = Shared:WaitForChild('Interfaces')
local Templates = Shared:WaitForChild('Templates')

local FSM_Template = require(Templates:WaitForChild('FSM_Template'))

local FSM_Interfaces = require(Interfaces:WaitForChild('FSMInterfaces'))

type IFSM_Methods = FSM_Interfaces.FSM_Methods
type IFSM = FSM_Interfaces.IFSM

local FSM = {}
local Methods: IFSM_Methods = {}
FSM.__index = function(t,key)
	return Methods[key] or FSM[key]
end

function FSM.new(owner, initState) : IFSM
	
	local self: IFSM = setmetatable(FSM_Template(), FSM)
	
	self.Owner = owner
	self.CurrentState = initState
	return self
end

function Methods.Update(self: IFSM, deltaTime: number,...: any)
	if not self.States[self.CurrentState] then return end
	self.States[self.CurrentState].OnUpdate(deltaTime,...)
end

function Methods.AddState(self: IFSM,state: {})
	self.States[state.Name] = state
end
   
function Methods.ChangeState(self: IFSM,newState: string)
	if not self.States[newState] then return end
	local state = self.States[newState]
	state.OnEnter()
	self.CurrentState = state.Name
	
end


function Methods.On(self: IFSM, name: string, callback: ()->{})
	table.insert(self.Listeners[name], callback)
end

function Methods.Fire(self: IFSM, name: string, ...: any)
	if not self.Listeners[name] then return end
	
	for _,v in pairs(self.Listeners[name]) do
		v(...)
	end 
end


return FSM
