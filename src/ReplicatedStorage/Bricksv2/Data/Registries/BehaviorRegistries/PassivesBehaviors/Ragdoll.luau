local RunService = game:GetService("RunService")
if RunService:IsClient() then return {} end

local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Bricks = ReplicatedStorage:WaitForChild('Bricksv2')


local Components = Bricks:WaitForChild('Components')
local _Data = Bricks:WaitForChild('Data')

local EntityInterfaces = require(ReplicatedStorage.Shared.Interfaces.EntityInterfaces)
local TaskManager = require(ReplicatedStorage.Modules.Utilities.TaskManager)
local _TaskManager = require(ReplicatedStorage.Modules.Utilities.TaskManager)
local Registry = require(Components:WaitForChild('Registry'))



local RagdollRegistry = Registry.new()



RagdollRegistry:Register('Block', function(self,node)
    local EventData = self.Tags['OnHit']['EventData']
    local HitData = EventData['HitData']

    local Victim = EventData['Victim'] :: EntityInterfaces.IEntityComponent
    if HitData['RagdollTime'] <= 0 then return end
    local RagdollTime = HitData['RagdollTime'] :: number
    local now = tick()
    local newRagdollTime: number = now + RagdollTime 

    if newRagdollTime <= (node.Config.LastRagdollTime or 0) then return end
    node.Config.LastRagdollTime = newRagdollTime

    local DiffRagdollTime = node.Config.LastRagdollTime - now
    local TaskTime = math.max(DiffRagdollTime :: number, 0)
    Victim:SetSpeedData('CanChange',false)
    Victim:SetStatusEffect('Ragdoll',true)

    
    Victim.SpeedController:Amplify({
        Name = 'Ragdoll';
        Percent = -100;
        UseBaseSpeed = false;
        Priority = 75;
    })
    
    TaskManager:CreateTask(Victim, 'Ragdoll', TaskTime, function(a0) 
        Victim:SetStatusEffect('Ragdoll',false)
        Victim:SetSpeedData('CanChange',true)
        Victim.SpeedController:Revert({Name = 'Ragdoll'})
    end)

end)


return RagdollRegistry
