local ReplicatedStorage = game:GetService('ReplicatedStorage')
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
local Bricks = ReplicatedStorage:WaitForChild('Bricksv2')
if RunService:IsClient() then return {} end

local Components = Bricks:WaitForChild('Components')
local _Data = Bricks:WaitForChild('Data')

local EntityInterfaces = require(ReplicatedStorage.Shared.Interfaces.EntityInterfaces)
local EntityComponent = require(ServerScriptService.Components.EntityComponent)
local PlayerInterfaces = require(ReplicatedStorage.Shared.Interfaces.PlayerInterfaces)
local Enums = require(ReplicatedStorage.Shared.Utilities.Modules.Enums)
local isSimilar = require(ReplicatedStorage.Shared.Utilities.Modules.Fusion.Utility.isSimilar)
local HitboxClass = require(ReplicatedStorage.Shared.Utilities.Modules.HitboxClass)
local TaskManager = require(ReplicatedStorage.Shared.Utilities.Modules.TaskManager)
local _TaskManager = require(ReplicatedStorage.Shared.Utilities.Modules.TaskManager)
local Fists = require(ReplicatedStorage.Shared.VFXs.Replica.VFXs.Fists)
local Registry = require(Components:WaitForChild('Registry'))



local EntityRegistry = Registry.new()

local function creteTrails(self,Victim,Part)
		self:Execute({
			Name = 'Network.PlayRemoteEvent';
			Config = {
				EventType = Enums.EventType.Close;
				Event = 'VFX';
				EventName = 'PlayVFX';
				EventData = {
					Player = Victim.Instance;
					VFXType = 'Effects.Trail';
					State = 'Start';
					Pack = 'Movement';
					AbilityName = 'Dash';
					LifeTime = 3;
					Parent = Part;
				};
			}
		})
end

EntityRegistry:Register('FistsBackStab', function(self, node)  
	local Victim = node.Config.Victim :: EntityInterfaces.IEntityComponent
	local Owner = self.Tags['Owner'] :: EntityInterfaces.IEntityComponent

	local VictimCharacter = Victim.Instance.Character :: Model
	local OwnerCharacter = Owner.Instance.Character :: Model

	local VictimRoot = VictimCharacter:FindFirstChild('HumanoidRootPart') :: BasePart
	local OwnerRoot = OwnerCharacter:FindFirstChild('HumanoidRootPart') :: BasePart

	TaskManager:CancelTask(Victim, 'Simulation')
	TaskManager:CancelTask(Owner, 'Simulation')

	Victim:SetStatusEffect('InGrab',true)
	Owner:SetStatusEffect('InGrab',true)

	VictimRoot.Anchored = true
	OwnerRoot.Anchored = true

	Owner:SetStatusEffect('CanAutoRotate',false)
	Owner:SetStatusEffect('CanBodySimulation',false)

	Victim:SetStatusEffect('CanAutoRotate',false)
	Victim:SetStatusEffect('CanBodySimulation',false)



	self:Execute({
			Name = 'Network.PlayBindableEvent';
			Config = {
				EventName = 'PlayVFX';
				EventData = {
					Player = Owner.Instance;
					Victim = Victim.Instance;
					VFXType = 'Fists.BackStab';
					State = 'Animation';
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
				Player = Owner.Instance;
				Victim = Victim.Instance;

				VFXType = 'Fists.BackStab';
				State = 'Effects';
			};
		}
	})

	VictimRoot.CFrame = OwnerRoot.CFrame + OwnerRoot.CFrame.LookVector * 2
	
	TaskManager:CreateTask(Victim, 'InGrabMove', 2.8, function(a0)  
		VictimRoot.Anchored = false
		if Owner.Instance.LocaleId then
			VictimRoot:SetNetworkOwner(Owner.Instance)
		end

		Victim:TriggerPassives('OnRagdoll',{
			Victim = Victim;
			HitData = {
				RagdollTime = 2;
			}
		})

		VictimRoot.AssemblyLinearVelocity = OwnerRoot.CFrame.UpVector * 50 + OwnerRoot.CFrame.LookVector * 100
		

		Victim:SetStatusEffect('InGrab',false)

		creteTrails(self,Victim,'Left Arm')
		creteTrails(self,Victim,'Right Arm')
		creteTrails(self,Victim,'Left Leg')
		creteTrails(self,Victim,'Right Leg')
		
		task.delay(2, function()
			if not Victim.Instance.LocaleId then
				VictimRoot:SetNetworkOwner(nil)
			end
		end)


	end)

	TaskManager:CreateTask(Owner, 'InGrabMove', 3.1, function(a0)
		OwnerRoot.Anchored = false
		
		Owner:SetStatusEffect('InGrab',false)

		Owner:SetStatusEffect('CanAutoRotate',true)
		Owner:SetStatusEffect('CanBodySimulation',true)

	end)

end)

