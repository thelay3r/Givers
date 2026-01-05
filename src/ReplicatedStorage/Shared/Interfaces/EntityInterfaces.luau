local ReplicatedStorage = game:GetService('ReplicatedStorage')

local Shared = ReplicatedStorage:WaitForChild('Shared')
local Interfaces = Shared:WaitForChild('Interfaces')
local Templates = Shared.Templates


local SpeedModuleInterface = require(script.Parent.SpeedModuleInterface)
local SessionData = require(Templates.SessionData)
local ValuesInterface = require(script.Parent.ValuesInterface)

type ISessionData = typeof(SessionData())
type IValues = ValuesInterface.IValues

export type IEntityMethods = {
	New: (self: IEntityMethods) -> (),
	AppendPassive: (self: IEntityMethods, scope : string, passiveName: string) -> (),
	InvalidatePassiveCache: (self: IEntityMethods)-> ();
}

export type IEntityComponent = IEntityMethods & IValues & {
	SessionData: ISessionData,
	SpeedController: SpeedModuleInterface.ISpeedComponent;
	Instance: Player;
}

return {}
