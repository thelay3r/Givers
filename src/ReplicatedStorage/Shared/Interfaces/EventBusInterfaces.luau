export type EventBusMethods = {
	Subscribe: (self: EventBusMethods, eventName: string, callback: (...any) -> ()) -> Connection,
	Once: (self: EventBusMethods, eventName: string, callback: (...any) -> ()) -> Connection,
	Fire: (self: EventBusMethods, eventName: string, ...any) -> (),
	Unsubscribe: (self: EventBusMethods, eventName: string, connection: Connection) -> (),
	Destroy: (self: EventBusMethods) -> (),
}

export type IEventBus = EventBusMethods & {
	
}

return {}