local ReplicatedStorage = game:GetService('ReplicatedStorage')

local Shared = ReplicatedStorage:WaitForChild('Shared')
local Interfaces = Shared:WaitForChild('Interfaces')

export type IStatesMethods = {
	New: (StateModule: ModuleScript, BehaviorModule: ModuleScript, args: StatesInterfaces.Iargs) -> (),
	Get: (self: IStatesMethods) -> (),
	
	CheckBehavior: (self:StatesInterfaces.IStatesComponent) -> (),
	SortedBehaivors: (self: StatesInterfaces.IStatesComponent) -> (),
	
	ChangeState: (self: StatesInterfaces.IStatesComponent) -> (),
	
	ChangeUpdate: (self: IStatesMethods, Update: boolean) -> (),
	ChangeType: (self: IStatesMethods, Type: string) -> (),
	
}

export type IStatesComponent = IStatesMethods & {
	Folder : Folder;
	SectionName : string;
	BehaviorName : string;
	StateName: string;
	State : string;
	Behaivor : boolean;
	Update : boolean;
	Ignore: boolean;
	Parent: any;
	args : {};
	Tasks : {};
	Threads : {};
}

export type IBehavior = {
	check: (self: IStatesComponent) -> any;
	action: (self: IStatesComponent) -> any;
	name: string;
	priority: number;
}

export type IState = {
	check: (self: IStatesComponent) -> any;
}

export type Iargs = {
	FOLDER: Folder;
	SECTION_NAME: string;
	BEHAVIOR_NAME: string;
	STATE_NAME: string;
	PARENT: any;
	UPDATE: boolean;
	UPDATE_TIME: number;
	IGNORE: boolean;
	LOCK_MODE: boolean;
	LAUNCH: boolean;
}

return {}
