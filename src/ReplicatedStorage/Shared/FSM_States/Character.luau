local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Shared = ReplicatedStorage:WaitForChild('Shared')
local Utilities = Shared:WaitForChild('Utilities')
local Modules = Utilities:WaitForChild('Modules')

local PlayerStates = {}

-- Idle State
PlayerStates.Idle = {
	Name = "Idle";
}

function PlayerStates.Idle.OnEnter(character, previousState)
	print(`[Idle] Entered from {previousState or "None"}`)
	local humanoid = character:FindFirstChildOfClass("Humanoid")
end

function PlayerStates.Idle.OnExit(character, nextState)
	print(`[Idle] Exiting to {nextState}`)
end

function PlayerStates.Idle.OnUpdate(character, deltaTime)
end

function PlayerStates.Idle.CanTransitionTo(character, nextState)
	return true
end

-- Walk/Run State
PlayerStates.Walk = {
	Name = "Walk";
}

function PlayerStates.Walk.OnEnter(character, previousState)
	print(`[Walk] Entered from {previousState or "None"}`)
	local humanoid = character:FindFirstChildOfClass("Humanoid")
end

function PlayerStates.Walk.OnExit(character, nextState)
	print(`[Walk] Exiting to {nextState}`)
end

function PlayerStates.Walk.OnUpdate(character, deltaTime)
	local humanoid = character:FindFirstChildOfClass("Humanoid")
end

function PlayerStates.Walk.CanTransitionTo(character, nextState)
	return true
end

-- Jump State
PlayerStates.Jump = {
	Name = "Jump";
}

function PlayerStates.Jump.OnEnter(character, previousState)
	print(`[Jump] Entered from {previousState or "None"}`)
	local humanoid = character:FindFirstChildOfClass("Humanoid")
end

function PlayerStates.Jump.OnExit(character, nextState)
	print(`[Jump] Exiting to {nextState}`)
end

function PlayerStates.Jump.OnUpdate(character, deltaTime)
end

function PlayerStates.Jump.CanTransitionTo(character, nextState)
	return true
end

-- Fall State
PlayerStates.Fall = {
	Name = "Fall";
}

function PlayerStates.Fall.OnEnter(character, previousState)
	print(`[Fall] Entered from {previousState or "None"}`)
end

function PlayerStates.Fall.OnExit(character, nextState)
	print(`[Fall] Exiting to {nextState}`)
end

function PlayerStates.Fall.OnUpdate(character, deltaTime)
end

function PlayerStates.Fall.CanTransitionTo(character, nextState)
	if nextState == "Jump" or nextState == "Landed" then
		return true
	end
	return false
end

-- Landed State
PlayerStates.Landed = {
	Name = "Landed";
}

function PlayerStates.Landed.OnEnter(character, previousState)
	print(`[Landed] Entered from {previousState or "None"}`)
	local humanoid = character:FindFirstChildOfClass("Humanoid")
end

function PlayerStates.Landed.OnExit(character, nextState)
	print(`[Landed] Exiting to {nextState}`)
end

function PlayerStates.Landed.OnUpdate(character, deltaTime)
end

function PlayerStates.Landed.CanTransitionTo(character, nextState)
	return nextState == "Idle" or nextState == "Walk"
end

return PlayerStates
