local ServerScriptService = game:GetService('ServerScriptService')
local ReplicatedStorage = game:GetService('ReplicatedStorage')

local Services = ServerScriptService:WaitForChild('Services')

local Shared = ReplicatedStorage:WaitForChild('Shared')
local Interfaces = Shared:WaitForChild('Interfaces')

local ReplicaService = require(Services:WaitForChild('ReplicaService'))
local PlayerInterfaces = require(Interfaces:WaitForChild('PlayerInterfaces'))
local ValuesInterface = require(Interfaces:WaitForChild('ValuesInterface'))

type IPlayer = PlayerInterfaces.IServerPlayerComponent
type IValues = ValuesInterface.IValues


local ValuesComponent: IValues = {}

function ValuesComponent.SpecialSet(self: IPlayer, name: string, value: any)

	local SessionData = self.SessionData

	if not SessionData[name] then return end

	SessionData[name] = value
	
	self.Replica:Set({'Session', name}, value)
end

function ValuesComponent.SetAttribute(self: IPlayer, name: string, value: any)
	
	local SessionData = self.SessionData
	local Scope = SessionData.Attributes
	
	local target = Scope[name]
	if target == nil then return end
	
	Scope[name] = value
	self.Replica:Set({'Session', 'Attributes', name}, value)
end

function ValuesComponent.SetStatusEffect(self: IPlayer, name: string, value: any)

	local SessionData = self.SessionData
	local Scope = SessionData.StatusEffects


	local target = Scope[name]
	if target == nil then return end

	Scope[name] = value
	self.Replica:Set({'Session', 'StatusEffects', name}, value)
end

function ValuesComponent.SetCharacterData(self: IPlayer, name: string, value: any)

	local SessionData = self.SessionData
	local Scope = SessionData.CharacterData

	local target = Scope[name]
	if target == nil then return end

	Scope[name] = value
	self.Replica:Set({'Session', 'CharacterData', name}, value)
end

function ValuesComponent.SetEquipment(self: IPlayer, name: string, value: any)

	local SessionData = self.SessionData
	local Scope = SessionData.Equipment

	local target = Scope[name]
	if target == nil then return end

	Scope[name] = value
	self.Replica:Set({'Session', 'Equipment', name}, value)
end

function ValuesComponent.SetSetting(self: IPlayer, name: string, value: any)

	local SessionData = self.SessionData
	local Scope = SessionData.Settings

	local target = Scope[name]
	if target == nil then return end

	Scope[name] = value
	self.Replica:Set({'Session', 'Settings', name}, value)
end

return ValuesComponent
