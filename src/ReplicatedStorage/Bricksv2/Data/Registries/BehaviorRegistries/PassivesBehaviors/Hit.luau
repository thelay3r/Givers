local RunService = game:GetService("RunService")
if RunService:IsClient() then return {} end

local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Bricks = ReplicatedStorage:WaitForChild('Bricksv2')


local Components = Bricks:WaitForChild('Components')
local _Data = Bricks:WaitForChild('Data')

local EntityInterfaces = require(ReplicatedStorage.Shared.Interfaces.EntityInterfaces)
local Enums = require(ReplicatedStorage.Modules.Utilities.Enums)
local _TaskManager = require(ReplicatedStorage.Modules.Utilities.TaskManager)
local Registry = require(Components:WaitForChild('Registry'))



local HitRegistry = Registry.new()


HitRegistry:Register('Hit', function(self,node)
    local EventData = self.Tags['OnHit']['EventData']
    local Victim = EventData['Victim']
    local Enemy = EventData['Enemy'] :: EntityInterfaces.IEntityComponent
    local HitData = EventData['HitData']
    if HitData.Damage <= 0 then return end
    
    local weapon = HitData.Weapon
    local combo = if Enemy.SessionData.StatusEffects.CurrentCombo <= 0 then 4 else Enemy.SessionData.StatusEffects.CurrentCombo
    self:Execute({
		Name = 'Network.PlayRemoteEvent';
		Config = {
			EventType = Enums.EventType.Close;
			Event = 'VFX';
			EventName = 'PlayVFX';
			EventData = {
				Player = Victim.Instance;
                Enemy = Enemy.Instance;
                Combo = combo;
				VFXType = weapon..'.Hit';
				State = 'Hit'
			};
		}
	})
    
end)


return HitRegistry
