local RunService = game:GetService("RunService")
if RunService:IsClient() then return {} end

local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Bricks = ReplicatedStorage:WaitForChild('Bricksv2')


local Components = Bricks:WaitForChild('Components')
local _Data = Bricks:WaitForChild('Data')

local EntityInterfaces = require(ReplicatedStorage.Shared.Interfaces.EntityInterfaces)
local TaskManager = require(ReplicatedStorage.Shared.Utilities.Modules.TaskManager)
local _TaskManager = require(ReplicatedStorage.Shared.Utilities.Modules.TaskManager)
local Registry = require(Components:WaitForChild('Registry'))



local StunRegistry = Registry.new()

StunRegistry:Register('GreatStun?', function(self,node)
    local EventData = self.Tags['OnHit']['EventData']
    local Entity = EventData['Victim'] :: EntityInterfaces.IEntityComponent 
    local StatusEffects = Entity.SessionData.StatusEffects

    return not StatusEffects.GreatStunned
end)

StunRegistry:Register('Block', function(self,node)
    local EventData = self.Tags['OnHit']['EventData']
    local Victim = EventData['Victim'] :: EntityInterfaces.IEntityComponent
    if not Victim.SessionData.StatusEffects['Block'] then return end
    
    EventData.Damage = 0
    
end)


return StunRegistry
