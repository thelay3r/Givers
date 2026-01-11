local RunService = game:GetService("RunService")
if RunService:IsClient() then return {} end

local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Bricks = ReplicatedStorage:WaitForChild('Bricksv2')


local Components = Bricks:WaitForChild('Components')
local _Data = Bricks:WaitForChild('Data')

local EntityInterfaces = require(ReplicatedStorage.Shared.Interfaces.EntityInterfaces)
local Ragdoll = require(ReplicatedStorage.Shared.Utilities.Modules.Ragdoll)
local TaskManager = require(ReplicatedStorage.Shared.Utilities.Modules.TaskManager)
local _TaskManager = require(ReplicatedStorage.Shared.Utilities.Modules.TaskManager)
local Registry = require(Components:WaitForChild('Registry'))



local RagdollRegistry = Registry.new()



RagdollRegistry:Register('Ragdoll', function(self,node)
    local EventData = self.Tags['OnRagdoll']['EventData']
    local HitData = EventData['HitData']
    
    local Victim = EventData['Victim'] :: EntityInterfaces.IEntityComponent
    local VictimCharacter = Victim.Instance.Character
    if not HitData.RagdollTime then return end

    if HitData['RagdollTime'] <= 0 then return end
    local RagdollTime = HitData['RagdollTime'] :: number
    local now = tick()
    local newRagdollTime: number = now + RagdollTime 

    if newRagdollTime <= (node.Config.LastRagdollTime or 0) then return end
    node.Config.LastRagdollTime = newRagdollTime


    local DiffRagdollTime = node.Config.LastRagdollTime - now
    local TaskTime = math.max(DiffRagdollTime :: number, 0)

    TaskManager:CancelTask(Victim, 'Simulation')

    Victim:SetSpeedData('CanChange',false)
    Victim:SetStatusEffect('CanAutoRotate',false)
    Victim:SetStatusEffect('CanBodySimulation',false)

    Victim:SetStatusEffect('Ragdoll',true)
    Ragdoll:Enabled(VictimCharacter)

    Victim.SpeedController:Amplify({
        Name = 'Ragdoll';
        Percent = -100;
        UseBaseSpeed = false;
        Priority = 75;
    })
    
    TaskManager:CreateTask(Victim, 'Ragdoll', TaskTime, function(a0) 
        Ragdoll:Disabled(VictimCharacter)

        Victim:SetStatusEffect('Ragdoll',false)
        Victim:SetSpeedData('CanChange',true)
        Victim:SetStatusEffect('CanAutoRotate',true)
        Victim:SetStatusEffect('CanBodySimulation',true)

        Victim.SpeedController:Revert({Name = 'Ragdoll'})
    end)

end)


return RagdollRegistry
