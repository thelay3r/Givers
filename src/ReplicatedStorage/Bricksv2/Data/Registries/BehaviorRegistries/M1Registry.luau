
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Bricks = ReplicatedStorage:WaitForChild('Bricksv2')

local Components = Bricks:WaitForChild('Components')
local Data = Bricks:WaitForChild('Data')
local Registries = Data:WaitForChild('Registries')

local PlayerInterfaces = require(ReplicatedStorage.Shared.Interfaces.PlayerInterfaces)
local TaskManager = require(ReplicatedStorage.Shared.Utilities.Modules.TaskManager)
local Registry = require(Components:WaitForChild('Registry'))
local AbilityParser = require(Components:WaitForChild('AbilityParser'))

local AbilityFolder = Data:WaitForChild('Abilities')
local BlackList = require(AbilityFolder:WaitForChild('BlackList'))


local EntityRegistry = Registry.new()

EntityRegistry:Register('Root', function(self, node)  
    print('New Root Behavior')
end)



EntityRegistry:Register('Fist', function(self, node)
	local Entity = self.Tags['Owner'] :: PlayerInterfaces.IServerPlayerComponent
	local Session = Entity.Replica.Data.Session
    self:Execute({
		Name = 'Network.PlayVFX';
		Config = {
			Client = true;
			VFXType = 'Fists.M1';
			EventData = {
				State = 'OnStart';
				Combo = Session.StatusEffects.CurrentCombo;
			}
		}
	})

end)

EntityRegistry:Register('Spear', function(self, node)
	local Entity = self.Tags['Owner'] :: PlayerInterfaces.IServerPlayerComponent
	local Session = Entity.Replica.Data.Session
    self:Execute({
		Name = 'Network.PlayVFX';
		Config = {
			Client = true;
			VFXType = 'Spear.M1';
			EventData = {
				State = 'OnStart';
				Combo = Session.StatusEffects.CurrentCombo;
			}
		}
	})

end)
return EntityRegistry
