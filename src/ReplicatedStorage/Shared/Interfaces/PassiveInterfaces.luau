local ReplicatedStorage = game:GetService('ReplicatedStorage')

local Shared = ReplicatedStorage:WaitForChild('Shared')
local Templates = Shared.Templates

export type IPassiveMethods = {
	New: (self: IPassiveMethods) -> ();
	SetupData: (level: number) -> ();
}

export type IPassive = {
	OnStart: (self: IPassive) -> ();
}

export type IPassiveComponents = IPassiveMethods & {
	
}

return {}
