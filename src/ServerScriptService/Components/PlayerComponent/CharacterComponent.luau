local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ServerScriptService = game:GetService("ServerScriptService")

local Shared = ReplicatedStorage:WaitForChild('Shared')
local Utilities = Shared:WaitForChild('Utilities')
local NetWork = Utilities:WaitForChild('NetWork')
local Interfaces = Shared:WaitForChild('Interfaces')
local Templates = Shared:WaitForChild('Templates')
local EntityComponent = require(ServerScriptService.Components.EntityComponent)
local PlayerInterfaces = require(Interfaces:WaitForChild('PlayerInterfaces'))

local SessionDataTemplate = require(Templates:WaitForChild('SessionData'))

local _Packets = require(NetWork:WaitForChild('Packets'))
local Replicator = require(NetWork:WaitForChild('Replicator'))

type IServerPlayerComponent = PlayerInterfaces.IServerPlayerComponent
type IServerPlayerMethods = PlayerInterfaces.IServerPlayerMethods

local Map = workspace:WaitForChild('Map')
local Entities = Map:WaitForChild('Entities')
local Players = Entities:WaitForChild('Players')

local CharacterComponent = {}

function CharacterComponent.SetupCharacter(self: IServerPlayerComponent)
	local player = self.Instance :: Player
	local character = player.Character :: Model
	if (not character) then character = player.CharacterAdded:Wait() end
	print(self)
	local Data = self.Replica.Data
	local Session = Data.Session

	local characterData = Session.CharacterData
	if (not characterData) then return end
	
	characterData.Character = character
	
	local humanoid: Humanoid = character:WaitForChild('Humanoid')
	local humanoidRootPart: BasePart = character:WaitForChild('HumanoidRootPart')
	
	characterData.Humanoid = humanoid
	characterData.HumanoidRootPart = humanoidRootPart
	
	characterData.Character.Parent = Players
	
	characterData.Character:SetAttribute('Id', Session.UserId)

	EntityComponent.AddToList(Session.UserId,self)
	print(Session)
	Replicator:GetRemote('BindableGlobal'):BindableFire('SetUp', Session.UserId)
	
	player.CharacterAdded:Connect(function(newCharacter)
		Session.StatusEffects = table.clone(SessionDataTemplate().StatusEffects)
		Session.Attributes = table.clone(SessionDataTemplate().Attributes)

		humanoid = newCharacter:WaitForChild('Humanoid')
		humanoidRootPart = newCharacter:WaitForChild('HumanoidRootPart')

		characterData.Character = newCharacter
		characterData.Humanoid = humanoid
		characterData.HumanoidRootPart = humanoidRootPart
		
		characterData.Character.Parent = Players
		
		characterData.Character:SetAttribute('Id', Session.UserId)
		characterData.Character:SetAttribute('Id', Session.UserId)
		
		Replicator:GetRemote('BindableGlobal'):BindableFire('SetUp', Session.UserId)
		
	end)
	
end

return CharacterComponent
