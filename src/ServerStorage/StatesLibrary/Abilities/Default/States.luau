local ReplicatedStorage = game:GetService('ReplicatedStorage')

local Shared = ReplicatedStorage:WaitForChild('Shared')
local Interfaces = Shared:WaitForChild('Interfaces')
local Utilities = Shared:WaitForChild('Utilities')
local NetWork = Utilities:WaitForChild('NetWork')

local Replica = require(NetWork:WaitForChild('VfxReplica'))

local StatesInterfaces = require(Interfaces:WaitForChild('StatesInterfaces'))
local EntityInterfaces = require(Interfaces:WaitForChild('EntityInterfaces'))

type IEntity = EntityInterfaces.IEntityComponent

local States = {}

States.Equip = {
		EquipStyle = function(self: StatesInterfaces.IStatesComponent)
			local Entity: IEntity = self.args.Entity
			local SessionData = Entity.SessionData
			local CharacterData = SessionData.CharacterData
			local StatusEffects = SessionData.StatusEffects

			local Style = Entity:GetPack(SessionData.Equipment.Style)

		    Entity:SpecialSet('CurrentEquipped', SessionData.Equipment.Style)
			Style['Equip']:OnStart()

		end;

		EquipWeapon = function(self: StatesInterfaces.IStatesComponent)
			local Entity: IEntity = self.args.Entity
			local SessionData = Entity.SessionData
			local CharacterData = SessionData.CharacterData
			local StatusEffects = SessionData.StatusEffects

		    Entity:SpecialSet('CurrentEquipped', SessionData.Equipment.Weapon)

		end;

		Unequip = function(self: StatesInterfaces.IStatesComponent)
			local Entity: IEntity = self.args.Entity
			local SessionData = Entity.SessionData
			local CharacterData = SessionData.CharacterData
			local StatusEffects = SessionData.StatusEffects
			local CurrentEquipped = SessionData.CurrentEquipped

		    Entity:SpecialSet('CurrentEquipped', 'none')
		
			local Weapon = Entity:GetPack(SessionData.CurrentEquipped)
			Weapon['Equip']:OnStart()
			
		end;
};

return States
