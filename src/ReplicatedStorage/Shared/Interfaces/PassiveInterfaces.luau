local ReplicatedStorage = game:GetService('ReplicatedStorage')

local Shared = ReplicatedStorage:WaitForChild('Shared')
local Templates = Shared.Templates

export type IPassiveMethods = {
	Trigger: (self: IPassiveMethods) -> ();
}

export type IPassive = {
	Trigger: (self: IPassive) -> ();
}

export type IPassiveComponents = IPassiveMethods & {
	Instance: IPassiveComponents;
}

return {}
