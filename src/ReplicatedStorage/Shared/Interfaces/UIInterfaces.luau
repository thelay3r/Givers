export type ButtonComponent = {
	BindToClick: (self: ButtonComponent, callback: () -> ()) -> (),
	BindToEnter: (self: ButtonComponent, callback: () -> ()) -> (),
	BindToLeave: (self: ButtonComponent, callback: () -> ()) -> (),
	BindToDown: (self: ButtonComponent, callback: () -> ()) -> (),
	BindToUp: (self: ButtonComponent, callback: () -> ()) -> (),
	BindToDestroy: (self: ButtonComponent, callback: () -> ()) -> (),
	BindToCallback: (self: ButtonComponent, name: string, callback: (...any) -> ()) -> (),
	OnCallback: (self: ButtonComponent, name: string,any) -> (),

	Instance : GuiButton;
}


export type ButtonPrototype<K, T> = {
	['new']: (guiButton: GuiButton, ...K) -> ButtonComponent & T
}

export type MenuButtonPrototype = ButtonPrototype<
	{
		style: string?
	}>

return nil