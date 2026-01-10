local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ServerScriptService = game:GetService("ServerScriptService")

local Shared = ReplicatedStorage:WaitForChild('Shared')
local Utilities = Shared:WaitForChild('Utilities')
local NetWork = Utilities:WaitForChild('NetWork')
local Interfaces = Shared:WaitForChild('Interfaces')
local Templates = Shared:WaitForChild('Templates')
local RunTimeList = require(ReplicatedStorage.Bricksv2.Data.Abilities.RunTimeList)
local EntityInterfaces = require(ReplicatedStorage.Shared.Interfaces.EntityInterfaces)
local TaskManager = require(ReplicatedStorage.Shared.Utilities.Modules.TaskManager)
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

local RunTimeBlackList = RunTimeList
local HealthRate = 3

local function CheckBlackList(Status)
	for i,v in pairs(RunTimeBlackList) do
		if Status[i] == true then return false end
	end
	return true
end

local function HealthRegen(self: EntityInterfaces.IEntityComponent)
	
	local HealthScript = self.Instance.Character:WaitForChild('Health')
	if HealthScript then HealthScript:Destroy() end

	TaskManager:CreateTask(self.Instance, 'Health', 0, function(a0)  
		local SessionData = self.SessionData
		local Attributes = SessionData.Attributes
		local StatusEffects = SessionData.StatusEffects

		local percent = 5
		while task.wait(HealthRate) do
			if not CheckBlackList(StatusEffects) then continue end
			local MaxHealth: number = Attributes.MaxHealth
			local ToHealth = MaxHealth * percent / 100
			self:TakeHealth(math.abs(ToHealth) + Attributes.AdditionalHealth)
		end
	end)

end

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

	Replicator:GetRemote('BindableGlobal'):BindableFire('SetUp', Session.UserId)
	
	for _,v in pairs(characterData.Character:GetDescendants()) do
		 if v:IsA('BasePart') then
			v.CollisionGroup = 'Player'
		end
	end

	HealthRegen(self)
	player.CharacterAdded:Connect(function(newCharacter)
		TaskManager:CancelAllTasks(self)
		TaskManager:CancelAllTasks(self.Instance)

		TaskManager:CancelAllThreads(self)
		TaskManager:CancelAllThreads(self.Instance)

		
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
		
		
		for _,v in pairs(characterData.Character:GetDescendants()) do
			if v:IsA('BasePart') then
				v.CollisionGroup = 'Player'
			end
		end

		Replicator:GetRemote('BindableGlobal'):BindableFire('SetUp', Session.UserId)
		

		HealthRegen(self)
	end)
	
end

return CharacterComponent
