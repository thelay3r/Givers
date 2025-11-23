local ReplicatedStorage = game:GetService('ReplicatedStorage')

local Shared = ReplicatedStorage:WaitForChild('Shared')
local Interfaces = Shared:WaitForChild('Interfaces')
local Templates = Shared.Templates

local StatesInterfaces = require(Interfaces:WaitForChild('StatesInterfaces'))
local AbilityTemplate = require(Templates:WaitForChild('Ability'))
type AbilityTemplateInstance = typeof(AbilityTemplate())

type IAbility = typeof(AbilityTemplate())

export type IAbilityMethods = {
	AddPack: (self: IAbilityMethods, AbilitiesFolder: Folder) -> (),
	GetPack: (self: IAbilityMethods, PackName: string) -> (),
	RemovePack: (self: IAbilityMethods, PackName: string) -> (),
	RemoveAllPacks: (self: IAbilityMethods) -> (),
	
	AddAbility: (self: IAbilityMethods, AbilitiesFolder: Folder, AbilityName: string) -> (),
	GetAbility: (self: IAbilityMethods, AbilityName: string) -> (),
	RemoveAbility: (self: IAbilityMethods, Scope: string, AbilityName: string) -> (),
	RemoveAllAbilities: (self: IAbilityMethods) -> (),
	
	LoadCFG: (self: AbilityPreset.IAbility, CFG: {}) -> (),
	CloseConnection: (self: AbilityInterfaces.IAbilityComponent) -> (),
	SetCooldown: (self: AbilityInterfaces.IAbilityComponent, increseadTime : number) -> (),
	CheckCooldown: (self: AbilityInterfaces.IAbilityComponent) -> (),
	CheckBlacklist: (self: IAbilityComponent, List: {}, Additional: IAdditional) -> (),
	SetAbility: (self: IAbilityComponent, Name: string, Value: string) -> (),
	
	OnStart: (self: IAbilityComponent, Additional: IAdditional) -> (),
	OnSpecialStart: (self: IAbilityComponent, Additional: IAdditional) -> (),
	OnStop: (self: IAbilityComponent) -> (),
}

export type IAdditional = {
	Bypass: boolean;
	CheckCD: boolean;
	IgnoreUsed: boolean;
}

export type IAbilityConfig = {
	Type: string;
	Duration: number;
	MinDuration: number;
	Cooldown: number;
	Key: any;
	Blacklist: {}
	
}

export type IAbilityComponent = IAbilityMethods & IAbilitypreset & {
	OwnerId: string;
	Name: string;
	State: StatesInterfaces.IStatesComponent;
	Key: Enum.KeyCode;
	Config: IAbilityConfig;
	IsActive: boolean;
	IsHolded: boolean;
	StartTime: number;
	LastUsed: number;
	Tasks: {};
	Threads: {};
}

return {}