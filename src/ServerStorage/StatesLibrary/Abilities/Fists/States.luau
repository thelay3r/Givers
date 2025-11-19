local ServerScriptService = game:GetService('ServerScriptService')
local ReplicatedStorage = game:GetService('ReplicatedStorage')

local Shared = ReplicatedStorage:WaitForChild('Shared')
local Interfaces = Shared:WaitForChild('Interfaces')
local Utilities = Shared:WaitForChild('Utilities')
local NetWork = Utilities:WaitForChild('NetWork')

local Services = ServerScriptService:WaitForChild('Services')

local VFXReplica = require(NetWork:WaitForChild('VfxReplica'))
local ReplicaService = require(Services:WaitForChild('ReplicaService'))

local StatesInterfaces = require(Interfaces:WaitForChild('StatesInterfaces'))
local EntityInterface = require(Interfaces:WaitForChild('EntityInterfaces'))

local States = {}

States.Equip = {
	EquipFists = function(self: StatesInterfaces.IStatesComponent)
		local Entity: EntityInterface.IEntityComponent = self.args.Entity
		local SessionData = Entity.SessionData
		local CharacterData = SessionData.CharacterData
		local Character = CharacterData.Character
		local StatusEffects = SessionData.StatusEffects
		local Equipment = SessionData.Equipment
		
		Entity:SetStatusEffect('EquippedWeapon', true)
		VFXReplica:Fire(CharacterData.HumanoidRootPart,math.huge, 'VFX', {Pack = SessionData.CurrentEquipped, Name ='Equip',Func = 'Equip'},CharacterData.Character,StatusEffects.EquippedWeapon)
		
	end,
	
	UnequipFists = function(self: StatesInterfaces.IStatesComponent)
		local Entity = self.args.Entity
		local SessionData = Entity.SessionData
		local CharacterData = SessionData.CharacterData
		local StatusEffects = SessionData.StatusEffects
		local Equipment = SessionData.Equipment

		Entity:SetStatusEffect('EquippedWeapon', false)
		
		VFXReplica:Fire(CharacterData.HumanoidRootPart,math.huge, 'VFX', {Pack = SessionData.CurrentEquipped, Name ='Equip',Func = 'Unequip'},CharacterData.Character,StatusEffects.EquippedWeapon)
		
	end,
}

return States
