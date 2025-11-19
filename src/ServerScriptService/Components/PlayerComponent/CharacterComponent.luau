local ReplicatedStorage = game:GetService('ReplicatedStorage')

local Shared = ReplicatedStorage:WaitForChild('Shared')
local Utilities = Shared:WaitForChild('Utilities')
local NetWork = Utilities:WaitForChild('NetWork')
local Interfaces = Shared:WaitForChild('Interfaces')
local Templates = Shared:WaitForChild('Templates')
local PlayerInterfaces = require(Interfaces:WaitForChild('PlayerInterfaces'))

local SessionDataTemplate = require(Templates:WaitForChild('SessionData'))

local Packets = require(NetWork:WaitForChild('Packets'))
local Replicator = require(NetWork:WaitForChild('Replicator'))

type IPlayerComponent = PlayerInterfaces.IPlayerClientComponent
type IServerPlayerComponent = PlayerInterfaces.IServerPlayerComponent
type IServerPlayerMethods = PlayerInterfaces.IServerPlayerMethods

local Map = workspace:WaitForChild('Map')
local Entities = Map:WaitForChild('Entities')
local Players = Entities:WaitForChild('Players')

local CharacterComponent = {}

function CharacterComponent.SetupCharacter(self: IServerPlayerComponent)
	local player: Player = self.Instance
	local character: Model = player.Character
	if (not character) then character = player.CharacterAdded:Wait() end
	
	local characterData = self.SessionData.CharacterData
	if (not characterData) then return end
	
	characterData.Character = character
	
	local humanoid: Humanoid = character:WaitForChild('Humanoid')
	local humanoidRootPart: BasePart = character:WaitForChild('HumanoidRootPart')
	
	characterData.Humanoid = humanoid
	characterData.HumanoidRootPart = humanoidRootPart
	
	characterData.Character.Parent = Players
	
	characterData.Character:SetAttribute('Id', self.SessionData.UserId)
	
	Replicator:GetRemote('BindableGlobal'):BindableFire('SetUp', self.SessionData.UserId)
	
	player.CharacterAdded:Connect(function(newCharacter)
		self.SessionData.StatusEffects = table.clone(SessionDataTemplate().StatusEffects)
		self.SessionData.Attributes = table.clone(SessionDataTemplate().Attributes)

		humanoid = newCharacter:WaitForChild('Humanoid')
		humanoidRootPart = newCharacter:WaitForChild('HumanoidRootPart')

		characterData.Character = newCharacter
		characterData.Humanoid = humanoid
		characterData.HumanoidRootPart = humanoidRootPart
		
		characterData.Character.Parent = Players
		
		characterData.Character:SetAttribute('Id', self.SessionData.UserId)
		characterData.Character:SetAttribute('Id', self.SessionData.UserId)
		
		Replicator:GetRemote('BindableGlobal'):BindableFire('SetUp', self.SessionData.UserId)
		
	end)
	
end

return CharacterComponent
