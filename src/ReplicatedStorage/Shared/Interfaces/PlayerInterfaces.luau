local ReplicatedStorage = game:GetService('ReplicatedStorage')

local Shared = ReplicatedStorage:WaitForChild('Shared')
local Templates = Shared.Templates

local SessionData = require(Templates:WaitForChild('SessionData'))
local ProfileStoreTemplate = require(Templates:WaitForChild('ProfileStoreTemplate'))

type ISessionData = typeof(SessionData())
type IProfileTemplate = typeof(ProfileStoreTemplate)

export type IReplicaServer = 
	{
		Set: (self: IReplicaServer, path: {string | number}, value: any)->();
		SetValues: (self: IReplicaServer,path: {string | number}, values: {[string]: any})->();
		TableInsert: (self: IReplicaServer,path: {string | number}, value: any, index: number?) -> number;
		TableRemove: (self: IReplicaServer,path: {string | number}, index: number)-> any;
		FireClient: (self: IReplicaServer,player: Player,any) -> ();
		FireAllClients: (self: IReplicaServer,any) ->();
		Replicate: (self: IReplicaServer,any) -> ();
		DontReplicate: (self: IReplicaServer,any) -> ();
		Subscribe: (self: IReplicaServer,player: Player) -> ();
		Unsubscribe: (self: IReplicaServer,player: Player) -> ();
		Identify: (self: IReplicaServer) -> string;
		IsActive: (self: IReplicaServer) -> boolean;
		Destroy: (self: IReplicaServer) -> ();
		Data: {
			Session : ISessionData;
			Profile : IProfileTemplate;
		};
	}

export type IServerPlayerMethods = {
	SetupCharacter: (self: IServerPlayerMethods) -> (),
	AppendPassive: (self: IServerPlayerMethods, scope : string, passiveName: string) -> (),
}

export type IServerPlayerComponent = IServerPlayerMethods & {
	Instance: Player,
	Replica: IReplicaServer,
}

return {}
