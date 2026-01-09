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



local StunRegistry = Registry.new()




StunRegistry:Register('GreatStun', function(self,node)
    local EventData = self.Tags['OnGreatStun']['EventData']
    local HitData = EventData['HitData']
    local Victim = EventData['Victim'] :: EntityInterfaces.IEntityComponent
    local StunTime = HitData['StunTime']

    if not HitData.StunTime then return end
  
    local now = tick()
    local newStun = now + StunTime 

    if newStun <= (node.Config.LastStunTime or 0) then return end
    node.Config.LastStunTime = newStun

    local DiffStunTime = node.Config.LastStunTime - now
    local TaskTime = math.max(DiffStunTime :: number, 0)
    Victim:SetSpeedData('CanChange',false)
    Victim:SetStatusEffect('CanBodySimulation',false)
    Victim:SetStatusEffect('CanAutoRotate',false)
    Victim:SetStatusEffect('GreatStun',true)

    
    Victim.SpeedController:Amplify({
        Name = 'GreatStun';
        Percent = -100;
        UseBaseSpeed = false;
        Priority = 100;
    })
    
    self:Execute({
		Name = 'Network.PlayRemoteEvent';
		Config = {
			EventType = Enums.EventType.Close;
			Event = 'VFX';
			EventName = 'PlayVFX';
			EventData = {
				Player = Victim.Instance;
				VFXType = 'GreatStun.Action';
				State = 'Effect';
			};
		}
	})

    self:Execute({
		Name = 'Network.PlayBindableEvent';
		Config = {
			EventName = 'PlayVFX';
			EventData = {
                Player = Victim.Instance;
                VFXType = 'GreatStun.Action';
				State = 'Animation';
			}
		}
	})

    TaskManager:CreateTask(Victim, 'Simulation', TaskTime, function(a0)  
        Victim:SetStatusEffect('CanAutoRotate',true)
        Victim:SetStatusEffect('CanBodySimulation',true)
    end)
    
    TaskManager:CreateTask(Victim, 'GreatStun', TaskTime, function(a0) 
        Victim:SetStatusEffect('GreatStun',false)
        Victim:SetSpeedData('CanChange',true)
        

        Victim.SpeedController:Revert({Name = 'GreatStun'})
        Victim:SetAttribute('Posture',0)
    end)
    
end)


return StunRegistry
