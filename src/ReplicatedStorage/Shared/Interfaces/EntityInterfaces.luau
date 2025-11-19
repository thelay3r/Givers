local ReplicatedStorage = game:GetService('ReplicatedStorage')

local Shared = ReplicatedStorage:WaitForChild('Shared')
local Interfaces = Shared:WaitForChild('Interfaces')
local Templates = Shared.Templates

local AbilityInteraces = require(Interfaces:WaitForChild('AbilityInerfaces'))

local SessionData = require(Templates.SessionData)
local ValuesInterface = require(script.Parent.ValuesInterface)

type ISessionData = typeof(SessionData())
type IValues = ValuesInterface.IValues

export type IEntityMethods = {
	New: (self: IEntityMethods) -> (),
	AppendPassive: (self: IEntityMethods, scope : string, passiveName: string) -> (),
}

export type IEntityComponent = IEntityMethods & AbilityInteraces.IAbilityMethods & IValues & {
	SessionData: ISessionData,
}

return {}
