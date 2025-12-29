

export type NpcHandlerMethods = 
	{
		new: (Part: BasePart) -> NPcHandlerComponent;
		_Create: (self:NPcHandlerComponent) -> ();
		_CreateModel: (self:NPcHandlerComponent) -> Model;
		_SpawnBranch: (self: NPcHandlerComponent)-> ();
	}

export type NPcHandlerComponent = NpcHandlerMethods &
	{
		AliveNPCs: {};
		Count: number;
		Active: boolean;
		NpcName: string;
		Type: string;
		_Instance: BasePart;
	}


return {}