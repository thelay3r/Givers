export type FSM_Methods = {
	new: (owner: any, initState: string) -> ();
	AddState: (self: IFSM, State: string) -> ();
	ChangeState: (self: IFSM, newState: string) -> ();
	Update: (self: IFSM, DeltaTime: number) -> ();
	On: (self: IFSM, Event: string, Callback: (any)) -> ();
	Fire: (self: IFSM,Name: string, data: any,any)->();
}

export type IFSM = FSM_Methods & 
{
	Owner: any;
	CurrentState: string | nil; 
	States: 
		{
			[string]: {};
		};
	Listeners: 
		{
			[string]: {};
		};
	PreviousState : string | nil;
}


return {}