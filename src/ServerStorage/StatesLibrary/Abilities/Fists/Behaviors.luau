local ReplicatedStorage = game:GetService('ReplicatedStorage')

local Shared = ReplicatedStorage:WaitForChild('Shared')
local Interfaces = Shared:WaitForChild('Interfaces')

local StatesInterfaces = require(Interfaces:WaitForChild('StatesInterfaces'))
local EntityInterfaces = require(Interfaces:WaitForChild('EntityInterfaces'))

type IEntity = EntityInterfaces.IEntityComponent

local States = require(script.Parent.States)

local Behaviors = {}

Behaviors.Equip = {
	EquipCheck = {
		name = 'EquipCheck';
		priority = 2;
		check = function(self: StatesInterfaces.IStatesComponent)
			local Entity: IEntity = self.args.Entity
			local SessionData = Entity.SessionData
			local StatusEffects = SessionData.StatusEffects
			local Equipment = SessionData.Equipment
			
			return SessionData.StatusEffects.EquippedWeapon
		end,
		trueaction = function(self: StatesInterfaces.IStatesComponent)
			States['Equip'].UnequipFists(self)
		end,

		falseaction = function(self: StatesInterfaces.IStatesComponent)
			States['Equip'].EquipFists(self)
		end,
	};
}


Behaviors.M1 = {
	M1 = {
		name = 'M1';
		priority = 3;
		check = function(self: StatesInterfaces.IStatesComponent)
			local Entity = self.args.Entity
			local SessionData = Entity.SessionData
			local StatusEffects = SessionData.StatusEffects
			local Equipment = SessionData.Equipment

			print(SessionData.StatusEffects.EquippedWeapon)
			return SessionData.StatusEffects.EquippedWeapon
		end,
		trueaction = function(self: StatesInterfaces.IStatesComponent)
			States['Equip'].EquipFists(self)
		end,

		falseaction = function(self: StatesInterfaces.IStatesComponent)
			States['Equip'].UnequipFists(self)
		end,
	};
}
return Behaviors
