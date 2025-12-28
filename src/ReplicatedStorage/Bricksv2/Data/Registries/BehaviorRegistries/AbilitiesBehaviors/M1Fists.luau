local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Bricks = ReplicatedStorage:WaitForChild('Bricksv2')

local Components = Bricks:WaitForChild('Components')
local _Data = Bricks:WaitForChild('Data')

local PlayerInterfaces = require(ReplicatedStorage.Shared.Interfaces.PlayerInterfaces)
local _TaskManager = require(ReplicatedStorage.Shared.Utilities.Modules.TaskManager)
local Registry = require(Components:WaitForChild('Registry'))



local EntityRegistry = Registry.new()

EntityRegistry:Register('Root', function(self, node)  
    print('New Root Behavior')
end)



EntityRegistry:Register('Fist', function(self, node)
	local Entity = self.Tags['Owner'] :: PlayerInterfaces.IServerPlayerComponent
	local Session = Entity.Replica.Data.Session
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
end)

return EntityRegistry
