
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
	local Session = Entity.Replica.Data.Session

	local current = Session.CurrentEquipped
	local weapon = Session.Equipment.Weapon
	local pressed = Session.PressedKeys
	local shiftDown = pressed and (pressed['LeftShift'] ~= nil or pressed['Shift'] ~= nil)

	local targetToEquip = if shiftDown then (weapon ~= 'none' and weapon or 'Fists') else 'Fists'

	if current ~= 'none' then
		targetToEquip = 'none'
	end
	
	self:Execute({
		Name = 'NetWork.PlayVFX';
		Config = {
			VFXType = 'Fists.Idle';
			VfxCFG = {
				State = targetToEquip ~= 'none' and 'Equip' or 'Unequip';
			};
		}
	})

	Session.CurrentEquipped = targetToEquip
end)

return EntityRegistry
