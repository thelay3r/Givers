local ReplicatedStorage = game:GetService('ReplicatedStorage')

local Shared = ReplicatedStorage:WaitForChild('Shared')
local Interfaces = Shared:WaitForChild('Interfaces')
local Templates = Shared.Templates

local AbilityInterfaces = require(Interfaces:WaitForChild('AbilityInerfaces'))
local ClientData = require(Templates:WaitForChild('ClientData'))
local EventBusInterfaces = require(Interfaces:WaitForChild('EventBusInterfaces'))

type IClientData = typeof(ClientData())

export type IReplicaData = {
	OnChange: (self: IReplicaData,listener : (action: string, path: {string | number}, param1: any, param2: any?) -> ()) -> ();
	OnSet: (self: IReplicaData,path: {string | number}, listener: (new_value: any, old_value: any) -> ())->();
}

export type IAbilityMethods = {
	AddPack: (self: IAbilityMethods, AbilitiesFolder: Folder) -> (),
	GetPack: (self: IAbilityMethods, PackName: string) -> (),
	RemovePack: (self: IAbilityMethods, PackName: string) -> (),
	RemoveAllPacks: (self: IAbilityMethods) -> (),

	AddAbility: (self: IAbilityMethods, AbilitiesFolder: Folder, AbilityName: string) -> (),
	GetAbility: (self: IAbilityMethods, Scope: string, AbilityName: string) -> (),
	RemoveAbility: (self: IAbilityMethods, Scope: string, AbilityName: string) -> (),
	RemoveAllAbilities: (self: IAbilityMethods) -> (),
}

export type IClientPlayerMethods = {
	New: (self: IClientPlayerComponent) -> (),
	SetupCharacter: (self: IClientPlayerComponent) -> (),
	LoadClientData: (self: IClientPlayerComponent) -> (),
	SharePlayer: (self: IClientPlayerComponent) ->(),
	
	LoadDefaultInput: (self: IClientPlayerComponent) -> (),
	UpdateAbilities: (self: IClientPlayerComponent, abilities: {AbilityInterfaces.ILocalAbilityComponent}) -> (),
	
}

export type IClientPlayerComponent = IClientPlayerMethods & IAbilityMethods & {
	Instance: Player,
	ClientData: IClientData,
	Replica: IReplicaData,
	Buses: {
		['Main'] : EventBusInterfaces.IEventBus;
		['Character'] : EventBusInterfaces.IEventBus;
	}
}

return {}
