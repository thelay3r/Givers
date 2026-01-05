local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ServerScriptService = game:GetService("ServerScriptService")

local Shared = ReplicatedStorage:WaitForChild('Shared')
local Interfaces = Shared:WaitForChild('Interfaces')
local Templates = Shared.Templates

local EntityInterfaces = require(ReplicatedStorage.Shared.Interfaces.EntityInterfaces)
local SpeedModuleInterface = require(script.Parent.SpeedModuleInterface)
local ClientData = require(Templates:WaitForChild('ClientData'))
local EventBusInterfaces = require(Interfaces:WaitForChild('EventBusInterfaces'))

type IClientData = typeof(ClientData())

export type IReplicaData = {
	OnChange: (self: IReplicaData,listener : (action: string, path: {string | number}, param1: any, param2: any?) -> ()) -> ();
	OnSet: (self: IReplicaData,path: {string | number}, listener: (new_value: any, old_value: any) -> ())->();
	Data: EntityInterfaces.IEntityComponent;
}

export type IAbilityMethods = {
	AppendAbility: (self: IClientPlayerComponent, packName: string, name: string) -> (),
	RemoveAbility: (self: IClientPlayerComponent, packName: string,name: string) -> (),
}

export type IClientPlayerMethods = {
	New: (self: IClientPlayerComponent) -> (),
	SetupCharacter: (self: IClientPlayerComponent) -> (),
	LoadClientData: (self: IClientPlayerComponent) -> (),
	SharePlayer: (self: IClientPlayerComponent) ->(),
	
	LoadDefaultInput: (self: IClientPlayerComponent) -> (),
	ReplicateKeys: (self: IClientPlayerComponent) -> (),
	InitDirection: (self: IClientPlayerComponent) -> (),
}

export type IClientPlayerComponent = IClientPlayerMethods & IAbilityMethods & {
	Instance: Player,
	SessionData: EntityInterfaces.IEntityComponent,
	ClientData: IClientData,
	SpeedController: SpeedModuleInterface.ISpeedComponent;
	Replica: IReplicaData,
	Buses: {
		['Main'] : EventBusInterfaces.IEventBus;
		['Character'] : EventBusInterfaces.IEventBus;
	}
}

return {}