EntityRegistry:Register('FistsJump', function(self,node): any
	local Entity = self.Tags['Owner'] :: PlayerInterfaces.IServerPlayerComponent
	local Session = Entity.SessionData

	self:Execute({
		Name = 'Network.PlayRemoteEvent';
		Config = {
			EventType = Enums.EventType.Close;
			Event = 'VFX';
			EventName = 'PlayVFX';
			EventData = {
				Player = Entity.Instance;
				VFXType = 'Fists.M1';
				State = 'JumpLocale';
			};
		}
	})

	self:Execute({
		Name = 'Network.PlayBindableEvent';
		Config = {
			EventName = 'PlayVFX';
			EventData = {
                Player = Entity.Instance;
                VFXType = 'Fists.M1';
				State = 'Jump';
				Combo = Session.StatusEffects.CurrentCombo;
			}
		}
	})



	local HitBox = HitboxClass.new('WeldedBox', 
	{
		IgnoreCharacters = {Entity.Instance.Character};
		velocityPrediction = true;
		root = Entity.Instance.Character:FindFirstChild('HumanoidRootPart');
		size = Vector3.new(4,4,4);
		debug = false;
		duration = .3;
		proportional = {
			offsetMultiplier = 1;
			DefaultSize = Vector3.new(4,4,4);
		}
	})
	task.delay(.3,function()
		HitBox:Start()
	end)

	HitBox.OnHit:Connect(function(hitCharacter, hitPart)
		local Victim = EntityComponent.GetEntity(hitCharacter:GetAttribute('Id'))
		if not Victim then return end
		
		self:Execute({
			Name = 'Action.DealDamage';
			Config = {
				['Victim'] = Victim;
				['Enemy'] = Entity;
				['HitData'] = {
					Damage = 5;
					StunTime = 1;
					Weapon = Enums.WeaponSubType.Fists.Name
				}
			}
		})
		
	end)

end)

EntityRegistry:Register('FistsRun', function(self,node): any
	local Entity = self.Tags['Owner'] :: PlayerInterfaces.IServerPlayerComponent
	local Session = Entity.SessionData

	self:Execute({
		Name = 'Network.PlayRemoteEvent';
		Config = {
			EventType = Enums.EventType.Close;
			Event = 'VFX';
			EventName = 'PlayVFX';
			EventData = {
				Player = Entity.Instance;
				VFXType = 'Fists.M1';
				State = 'RunLocale';
			};
		}
	})

	self:Execute({
		Name = 'Network.PlayBindableEvent';
		Config = {
			EventName = 'PlayVFX';
			EventData = {
                Player = Entity.Instance;
                VFXType = 'Fists.M1';
				State = 'Run';
				Combo = Session.StatusEffects.CurrentCombo;
			}
		}
	})



	local HitBox = HitboxClass.new('WeldedBox', 
	{
		IgnoreCharacters = {Entity.Instance.Character};
		velocityPrediction = true;
		root = Entity.Instance.Character:FindFirstChild('HumanoidRootPart');
		size = Vector3.new(4,4,4);
		debug = false;
		duration = .3;
		proportional = {
			offsetMultiplier = 1;
			DefaultSize = Vector3.new(4,4,4);
		}
	})
	task.delay(.3,function()
		HitBox:Start()
	end)

	HitBox.OnHit:Connect(function(hitCharacter, hitPart)
		local Victim = EntityComponent.GetEntity(hitCharacter:GetAttribute('Id'))
		if not Victim then return end
		
		self:Execute({
			Name = 'Action.DealDamage';
			Config = {
				['Victim'] = Victim;
				['Enemy'] = Entity;
				['HitData'] = {
					Damage = 5;
					StunTime = 1;
					Weapon = Enums.WeaponSubType.Fists.Name
				}
			}
		})
		
	end)

end)

EntityRegistry:Register('Fists', function(self, node)
	local Entity = self.Tags['Owner'] :: EntityInterfaces.IEntityComponent
	local Session = Entity.SessionData
    self:Execute({
		Name = 'Network.PlayBindableEvent';
		Config = {
			EventName = 'PlayVFX';
			EventData = {
                Player = Entity.Instance;
                VFXType = 'Fists.M1';
				State = 'OnStart';
				Combo = math.max(1,Session.StatusEffects.CurrentCombo);
			}
		}
	})


	local HitBox = HitboxClass.new('WeldedBox', 
	{
		IgnoreCharacters = {Entity.Instance.Character};
		velocityPrediction = true;
		root = Entity.Instance.Character:FindFirstChild('HumanoidRootPart');
		size = Vector3.new(4,4,4);
		debug = false;
		duration = .3;
		proportional = {
			offsetMultiplier = 1;
			DefaultSize = Vector3.new(4,4,4);
		}
	})
	task.delay(.3,function()
		HitBox:Start()
	end)

	HitBox.OnHit:Connect(function(hitCharacter, hitPart)
		local Victim = EntityComponent.GetEntity(hitCharacter:GetAttribute('Id'))
		if not Victim then return end
		
		self:Execute({
			Name = 'Action.DealDamage';
			Config = {
				['Victim'] = Victim;
				['Enemy'] = Entity;
				['HitData'] = {
					Damage = 5;
					StunTime = 1;
					Weapon = Enums.WeaponSubType.Fists.Name
				}
			}
		})
		
	end)
	
end)

return EntityRegistry
