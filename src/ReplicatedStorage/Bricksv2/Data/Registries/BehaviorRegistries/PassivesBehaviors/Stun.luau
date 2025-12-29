local ReplicatedStorage = game:GetService('ReplicatedStorage')
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
local Bricks = ReplicatedStorage:WaitForChild('Bricksv2')
if RunService:IsClient() then return {} end

local Components = Bricks:WaitForChild('Components')
local _Data = Bricks:WaitForChild('Data')

local EntityInterfaces = require(ReplicatedStorage.Shared.Interfaces.EntityInterfaces)
local PlayerInterfaces = require(ReplicatedStorage.Shared.Interfaces.PlayerInterfaces)
local HitboxClass = require(ReplicatedStorage.Shared.Utilities.Modules.HitboxClass)
local _TaskManager = require(ReplicatedStorage.Shared.Utilities.Modules.TaskManager)
local Registry = require(Components:WaitForChild('Registry'))



local StunRegistry = Registry.new()

StunRegistry:Register('GreatStun?', function(self,node)
    local EventData = self.Tags['OnHit']['EventData']
    local Entity = EventData['Victim'] :: EntityInterfaces.IEntityComponent 
    local StatusEffects = Entity.SessionData.StatusEffects

    return not StatusEffects.GreatStunned
end)

StunRegistry:Register('Stun', function(self,node)
    local EventData = self.Tags['OnHit']['EventData']
    local Victim = EventData['Victim']

    
    Victim:SetStatusEffect('Stun',true)
end)


return StunRegistry
