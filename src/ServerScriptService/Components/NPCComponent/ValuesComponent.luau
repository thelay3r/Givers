local ReplicatedStorage = game:GetService('ReplicatedStorage')




local Shared = ReplicatedStorage:WaitForChild('Shared')
local Interfaces = Shared:WaitForChild('Interfaces')


local EntityInterfaces = require(Interfaces:WaitForChild('EntityInterfaces'))
local ValuesInterface = require(Interfaces:WaitForChild('ValuesInterface'))


type IEntity = EntityInterfaces.IEntityComponent
type IValues = ValuesInterface.IValues



local ValuesComponent: any | IValues = {}

local function SetValue(self: IEntity, scope: any, name: string, value: any, subKey: string?)
    local target = scope[name]
    if target == nil then return end
    
    if subKey then
        if value == nil then
			table.clear(target[subKey])
		end
        target[subKey] = value
    else
        scope[name] = value
    end
end


function ValuesComponent.SpecialSet(self: IEntity, name: string, value: any, subKey: string?)
    local SessionData = self.SessionData
    
    if SessionData[name] == nil then return end

    if subKey then
		if value == nil then
			table.clear(SessionData[name][subKey])
		end
        SessionData[name][subKey] = value
    else
        SessionData[name] = value
    end
end


function ValuesComponent.SetAbility(self: IEntity, name: string, value: any, subKey: string?)
    local SessionData = self.SessionData
    SetValue(self, SessionData.Abilities, name, value, subKey)
end

function ValuesComponent.SetPassive(self: IEntity, name: string, value: any, subKey: string?)
    local SessionData = self.SessionData
    SetValue(self, SessionData.Passives, name, value, subKey)
end

function ValuesComponent.SetAttribute(self: IEntity, name: string, value: any, subKey: string?)
    local SessionData = self.SessionData
    SetValue(self, SessionData.Attributes, name, value, subKey)
end


function ValuesComponent.SetStatusEffect(self: IEntity, name: string, value: any, subKey: string?)
    local SessionData = self.SessionData
    SetValue(self, SessionData.StatusEffects, name, value, subKey)
end


function ValuesComponent.SetCharacterData(self: IEntity, name: string, value: any, subKey: string?)
    local SessionData = self.SessionData
    SetValue(self, SessionData.CharacterData, name, value, subKey)
end


function ValuesComponent.SetEquipment(self: IEntity, name: string, value: any, subKey: string?)
    local SessionData = self.SessionData
    SetValue(self, SessionData.Equipment, name, value, subKey)
end


function ValuesComponent.SetSpeedData(self: IEntity, name: string, value: any, subKey: string?)
    local SessionData = self.SessionData
    SetValue(self, SessionData.SpeedData, name, value, subKey)
end


function ValuesComponent.SetSetting(self: IEntity, name: string, value: any, subKey: string?)
    local SessionData = self.SessionData
    SetValue(self, SessionData.Settings, name, value, subKey)
end


return ValuesComponent
