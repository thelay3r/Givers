local ReplicatedStorage = game:GetService('ReplicatedStorage')

local Shared = ReplicatedStorage:WaitForChild('Shared')
local Utilites = Shared:WaitForChild('Utilities')
local Modules = Utilites:WaitForChild('Modules')
local JumpPowerModuleInterface = require(ReplicatedStorage.Shared.Interfaces.JumpPowerModuleInterface)
local SpeedModuleInterface = require(ReplicatedStorage.Shared.Interfaces.SpeedModuleInterface)
local TableHelper = require(Modules:WaitForChild('TableHelper'))
local _Interfaces = Shared:WaitForChild('Interfaces')

local SessionData = {
	
	UserId = 'UserId';
	Instance = nil;
	Instances = {};
	
	CurrentEquipped = 'none';
	CurrentInArm = 'none';

	SpeedData = {
		DefaultSpeed = 12,
		CurrentSpeed = 12,
		LastSpeed = 12,
		Cache = {} :: {[string]: SpeedModuleInterface.SpeedModifier},
		PendingValidation = {},
		CanChange = true :: boolean
	};
	JumpData = {
		DefaultJump = 12,
		CurrentJump = 12,
		LastJump = 12,
		Cache = {} :: {[string]:	JumpPowerModuleInterface.JumpModifier},
		PendingValidation = {},
		CanChange = true :: boolean
	};

	Attributes = 
		{
			Posture = 0;
			MaxPosture = 100;

			Health = 100;
			MaxHealth = 100;
			
			WalkSpeed = 12;
			JumpPower = 50;

			AutoRotateSpeed = 3;

			AdditionalHealth = 0;
		};
	
	CharacterData = 
		{
			Character = nil :: any & Model;
			Humanoid = nil :: any & Humanoid;
			HumanoidRootPart = nil :: any & BasePart;
		};
	
	Equipment = 
		{
			Weapon = 'none';
			Armor = 'none';
			
		};
	
	StatusEffects = 
		{
			EquippedWeapon = false;
			Click = false;
			CurrentCombo = 0;
			
			Combat = false;

			Stun = false;
			ActiveSkill = false;
			Block = false;
			Parry = false;
			GreatStun = false;
			Ragdoll = false;
			KnockDown = false;
			IsDead = false;

			Carry = false;

			IFRAME = false;

			Dashing = false;
			Vaulting = false;
			IsRunning = false;

			InGrab = false;
			InGrip = false;
			
			AfterSpace = false;
			ByPass = false;
			
			CanBodySimulation = true;
			CanAutoRotate = true;
			CanRun = true;

			LockedStateBody = false;
			LockedStateRotate = false;
		};
	
	Packs = {};
	Abilities = {};
	Passives = {};
	
	PressedKeys = {};
	
	Settings = 
		{
			['Loaded'] = false;
		};
	Threads = {};
	Tasks = {};
	
}

return function(): typeof(SessionData)
	return TableHelper:DeepTableClone(SessionData)
end