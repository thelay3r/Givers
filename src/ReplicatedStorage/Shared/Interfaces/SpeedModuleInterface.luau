

export type SpeedModifier = {
	Name: string,
	Delta: number,
	PreviousSpeed: number,
	Type: 'Buff' | 'Debuff',
	Priority: number,
	AppliedAt: number,
}

export type SpeedComponentData = {
	DefaultSpeed: number,
	CurrentSpeed: number,
	LastSpeed: number,
	Cache: {[string]: SpeedModifier},
	PendingValidation: {[string]: SpeedModifier},
}

export type SpeedInfo = {
	Current: number,
	Default: number,
	Last: number,
	Max: number,
	Min: number,
	ModifierCount: number,
}

export type AmplifyConfig = {
	Name: string,
	Percent: number,
	UseBaseSpeed: boolean,
	Priority: number,
	ClearBuffsOnDebuff: boolean,
	Replicated: boolean,
}

export type RevertConfig = {
	Name: string,
	Replicated: boolean,
}

export type ISpeedComponent = {
	-- Данные
	Entity: any,
	Character: any,
	Humanoid: any,
	Data: SpeedComponentData,

	-- Приватные методы
	_SetSpeed: (self: ISpeedComponent, Speed: number) -> boolean,
	_ReportSpeedToServer: (self: ISpeedComponent, Speed: number) -> (),
	_ClearAllModifiers: (self: ISpeedComponent) -> (),

	-- Публичные методы
	Amplify: (self: ISpeedComponent, Data: AmplifyConfig) -> boolean,
	Revert: (self: ISpeedComponent, Data: RevertConfig) -> boolean,
	GetModifier: (self: ISpeedComponent, Name: string) -> SpeedModifier,
	GetAllModifiers: (self: ISpeedComponent) -> {[string]: SpeedModifier},
	GetSpeedInfo: (self: ISpeedComponent) -> SpeedInfo,
	ResetToDefault: (self: ISpeedComponent) -> (),
	SetConfig: (self: ISpeedComponent, NewConfig: {[string]: any}) -> (),
}

export type ISpeedController = {
	new: (Entity: any) -> ISpeedComponent,
	SetMaxSpeed: (maxSpeed: number) -> (),
	SetDebug: (enabled: boolean) -> (),
}

export type SpeedInfoReturn = {
	Current: number,
	Default: number,
	Last: number,
	Max: number,
	Min: number,
	ModifierCount: number,
}

return {
	SpeedModifier = {} :: SpeedModifier,
	SpeedComponentData = {} :: SpeedComponentData,
	SpeedInfo = {} :: SpeedInfo,
	AmplifyConfig = {} :: AmplifyConfig,
	RevertConfig = {} :: RevertConfig,
	ISpeedComponent = {} :: ISpeedComponent,
	ISpeedController = {} :: ISpeedController,
	SpeedInfoReturn = {}:: SpeedInfoReturn
}
