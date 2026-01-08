local ReplicatedStorage = game:GetService('ReplicatedStorage')
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
local Bricks = ReplicatedStorage:WaitForChild('Bricksv2')
if RunService:IsClient() then return {} end

local Components = Bricks:WaitForChild('Components')
local _Data = Bricks:WaitForChild('Data')

local EntityComponent = require(ServerScriptService.Components.EntityComponent)
local PlayerInterfaces = require(ReplicatedStorage.Shared.Interfaces.PlayerInterfaces)
local Enums = require(ReplicatedStorage.Shared.Utilities.Modules.Enums)
local isSimilar = require(ReplicatedStorage.Shared.Utilities.Modules.Fusion.Utility.isSimilar)
local HitboxClass = require(ReplicatedStorage.Shared.Utilities.Modules.HitboxClass)
local _TaskManager = require(ReplicatedStorage.Shared.Utilities.Modules.TaskManager)
local Fists = require(ReplicatedStorage.Shared.VFXs.Replica.VFXs.Fists)
local Registry = require(Components:WaitForChild('Registry'))



local EntityRegistry = Registry.new()

EntityRegistry:Register('Root', function(self, node)  
    print('New Root Behavior')
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

EntityRegistry:Register('Fists', function(self, node)
	local Entity = self.Tags['Owner'] :: PlayerInterfaces.IServerPlayerComponent
	local Session = Entity.SessionData
    self:Execute({
		Name = 'Network.PlayBindableEvent';
		Config = {
			EventName = 'PlayVFX';
			EventData = {
                Player = Entity.Instance;
                VFXType = 'Fists.M1';
				State = 'OnStart';
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

return EntityRegistry
