local ReplicatedStorage = game:GetService('ReplicatedStorage')

local Shared = ReplicatedStorage:WaitForChild('Shared')
local Utilities = Shared:WaitForChild('Utilities')
local NetWork = Utilities:WaitForChild('NetWork')
local Interfaces = Shared:WaitForChild('Interfaces')

local NPCInterfaces = require(Interfaces:WaitForChild("NPCInterfaces"))
local Replicator = require(NetWork:WaitForChild('Replicator'))

local Map = workspace:WaitForChild('Map')
local Entities = Map:WaitForChild('Entities')
local NPCs = Entities:WaitForChild('NPCs')

local VFXReplica = require(NetWork:WaitForChild('VfxReplica'))

local CharacterComponent = {}

function CharacterComponent.SetupCharacter(self:any & NPCInterfaces.INPCComponent, Model: Model): NPCInterfaces.INPCComponent
	local character = Model:Clone()
	character.Parent = workspace.Map.Entities.NPCs
	
	local SessionData = self.SessionData
	local CharacterData = SessionData.CharacterData
	
	local humanoid: Humanoid = character:FindFirstChildOfClass('Humanoid')
	local humanoidRootPart: BasePart = character:FindFirstChild('HumanoidRootPart')
	
	CharacterData.Character = character
	CharacterData.Humanoid = humanoid
	CharacterData.HumanoidRootPart = humanoidRootPart
	
	CharacterData.Character.Parent = NPCs.Neutral
	
	CharacterData.Character:SetAttribute("Id", self.SessionData.UserId)
	self.Instance = {
		UserId = self.SessionData.UserId;
		Character = CharacterData.Character;
	}
	for _,v in pairs(CharacterData.Character:GetDescendants()) do
		if v:IsA('BasePart') then
			v.CollisionGroup = "NPC"
		end
	end
	VFXReplica:Fire(self.SessionData.CharacterData.HumanoidRootPart, math.huge, 'ReplicateNPCAnimations', {
		NPC = CharacterData.Character
	})
	
	humanoid.Died:Once(function()
		task.wait(2)
		CharacterData.Character:Destroy()
		self:Destroy()
		
	end)
	
	return self
end

return CharacterComponent
