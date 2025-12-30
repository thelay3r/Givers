local ReplicatedStorage = game:GetService('ReplicatedStorage')

local Shared = ReplicatedStorage:WaitForChild('Shared')
local Utilites = Shared:WaitForChild('Utilities')
local Modules = Utilites:WaitForChild('Modules')
local SpeedModuleInterface = require(ReplicatedStorage.Shared.Interfaces.SpeedModuleInterface)
local TableHelper = require(Modules:WaitForChild('TableHelper'))
local Interfaces = Shared:WaitForChild('Interfaces')

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
	};

	Attributes = 
		{
			Health = 100;
			MaxHealth = 100;
			
			WalkSpeed = 16;
			JumpPower = 50;
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
			
			Stun = false;
			ActiveSkill = false;
			Block = false;
			Parry = false;
			GreatStunned = false;
			Ragdolled = false;
			NockDown = false;
			IsDead = false;
			
			Dashing = false;
			Vaulting = false;
			IsRunning = false;

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