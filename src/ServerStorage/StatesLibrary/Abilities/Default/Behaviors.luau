local ReplicatedStorage = game:GetService('ReplicatedStorage')

local Shared = ReplicatedStorage:WaitForChild('Shared')
local Interfaces = Shared:WaitForChild('Interfaces')

local StatesInterfaces = require(Interfaces:WaitForChild('StatesInterfaces'))

local States = require(script.Parent.States)

local Behaviors = {}

Behaviors.Equip = {
	EquipCheck = {
		priority = 1;

		check = function(self: StatesInterfaces.IStatesComponent)
			local Entity = self.args.Entity
			local SessionData = Entity.SessionData
			local StatusEffects = SessionData.StatusEffects

			if SessionData.CurrentEquipped == 'none' then
				return true
			else
				return false
			end

		end,

		trueaction = function(self: StatesInterfaces.IStatesComponent)

			local Entity = self.args.Entity
			local Equipment = Entity.SessionData.Equipment

			local LefhShift = Entity.SessionData.PressedKeys['LeftShift']

			if LefhShift and Equipment.Weapon ~= 'none' then
				States.Equip.EquipWeapon(self)
			else
				States.Equip.EquipStyle(self)
			end

		end,

		falseaction = function(self: StatesInterfaces.IStatesComponent)
			States.Equip.Unequip(self)
		end,
	};
	
};

return Behaviors
