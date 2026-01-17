local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
if RunService:IsClient() then return {} end

local ServerScriptService = game:GetService("ServerScriptService")
local Bricks = ReplicatedStorage.Bricksv2

local _Components = Bricks:WaitForChild('Components')
local Data = Bricks:WaitForChild('Data')
local _Registries = Data:WaitForChild('Registries')
local EntityComponent = require(ServerScriptService.Components.EntityComponent)
local EntityInterfaces = require(ReplicatedStorage.Shared.Interfaces.EntityInterfaces)
local AssetsHelper = require(ReplicatedStorage.Shared.Utilities.Modules.AssetsHelper)
local Enums = require(ReplicatedStorage.Shared.Utilities.Modules.Enums)
local HitboxClass = require(ReplicatedStorage.Shared.Utilities.Modules.HitboxClass)
local Ragdoll = require(ReplicatedStorage.Shared.Utilities.Modules.Ragdoll)
local TaskManager = require(ReplicatedStorage.Shared.Utilities.Modules.TaskManager)
local Registry = require(_Components.Registry)


local registry = Registry.new()

local GripTimer = 2.75

registry:Register('GripDown', function(self,node)
	local Owner = self.Tags['Owner'] :: EntityInterfaces.IEntityComponent
	return Owner.SessionData.StatusEffects.Carry
end)
registry:Register('UpGrip', function(self,node)
	local Owner = self.Tags['Owner'] :: EntityInterfaces.IEntityComponent
	return not Owner.SessionData.StatusEffects.Carry
end)

registry:Register('CheckGrip', function(self,node): any  
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
			Name = 'Action.Grip';
			Config = {
				Target = Entity;
			}
		})
	end)

end)

registry:Register('Grip', function(self,node)
	local Owner = self.Tags['Owner'] :: EntityInterfaces.IEntityComponent
	local Victim = node.Config.Target :: EntityInterfaces.IEntityComponent

	local VInstance = Victim.Instance :: Player
	local OInstance = Owner.Instance :: Player

	Owner.GripbedBody = Victim

	Victim:SetStatusEffect('InGrip',true)
	Owner:SetStatusEffect('Carry',true)

	Victim:SetStatusEffect('CanBodySimulation',false)
	Victim:SetStatusEffect('CanAutoRotate',false)

	Owner:SetStatusEffect('CanBodySimulation',false)
	Owner:SetStatusEffect('CanAutoRotate',false)

	Victim.SpeedController:Amplify({
        Name = 'Grip';
        Percent = -100;
        UseBaseSpeed = false;
        Priority = 20;
    })

	Ragdoll:Disabled(VInstance.Character)

	local Weld = Instance.new('Weld') :: Weld

	Weld.Part0 = OInstance.Character.PrimaryPart
	Weld.Part1 = VInstance.Character.PrimaryPart

	Weld.Parent = Weld.Part0

	local action = if Owner.SessionData.CurrentEquipped ~= 'none' then Owner.SessionData.CurrentEquipped else 'Fists'

	TaskManager:CreateTask(OInstance, 'Grip', GripTimer, function(a0)  
		self:Execute({
			Name = 'Action.GripDone'
		})
		self:Execute({
			Name = 'Action.UnGrip'
		})
	end)

	self:Execute({
		Name = 'Network.PlayBindableEvent';
		Config = {
			EventName = 'PlayVFX';
			EventData = {
                Player = OInstance;
				Victim = VInstance;
                VFXType = action..'.Grip';
				State = 'Start';
			}
		}
	})
	self:Execute({
		Name = 'Network.PlayRemoteEvent';
		Config = {
			EventType = Enums.EventType.Close;
			Event = 'VFX';
			EventName = 'PlayVFX';
			EventData = {
				Player = OInstance;
				Victim = VInstance;
				VFXType = action..'.Grip';
				State = 'LocaleStart';
			};
		}
	})

end)

registry:Register('GripDone', function(self,node): any  
	local Owner = self.Tags['Owner'] :: EntityInterfaces.IEntityComponent
	local Victim = Owner.GripbedBody :: EntityInterfaces.IEntityComponent

	local VInstance = Victim.Instance :: Player
	local OInstance = Owner.Instance :: Player

	Victim:TakeDamage(1e10,true)
end)

registry:Register('UnGrip', function(self,node)
	local Owner = self.Tags['Owner'] :: EntityInterfaces.IEntityComponent
	local Victim = Owner.GripbedBody :: EntityInterfaces.IEntityComponent

	local VInstance = Victim.Instance :: Player
	local OInstance = Owner.Instance :: Player

	TaskManager:CancelTask(OInstance, 'Grip')


	Ragdoll:Enabled(VInstance.Character)

	OInstance.Character.PrimaryPart:FindFirstChildOfClass('Weld'):Destroy()

	Owner.GripbedBody = nil

	Owner:SetStatusEffect('Carry',false)
	Victim:SetStatusEffect('InGrip',false)

	Victim:SetStatusEffect('CanBodySimulation',true)
	Victim:SetStatusEffect('CanAutoRotate',true)

	Owner:SetStatusEffect('CanBodySimulation',true)
	Owner:SetStatusEffect('CanAutoRotate',true)

	local action = if Owner.SessionData.CurrentEquipped ~= 'none' then Owner.SessionData.CurrentEquipped else 'Fists'


	self:Execute({
		Name = 'Network.PlayBindableEvent';
		Config = {
			EventName = 'PlayVFX';
			EventData = {
                Player = OInstance;
				Victim = VInstance;
                VFXType = action..'.Grip';
				State = 'Stop';
			}
		}
	})

	self:Execute({
		Name = 'Network.PlayRemoteEvent';
		Config = {
			EventType = Enums.EventType.Close;
			Event = 'VFX';
			EventName = 'PlayVFX';
			EventData = {
				Player = OInstance;
				Victim = VInstance;
				VFXType = action..'.Grip';
				State = 'LocaleStop';
			};
		}
	})
end)

return registry