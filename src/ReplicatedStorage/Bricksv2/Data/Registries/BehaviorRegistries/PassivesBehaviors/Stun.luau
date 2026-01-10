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

StunRegistry:Register('Stun', function(self,node)
    local EventData = self.Tags['OnHit']['EventData']
    local HitData = EventData['HitData']
    local Victim = EventData['Victim'] :: EntityInterfaces.IEntityComponent
    local StunTime = HitData['StunTime']

    if not HitData.StunTime then return end
    if Victim.SessionData.StatusEffects['Block'] then return end
  
    

    local now = tick()
    local newStun = now + StunTime 

    if newStun <= (node.Config.LastStunTime or 0) then return end
    node.Config.LastStunTime = newStun

    local DiffStunTime = node.Config.LastStunTime - now
    local TaskTime = math.max(DiffStunTime :: number, 0)
    Victim:SetSpeedData('CanChange',false)
    Victim:SetStatusEffect('Stun',true)

    
    Victim.SpeedController:Amplify({
        Name = 'Stun';
        Percent = -80;
        UseBaseSpeed = false;
        Priority = 20;
    })
    TaskManager:CreateTask(Victim, 'Stun', TaskTime, function(a0) 
        Victim:SetStatusEffect('Stun',false)
        Victim:SetSpeedData('CanChange',true)
        Victim.SpeedController:Revert({Name = 'Stun'})
    end)
    
end)


return StunRegistry
