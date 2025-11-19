local ReplicatedStorage = game:GetService('ReplicatedStorage')

local Shared = ReplicatedStorage:WaitForChild('Shared')
local Utilites = Shared:WaitForChild('Utilities')
local Modules = Utilites:WaitForChild('Modules')
local TableHelper = require(Modules:WaitForChild('TableHelper'))
local Interfaces = Shared:WaitForChild('Interfaces')

local SessionData = {
	
	CharacterData = 
		{
			Character = nil :: Model;
			Humanoid = nil :: Humanoid;
			HumanoidRootPart = nil :: BasePart;
		};
	
	Controls = {};
	PressedKeys = {};
	Threads = {};
	Tasks = {};
	Ticks = {};
	
	Packs = {};
	Abilities = {};
	OnCooldown = {};
	Camera = 
		{
			WorkspaceCamera = {};
			Shaker = {};
		};
	
	ClientAbilities = {
		
		Packs = {};
		Abilities = {};

	};
	
	Replica = {};
	AdditionalInfo  = 
		{
			_lastPosition = Vector3.zero
		};
	StatusEffects = 
		{
			Stun = false;
			
			Dashing = false;
			Vaulting = false;
			IsRunning = false;
			
			Simulation = true;
			
			CameraRotation = true;
			AutoRotate = true;
			
		};
	
}

return function(): typeof(SessionData)
	return TableHelper:DeepTableClone(SessionData)
end