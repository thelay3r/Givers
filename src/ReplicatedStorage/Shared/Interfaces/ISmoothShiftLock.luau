local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayerInterfaces = require(ReplicatedStorage.Shared.Interfaces.LocalPlayerInterfaces)

type Maid = {
	GiveTask: (self: Maid, task: any) -> any,
	DoCleaning: (self: Maid) -> (),
	[any]: any
}

type Spring = {
	Position: Vector3,
	Target: Vector3,
	Damper: number,
	Speed: number,
	[any]: any
}

export type ISmoothShiftLock = {
	Enabled: boolean,
	ModedPlayer: LocalPlayerInterfaces.IClientPlayerComponent,
	
	_runtimeMaid: Maid,
	_shiftlockMaid: Maid,
	_cameraOffsetSpring: Spring,
	
	Character: Model?,
	Torso: BasePart?,
	RootPart: BasePart?,
	Humanoid: Humanoid?,
	Head: BasePart?,

	Enable: (self: ISmoothShiftLock) -> (),
	Disable: (self: ISmoothShiftLock) -> (),
	IsEnabled: (self: ISmoothShiftLock) -> boolean,
	ToggleShiftLock: (self: ISmoothShiftLock, Enable: boolean?) -> (),

	_refreshCharacterVariables: (self: ISmoothShiftLock) -> (),
	_doShiftLockSwitch: (self: ISmoothShiftLock, Name: string, State: Enum.UserInputState, Input: InputObject) -> Enum.ContextActionResult,
	_updateMouseState: (self: ISmoothShiftLock) -> (),
	_updateMouseIcon: (self: ISmoothShiftLock) -> (),
	_transitionLockOffset: (self: ISmoothShiftLock) -> (),
}

return {}
