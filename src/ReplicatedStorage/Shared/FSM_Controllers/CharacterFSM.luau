local ReplicatedStorage = game:GetService('ReplicatedStorage')

local Shared = ReplicatedStorage:WaitForChild('Shared')
local Utilities = Shared:WaitForChild('Utilities')
local Modules = Utilities:WaitForChild('Modules')

local FSM = require(Modules:WaitForChild('FSM'))
local CharacterStates = require(Shared:WaitForChild('FSM_States'):WaitForChild('Character'))

local CharacterFSMController = {}
CharacterFSMController.__index = CharacterFSMController

local STATE_MAPPING = {
	[Enum.HumanoidStateType.Running] = function(humanoid: Humanoid)
		return humanoid.MoveDirection.Magnitude > 0.01 and "Walk" or "Idle"
	end;
	[Enum.HumanoidStateType.Jumping] = "Jump";
	[Enum.HumanoidStateType.Freefall] = "Fall";
	[Enum.HumanoidStateType.Landed] = "Landed";
	[Enum.HumanoidStateType.Swimming] = "Walk"; 
	[Enum.HumanoidStateType.Climbing] = "Walk";
}

function CharacterFSMController.new(character)
	local self = setmetatable({}, CharacterFSMController)

	self.Character = character
	self.Humanoid = character:WaitForChild("Humanoid")

	self.FSM = FSM.new(character, "Idle")

	self.FSM:AddState(CharacterStates.Idle)
	self.FSM:AddState(CharacterStates.Walk)
	self.FSM:AddState(CharacterStates.Jump)
	self.FSM:AddState(CharacterStates.Fall)
	self.FSM:AddState(CharacterStates.Landed)
	self:ConnectStateChanged()

	self:StartUpdateLoop()
	print(`[CharacterFSM] Initialized for {character.Name}`)

	return self
end

function CharacterFSMController:ConnectStateChanged()
	self.StateChangedConnection = self.Humanoid.StateChanged:Connect(function(oldState, newState)
		self:OnHumanoidStateChanged(oldState, newState)
	end)
end

function CharacterFSMController:OnHumanoidStateChanged(oldHumanoidState, newHumanoidState)
	local mappedState = STATE_MAPPING[newHumanoidState]

	if not mappedState then 
		warn(`[CharacterFSM] Unmapped HumanoidStateType: {newHumanoidState}`)
		return 
	end

	if type(mappedState) == "function" then
		mappedState = mappedState(self.Humanoid)
	end

	local success = self.FSM:ChangeState(mappedState)

	if success then
		print(`[CharacterFSM] State changed: {oldHumanoidState} -> {newHumanoidState} (FSM: {mappedState})`)
	else
		warn(`[CharacterFSM] Failed to change state to {mappedState}`)
	end
end

function CharacterFSMController:StartUpdateLoop()
	local RunService = game:GetService("RunService")

	self.UpdateConnection = RunService.Heartbeat:Connect(function(deltaTime)
		self.FSM:Update(deltaTime)
	end)
end

function CharacterFSMController:Destroy()
	if self.StateChangedConnection then
		self.StateChangedConnection:Disconnect()
	end

	if self.UpdateConnection then
		self.UpdateConnection:Disconnect()
	end

	print(`[CharacterFSM] Destroyed for {self.Character.Name}`)
end

return CharacterFSMController
