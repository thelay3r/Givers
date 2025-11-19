local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ServerScriptService = game:GetService('ServerScriptService')
local RunService = game:GetService('RunService')

local Shared = ReplicatedStorage:WaitForChild('Shared')
local Utilites = Shared:WaitForChild('Utilities')
local Modules = Utilites:WaitForChild('Modules')
local TableHelper = require(Modules:WaitForChild('TableHelper'))
local ServerComponents = ServerScriptService:WaitForChild('Components')
local Interfaces = Shared:WaitForChild('Interfaces')

local PassiveInterfaces = require(Interfaces:WaitForChild('PassiveInterfaces'))
local AbstractPassives = require(ServerComponents:WaitForChild('AbsctractPassives'))

type IPassiveComponents = PassiveInterfaces.IPassive

local SessionData = {
	
	UserId = 'UserId';
	Instance = nil;
	Instances = {};
	
	CurrentEquipped = 'none';

	Attributes = 
		{
			Health = 100;
			MaxHealth = 100;
			
			WalkSpeed = 16;
			JumpPower = 50;
		};
	
	CharacterData = 
		{
			Character = nil :: Model;
			Humanoid = nil :: Humanoid;
			HumanoidRootPart = nil :: BasePart;
		};
	
	Equipment = 
		{
			Style = 'Fists';
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
	Passives = {}:: {IPassiveComponents};
	
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