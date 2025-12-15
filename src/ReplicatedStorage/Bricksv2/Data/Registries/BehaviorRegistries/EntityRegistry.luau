
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



EntityRegistry:Register('SwapWeapon', function(self, node)
	
	local Entity = self.Tags['Owner'] :: PlayerInterfaces.IServerPlayerComponent
	local Data = Entity.Replica.Data
	local Session = Data.Session

	print(Session)

	if not (Session.CurrentEquipped ~= 'none') then 
		Session.CurrentEquipped = 'none' 
		return 
	end


	local weapon = Session.Equipment.Weapon
	Session.CurrentEquipped = if weapon ~= 'none' then weapon else 'Fists'

end)

return EntityRegistry
