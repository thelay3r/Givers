local ReplicatedStorage = game:GetService('ReplicatedStorage')

local Shared = ReplicatedStorage:WaitForChild('Shared')
local Utilities = Shared:WaitForChild('Utilities')
local UtilModules = Utilities:WaitForChild('Modules')
local Templates = Shared:WaitForChild('Templates')
local Interfaces = Shared:WaitForChild('Interfaces')

local LocalPlayerInterfaces = require(Interfaces:WaitForChild('LocalPlayerInterfaces'))
local ClientDataTemplate = require(Templates:WaitForChild('ClientData'))
local TaskManager = require(UtilModules:WaitForChild('TaskManager'))
local Animator = require(UtilModules:WaitForChild('Animator'))

local LocalCharacterComponent = {}

function LocalCharacterComponent.SetupCharacter(self: LocalPlayerInterfaces.IClientPlayerComponent)

	local player: Player = self.Instance
	local character: Model = player.Character
	if (not character) then character = player.CharacterAdded:Wait() end

	local characterData = self.ClientData.CharacterData
	if (not characterData) then return end
	
	
	
	characterData.Character = character

	local humanoid: Humanoid = character:WaitForChild('Humanoid')
	local humanoidRootPart: BasePart = character:WaitForChild('HumanoidRootPart')
	humanoid.WalkSpeed = 12

	characterData.Humanoid = humanoid
	characterData.HumanoidRootPart = humanoidRootPart

	Animator.InitAnimations(self)
	self:InitDirection()
	TaskManager:CreateThread(self,'Jumping',humanoid.Jumping:Connect(function(active)
		--print(self.MainBus)
		if not active then return end
		self.Buses.Character:Fire('OnJump')
	end))

	player.CharacterAdded:Connect(function(newCharacter)

		humanoid = newCharacter:FindFirstChildOfClass('Humanoid')
		humanoidRootPart = newCharacter:FindFirstChild('HumanoidRootPart')
		
		humanoid.WalkSpeed = 12

		
		characterData.Character = newCharacter
		characterData.Humanoid = humanoid
		characterData.HumanoidRootPart = humanoidRootPart
		
		TaskManager:CancelAllThreads(self)
		TaskManager:CancelAllTasks(self)
		table.clear(self.ClientData.PressedKeys)
		table.clear(self.ClientData.Ticks)
		
		
		self:ReplicateKeys()
		self:InitDirection()
		Animator.InitAnimations(self)		
	end)
end

return LocalCharacterComponent
