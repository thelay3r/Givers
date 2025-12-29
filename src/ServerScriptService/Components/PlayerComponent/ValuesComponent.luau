local ReplicatedStorage = game:GetService('ReplicatedStorage')


local Shared = ReplicatedStorage:WaitForChild('Shared')
local Interfaces = Shared:WaitForChild('Interfaces')

local PlayerInterfaces = require(Interfaces:WaitForChild('PlayerInterfaces'))
local ValuesInterface = require(Interfaces:WaitForChild('ValuesInterface'))

type IPlayer = PlayerInterfaces.IServerPlayerComponent
type IValues = ValuesInterface.IValues


local ValuesComponent = {}

function ValuesComponent.SpecialSet(self: IPlayer, name: string, value: any)
	self.Replica:Set({'Session', name}, value)
end

function ValuesComponent.SetAbility(self: IPlayer, name: string, value: any)
	self.Replica:Set({'Session', 'Abilities', name}, value)
end
function ValuesComponent.SetPassive(self: IPlayer, name: string, value: any)
	self.Replica:Set({'Session', 'Passives', name}, value)
end
function ValuesComponent.SetAttribute(self: IPlayer, name: string, value: any)
	self.Replica:Set({'Session', 'Attributes', name}, value)
end

function ValuesComponent.SetStatusEffect(self: IPlayer, name: string, value: any)
	self.Replica:Set({'Session', 'StatusEffects', name}, value)
end

function ValuesComponent.SetCharacterData(self: IPlayer, name: string, value: any)
	self.Replica:Set({'Session', 'CharacterData', name}, value)
end

function ValuesComponent.SetEquipment(self: IPlayer, name: string, value: any)
	self.Replica:Set({'Session', 'Equipment', name}, value)
end

function ValuesComponent.SetSetting(self: IPlayer, name: string, value: any)
	self.Replica:Set({'Session', 'Settings', name}, value)
end

return ValuesComponent
