
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Bricks = ReplicatedStorage:WaitForChild('Bricksv2')

local Components = Bricks:WaitForChild('Components')
local Data = Bricks:WaitForChild('Data')
local Registries = Data:WaitForChild('Registries')

local PlayerInterfaces = require(ReplicatedStorage.Shared.Interfaces.PlayerInterfaces)
local Enums = require(ReplicatedStorage.Shared.Utilities.Modules.Enums)
local SpeedController = require(ReplicatedStorage.Shared.Utilities.Modules.SpeedController)
local TaskManager = require(ReplicatedStorage.Shared.Utilities.Modules.TaskManager)
local Registry = require(Components:WaitForChild('Registry'))
local AbilityParser = require(Components:WaitForChild('AbilityParser'))

local AbilityFolder = Data:WaitForChild('Abilities')
local BlackList = require(AbilityFolder:WaitForChild('BlackList'))


local EntityRegistry = Registry.new()

EntityRegistry:Register('Root', function(self, node)  
    print('New Root Behavior')
end)

EntityRegistry:Register('AcceleratMoveSpeed', function(self,node)
	local Entity = node.Additional['Owner']
	if not Entity then return end
	local config = node.Config
	local Character = Entity.Instance.Character

	local Speed = SpeedController.new(Character)
	local targetSpeed = config.BaseSpeed * (config.Acceleration or 1)
	local updTime = config.AccelerationTime * 60
		
	local diff = targetSpeed - config.BaseSpeed
	local speedPerFrame = diff / (updTime)
	local percentPerFrame = (speedPerFrame / config.BaseSpeed) * 100

	if config.AccelerationTime == 0 then
		config.AccelerationTime = 0.01
	end

	TaskManager:CreateTask(self, 'Accelerat', 0, function(a0)
		for i=1, updTime do
			Speed:Amplify(
				{
					Name = (config.Name) or ('AcceleratMoveSpeed')..Character.Name;
					Type = 'Buff';
					Percent = percentPerFrame;
					InitSpeed = config.BaseSpeed;
				})
			task.wait(1/60)
		end
	end)
end)

EntityRegistry:Register('DeAcceleratMoveSpeed', function(self,node)
	local Entity = node.Additional['Owner']
	if not Entity then return end
	local config = node.Additional['Config']
	local Character = Entity.Instance.Character

	if config['Accelerat'] then
		task.cancel(config['Accelerat'] )
		config['Accelerat'] = nil
	end

	local Speed = SpeedController.new(Character)
	Speed:Revert(
		{
			Name = config.Name or ('AcceleratMoveSpeed')..Character.Name;
			Recursive = false;
		})
end)

EntityRegistry:Register('SetStatusEffect', function(self,node)
	local Entity = self.Tags['Owner']
  	local sessionData = (Entity.Replica.Data.Session)
	local config = node.Config
	sessionData.StatusEffects[config.Effect] = config.Status
	print('Change',node)
	if not RunService:IsServer() then return end
	Entity:SetStatusEffect(config.Effect, config.Status)
end)

EntityRegistry:Register('SwapWeapon', function(self, node)
	local Entity = self.Tags['Owner'] :: PlayerInterfaces.IServerPlayerComponent
	local Session = Entity.Replica.Data.Session

	print('Try to swap')

	local current = Session.CurrentEquipped
	local weapon = Session.Equipment.Weapon
	local pressed = Session.PressedKeys
	local shiftDown = pressed and (pressed['LeftShift'] ~= nil or pressed['Shift'] ~= nil)

	local targetToEquip = if shiftDown then (weapon ~= 'none' and weapon or 'Fists') else 'Fists'

	if current ~= 'none' then
		targetToEquip = 'none'
	end
	
	print('Test Tag')

	self:Execute({
		Name = 'Network.PlayRemoteEvent';
		Config = {
			EventType = Enums.EventType.Close;
			Event = 'VFX';
			EventName = 'PlayVFX';
			EventData = {
				Player = Entity.Instance;
				VFXType = 'Fists.Idle';
				State = targetToEquip ~= 'none' and 'Equip' or 'Unequip';
			};
		}
	})

	Entity:SetEquipment('CurrentEquipped', targetToEquip)
	Session.CurrentEquipped = targetToEquip
end)

return EntityRegistry
