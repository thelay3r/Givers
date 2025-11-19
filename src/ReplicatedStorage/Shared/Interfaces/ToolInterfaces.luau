
export type IToolMethods = {
	new: (self: IToolMethods) -> ();
	BindToEquip: (callback: () -> {}) -> ();
	BindToUnequip: (callback: () -> {}) -> ();
	BindToDown: (callback: () -> {}) -> ();
	BindToUp: (callback: () -> {}) -> ();
	BindToClick: (callback: () -> {}) -> ();
	OnCallback: (name: string, any) -> ();
	BindToCallback: (name: string, callback: (...any) -> {}) -> ();
	BindToDestroy: (callback: () -> {}) -> ();
}

export type IToolComponents = IToolMethods & {
	Instance: Tool;
	Equipped: boolean;
	Activated: boolean;
	
	OnEquip: {};
	OnUnequip: {};
	OnClick: {};
	OnDown: {};
	OnUp: {};
	OnDestroy: {};
	
	CallBacks: {};
	
	Config: 
		{
			Name: string;
			Scope: string;
			Type: string;
			LastUsed: number;
			Duration: number;
			MinDuration: number;
			
		};
	
	Tasks: {};
	Threads: {};
}

return {}
