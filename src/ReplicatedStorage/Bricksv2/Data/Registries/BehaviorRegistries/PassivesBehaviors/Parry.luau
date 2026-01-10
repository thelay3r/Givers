local RunService = game:GetService("RunService")
if RunService:IsClient() then return {} end

local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Bricks = ReplicatedStorage:WaitForChild('Bricksv2')


local Components = Bricks:WaitForChild('Components')
local _Data = Bricks:WaitForChild('Data')

local EntityInterfaces = require(ReplicatedStorage.Shared.Interfaces.EntityInterfaces)
local Enums = require(ReplicatedStorage.Shared.Utilities.Modules.Enums)
local TaskManager = require(ReplicatedStorage.Shared.Utilities.Modules.TaskManager)
local _TaskManager = require(ReplicatedStorage.Shared.Utilities.Modules.TaskManager)
local Registry = require(Components:WaitForChild('Registry'))



local ParryRegistry = Registry.new()

ParryRegistry:Register('ParryHit', function(self,node)  
    local EventData = self.Tags['OnHit']['EventData']
    local Enemy = EventData['Enemy'] :: EntityInterfaces.IEntityComponent
    local Victim = EventData['Victim'] :: EntityInterfaces.IEntityComponent
    local StatusEffects = Victim.SessionData.StatusEffects

    if not StatusEffects.Parry then return end

    		self:Execute({
			Name = 'Action.DealDamage';
			Config = {
				['Victim'] = Enemy;
				['Enemy'] = Victim;
				['HitData'] = {
					Damage = 0;
					StunTime = 1;
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
				Player = Victim.Instance;
				VFXType = 'Parry.Parry';
				State = 'Hit'
			};
		}
	})

end)


ParryRegistry:Register('Parry', function(self,node)
    local EventData = self.Tags['OnCast']['EventData']
    local Victim = EventData['Victim'] :: EntityInterfaces.IEntityComponent

	self:Execute({
		Name = 'Network.PlayRemoteEvent';
		Config = {
			EventType = Enums.EventType.Close;
			Event = 'VFX';
			EventName = 'PlayVFX';
			EventData = {
				Player = Victim.Instance;
				VFXType = 'Parry.Parry';
				State = 'Cast'
			};
		}
	})

    Victim:SetStatusEffect('Parry',true)
    TaskManager:CreateTask(Victim, 'Parry', 1, function(a0)  
        Victim:SetStatusEffect('Parry',false)
    end)

end)


return ParryRegistry
