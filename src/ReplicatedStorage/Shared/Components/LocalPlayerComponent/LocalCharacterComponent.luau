local ReplicatedStorage = game:GetService('ReplicatedStorage')

local Shared = ReplicatedStorage:WaitForChild('Shared')
local Utilities = Shared:WaitForChild('Utilities')
local UtilModules = Utilities:WaitForChild('Modules')
local Interfaces = Shared:WaitForChild('Interfaces')

local LocalPlayerInterfaces = require(Interfaces:WaitForChild('LocalPlayerInterfaces'))
local TaskManager = require(UtilModules:WaitForChild('TaskManager'))
local Animator = require(UtilModules:WaitForChild('Animator'))
local FSM_Controllers = Shared:WaitForChild('FSM_Controllers')

local CharacterFSM = require(FSM_Controllers:WaitForChild('CharacterFSM'))
local LocalCharacterComponent = {}

function LocalCharacterComponent.SetupCharacter(self: LocalPlayerInterfaces.IClientPlayerComponent)

	local player: Player = self.Instance
	local character = player.Character :: Model
	if (not character) then character = player.CharacterAdded:Wait() end

	local characterData = self.ClientData.CharacterData
	if (not characterData) then return end
	
	characterData.Character = character

	local humanoid = character:WaitForChild('Humanoid') :: Humanoid
	local humanoidRootPart = character:WaitForChild('HumanoidRootPart') :: BasePart
	humanoid.UseJumpPower = true

	characterData.Humanoid = humanoid
	characterData.HumanoidRootPart = humanoidRootPart

	Animator.InitAnimations(self)
	self:InitDirection()
	
	local function jumpConnection(active)
		if not active then return end
		self.Buses.Character:Fire('OnJump')
	end

	local function healthConnection()
		self.Buses.Character:Fire('OnHealthChanged')
	end

	local function initializeThreads()
		TaskManager:CreateThread(self,'Jumping',characterData.Humanoid.Jumping:Connect(jumpConnection))
		TaskManager:CreateThread(self,'HealthChanged',characterData.Humanoid.HealthChanged:Connect(healthConnection))
	end

	initializeThreads()

	characterData.Humanoid.Health = 80

	player.CharacterAdded:Connect(function(newCharacter)

		humanoid = newCharacter:FindFirstChildOfClass('Humanoid')
		humanoidRootPart = newCharacter:FindFirstChild('HumanoidRootPart')
		
		humanoid.WalkSpeed = 12
		humanoid.UseJumpPower = true
		
		characterData.Character = newCharacter
		characterData.Humanoid = humanoid
		characterData.HumanoidRootPart = humanoidRootPart
		
		TaskManager:CancelAllThreads(self)
		TaskManager:CancelAllTasks(self)
		table.clear(self.ClientData.PressedKeys)
		table.clear(self.ClientData.Ticks)
		
		--бога нет.
		self:ReplicateKeys()
		self:InitDirection()
		Animator.InitAnimations(self)

		initializeThreads()

	end)
end

return LocalCharacterComponent
