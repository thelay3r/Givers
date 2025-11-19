export type Connection = {
	Disconnect: (self: Connection) -> (),
	Connected: boolean
}

export type SignalMethods = {
	Connect: (self: Signal, callback: (...any) -> ()) -> Connection,
	Once: (self: Signal, callback: (...any) -> ()) -> Connection,
	Fire: (self: Signal, ...any) -> (),
	DisconnectAll: (self: Signal) -> (),
	Destroy: (self: Signal) -> (),
}

export type ISignal = SignalMethods & {}

return {}