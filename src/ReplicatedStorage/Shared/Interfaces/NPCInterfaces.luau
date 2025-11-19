local ReplicatedStorage = game:GetService('ReplicatedStorage')

local Shared = ReplicatedStorage:WaitForChild('Shared')
local Templates = Shared.Templates

local SessionData = require(Templates:WaitForChild('SessionData'))

type ISessionData = typeof(SessionData())

export type INPCMethods = {
	New: (self: INPCMethods) -> (),
	Destroy:(self: INPCComponent)-> ();
	SetupCharacter: (self: INPCMethods) -> (),
	AppendPassive: (self: INPCMethods, scope : string, passiveName: string) -> (),
}

export type INPCComponent = INPCMethods & {
	SessionData: ISessionData,
}

return {}
