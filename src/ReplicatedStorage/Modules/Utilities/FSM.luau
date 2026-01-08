local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Shared = ReplicatedStorage:WaitForChild('Shared')
local Interfaces = Shared:WaitForChild('Interfaces')
local Templates = Shared:WaitForChild('Templates')

local FSM_Template = require(Templates:WaitForChild('FSM_Template'))
local FSM_Interfaces = require(Interfaces:WaitForChild('FSMInterfaces'))

type IFSM_Methods = FSM_Interfaces.FSM_Methods
type IFSM = FSM_Interfaces.IFSM

local FSM = {}
local Methods = {} :: IFSM_Methods
FSM.__index = function(t, key)
	return Methods[key] or FSM[key]
end

function FSM.new(owner, initState): IFSM
	local self = setmetatable(FSM_Template(), FSM) :: any & IFSM

	self.Owner = owner
	self.CurrentState = initState
	self.PreviousState = nil
	return self
end

function Methods.Update(self: IFSM, deltaTime: number, ...: any)
	if not self.States[self.CurrentState :: string] then return end
	local currentState = self.States[self.CurrentState :: string]
	if currentState.OnUpdate then
		currentState.OnUpdate(self.Owner, deltaTime, ...)
	end
end

function Methods.AddState(self: IFSM, state)
	self.States[state.Name] = state
end

function Methods.ChangeState(self: IFSM, newStateName: string)
	if not self.States[newStateName] then 
		warn(`[FSM] State "{newStateName}" not found`)
		return false
	end

	if self.CurrentState == newStateName then return false end

	local newState = self.States[newStateName]
	local oldState = self.States[self.CurrentState :: string]

	-- Проверка возможности перехода
	if oldState and oldState.CanTransitionTo then
		if not oldState.CanTransitionTo(self.Owner, newStateName) then
			return false
		end
	end

	-- OnExit для текущего состояния
	if oldState and oldState.OnExit then
		oldState.OnExit(self.Owner, newStateName)
	end

	self.PreviousState = self.CurrentState
	self.CurrentState = newStateName

	-- OnEnter для нового состояния
	if newState.OnEnter then
		newState.OnEnter(self.Owner, self.PreviousState)
	end

	-- Fire событие смены состояния
	self:Fire("StateChanged", self.PreviousState, self.CurrentState)

	return true
end

function Methods.GetCurrentState(self: IFSM)
	return self.CurrentState
end

function Methods.GetPreviousState(self: IFSM): string?
	return self.PreviousState
end

function Methods.On(self: IFSM, name: string, callback: () -> {})
	if not self.Listeners[name] then
		self.Listeners[name] = {}
	end
	table.insert(self.Listeners[name], callback)
end

function Methods.Fire(self: IFSM, name: string, ...: any)
	if not self.Listeners[name] then return end

	for _, v in pairs(self.Listeners[name]) do
		v(...)
	end
end

return FSM
