local RunService = game:GetService("RunService")
if RunService:IsClient() then return {} end

local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Bricks = ReplicatedStorage:WaitForChild('Bricksv2')


local Components = Bricks:WaitForChild('Components')
local _Data = Bricks:WaitForChild('Data')

local EntityInterfaces = require(ReplicatedStorage.Shared.Interfaces.EntityInterfaces)
local _TaskManager = require(ReplicatedStorage.Shared.Utilities.Modules.TaskManager)
local Registry = require(Components:WaitForChild('Registry'))



local StunRegistry = Registry.new()



StunRegistry:Register('Block', function(self,node)
    local EventData = self.Tags['OnHit']['EventData']
    local HitData = EventData['HitData']
    local Victim = EventData['Victim'] :: EntityInterfaces.IEntityComponent
    local StatusEffects = Victim.SessionData.StatusEffects

    if not StatusEffects['Block'] then return end
    
    HitData.Damage = 0
    
    if StatusEffects.Parry then return end
    self:Execute({
        Name = 'Action.DealPosture';
        Config = EventData;
    })
end)


return StunRegistry
