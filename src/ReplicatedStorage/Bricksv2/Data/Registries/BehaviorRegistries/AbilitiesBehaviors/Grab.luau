local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
if RunService:IsClient() then return {} end

local ServerScriptService = game:GetService("ServerScriptService")
local Bricks = ReplicatedStorage.Bricksv2

local _Components = Bricks:WaitForChild('Components')
local Data = Bricks:WaitForChild('Data')
local _Registries = Data:WaitForChild('Registries')
local EntitiesStorage = require(ServerScriptService.Components.EntitiesStorage)
local EntityComponent = require(ServerScriptService.Components.EntityComponent)
local EntityInterfaces = require(ReplicatedStorage.Shared.Interfaces.EntityInterfaces)
local AssetsHelper = require(ReplicatedStorage.Shared.Utilities.Modules.AssetsHelper)
local HitboxClass = require(ReplicatedStorage.Shared.Utilities.Modules.HitboxClass)
local Ragdoll = require(ReplicatedStorage.Shared.Utilities.Modules.Ragdoll)
local TaskManager = require(ReplicatedStorage.Shared.Utilities.Modules.TaskManager)
local Registry = require(_Components.Registry)


local registry = Registry.new()

registry:Register('GrabDown', function(self,node)
	local Owner = self.Tags['Owner'] :: EntityInterfaces.IEntityComponent
	print(Owner.SessionData.StatusEffects.Carry)
	return Owner.SessionData.StatusEffects.Carry
end)
registry:Register('UpGrab', function(self,node)
	local Owner = self.Tags['Owner'] :: EntityInterfaces.IEntityComponent
	return not Owner.SessionData.StatusEffects.Carry
end)

registry:Register('CheckGrab', function(self,node): any  
	local Owner = self.Tags['Owner'] :: EntityInterfaces.IEntityComponent
	local _Instance = Owner.Instance :: Player
	local Character = _Instance.Character :: Model

	node.Config['Victim'] = false

	local HitBox = HitboxClass.new('WeldedBox', 
	{
		IgnoreCharacters = {Character};
		velocityPrediction = true;
		root = Character:FindFirstChild('HumanoidRootPart');
		size = Vector3.new(6,6,6);
		debug = false;
		duration = .3;
	})
	HitBox:Start()
	HitBox.OnHit:Connect(function(_Character: Model)
		local Entity = EntityComponent.GetEntity(_Character:GetAttribute('Id')) :: EntityInterfaces.IEntityComponent
		if (not Entity) or (node.Config['Victim']) then return end
		local ESessionData = Entity.SessionData
		local EStatusEffects = ESessionData.StatusEffects
		if not EStatusEffects.KnockDown then return end

		
		node.Config['Victim'] = Entity
		self:Execute({
			Name = 'Action.Grab';
			Config = {
				Target = Entity;
			}
		})
	end)

end)

registry:Register('Grab', function(self,node)
	local Owner = self.Tags['Owner'] :: EntityInterfaces.IEntityComponent
	local Victim = node.Config.Target :: EntityInterfaces.IEntityComponent

	local VInstance = Victim.Instance :: Player
	local OInstance = Owner.Instance :: Player

	Ragdoll:Disabled(VInstance.Character)

	VInstance.Character.Humanoid.PlatformStand = true

	for _,v in pairs(VInstance.Character:GetDescendants()) do
		if v:IsA('BasePart') then
			v.CanCollide = false
			v.Massless = true
		end
	end

	local Weld = Instance.new('Weld') :: Weld

	Weld.Part0 = OInstance.Character.Torso
	Weld.Part1 = VInstance.Character.PrimaryPart

	Weld.Parent = Weld.Part0

	Owner:SetStatusEffect('Carry',true)

	self:Execute({
		Name = 'Network.PlayBindableEvent';
		Config = {
			EventName = 'PlayVFX';
			EventData = {
                Player = OInstance;
				Victim = VInstance;
                VFXType = 'Grab.Carry';
				State = 'Carry';
			}
		}
	})

end)

registry:Register('UnGrab', function(self,node)
	local Owner = self.Tags['Owner'] :: EntityInterfaces.IEntityComponent
	local Victim = self.Tags['CheckGrab']['Victim'] :: EntityInterfaces.IEntityComponent

	local VInstance = Victim.Instance :: Player
	local OInstance = Owner.Instance :: Player

	Ragdoll:Enabled(VInstance.Character)

	OInstance.Character.Torso:FindFirstChildOfClass('Weld'):Destroy()

	

	Owner:SetStatusEffect('Carry',false)

	self:Execute({
		Name = 'Network.PlayBindableEvent';
		Config = {
			EventName = 'PlayVFX';
			EventData = {
                Player = OInstance;
				Victim = VInstance;
                VFXType = 'Grab.Carry';
				State = 'UnCarry';
			}
		}
	})

end)

return registry