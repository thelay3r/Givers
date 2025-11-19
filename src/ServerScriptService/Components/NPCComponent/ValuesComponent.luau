local ServerScriptService = game:GetService('ServerScriptService')
local ReplicatedStorage = game:GetService('ReplicatedStorage')

local Services = ServerScriptService:WaitForChild('Services')

local Shared = ReplicatedStorage:WaitForChild('Shared')
local Interfaces = Shared:WaitForChild('Interfaces')

local ReplicaService = require(Services:WaitForChild('ReplicaService'))
local EntityInterfaces = require(Interfaces:WaitForChild('EntityInterfaces'))
local ValuesInterface = require(Interfaces:WaitForChild('ValuesInterface'))

type IEntity = EntityInterfaces.IEntityComponent
type IValues = ValuesInterface.IValues


local ValuesComponent: IValues = {}

function ValuesComponent.SpecialSet(self: IPlayer, string, name: string, value: any)

	local SessionData = self.SessionData
	
	if not SessionData[name] then return end

	SessionData[name] = value
end

function ValuesComponent.SetAttribute(self: IEntity, name: string, value: any)
	
	local SessionData = self.SessionData
	local Scope = SessionData.Attributes
	
	local target = Scope[name]
	if not target then return end
	
	Scope[name] = value
end

function ValuesComponent.SetStatusEffect(self: IEntity, name: string, value: any)

	local SessionData = self.SessionData
	local Scope = SessionData.StatusEffects

	local target = Scope[name]
	if not target then return end

	Scope[name] = value
end

function ValuesComponent.SetCharacterData(self: IEntity, name: string, value: any)

	local SessionData = self.SessionData
	local Scope = SessionData.CharacterData

	local target = Scope[name]
	if not target then return end

	Scope[name] = value
end

function ValuesComponent.SetEquipment(self: IEntity, name: string, value: any)

	local SessionData = self.SessionData
	local Scope = SessionData.Equipment

	local target = Scope[name]
	if not target then return end

	Scope[name] = value
end

function ValuesComponent.SetSetting(self: IEntity, name: string, value: any)

	local SessionData = self.SessionData
	local Scope = SessionData.Settings

	local target = Scope[name]
	if not target then return end

	Scope[name] = value
end

return ValuesComponent
