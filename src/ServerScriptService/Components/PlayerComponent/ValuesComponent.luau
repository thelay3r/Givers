local ReplicatedStorage = game:GetService('ReplicatedStorage')



local Shared = ReplicatedStorage:WaitForChild('Shared')
local Interfaces = Shared:WaitForChild('Interfaces')


local PlayerInterfaces = require(Interfaces:WaitForChild('PlayerInterfaces'))
local ValuesInterface = require(Interfaces:WaitForChild('ValuesInterface'))


type IPlayer = PlayerInterfaces.IServerPlayerComponent
type IValues = ValuesInterface.IValues



local ValuesComponent = {}


local function SetValue(self: IPlayer, category: string, name: string, value: any, subKey: string?)
    if subKey then
		if (value == nil) and self.Replica.Data.Session[category][name][subKey] ~= nil then
			table.clear(self.Replica.Data.Session[category][name][subKey])
		end
        self.Replica:Set({'Session', category, name, subKey}, value)
    else
        self.Replica:Set({'Session', category, name}, value)
    end
end


function ValuesComponent.SpecialSet(self: IPlayer, name: string, value: any, subKey: string?)
    if subKey then
        self.Replica:Set({'Session', name, subKey}, value)
    else
        self.Replica:Set({'Session', name}, value)
    end
end


function ValuesComponent.SetAbility(self: IPlayer, name: string, value: any, subKey: string?)
    SetValue(self, 'Abilities', name, value, subKey)
end

function ValuesComponent.SetPassive(self: IPlayer, name: string, value: any, subKey: string?)
    SetValue(self, 'Passives', name, value, subKey)
end

function ValuesComponent.SetAttribute(self: IPlayer, name: string, value: any, subKey: string?)
    SetValue(self, 'Attributes', name, value, subKey)
end


function ValuesComponent.SetSpeedData(self: IPlayer, name: string, value: any, subKey: string?)
    SetValue(self, 'SpeedData', name, value, subKey)
end

function ValuesComponent.SetJumpData(self: IPlayer, name: string, value: any, subKey: string?)
    SetValue(self, 'JumpData', name, value, subKey)
end
function ValuesComponent.SetStatusEffect(self: IPlayer, name: string, value: any, subKey: string?)
    SetValue(self, 'StatusEffects', name, value, subKey)
end


function ValuesComponent.SetCharacterData(self: IPlayer, name: string, value: any, subKey: string?)
    SetValue(self, 'CharacterData', name, value, subKey)
end


function ValuesComponent.SetEquipment(self: IPlayer, name: string, value: any, subKey: string?)
    SetValue(self, 'Equipment', name, value, subKey)
end


function ValuesComponent.SetSetting(self: IPlayer, name: string, value: any, subKey: string?)
    SetValue(self, 'Settings', name, value, subKey)
end


return ValuesComponent
