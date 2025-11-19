local ReplicatedStorage = game:GetService('ReplicatedStorage')
local RunService = game:GetService('RunService')

local Shared = ReplicatedStorage:WaitForChild('Shared')
local Utilities = Shared:WaitForChild('Utilities')
local NetWork = Utilities:WaitForChild('NetWork')
local Modules = Utilities:WaitForChild('Modules')
local Interfaces = Shared:WaitForChild('Interfaces')

local TaskManager = require(Modules:FindFirstChild('TaskManager'))
local AnimationsComponent = require(Modules:FindFirstChild('AnimationsComponent'))
local StateManager = require(Modules:FindFirstChild('StateManager'))
local CountHadnler = require(Modules:WaitForChild('CountHandler'))

local VFXs = Shared:WaitForChild('VFXs')
local StatesLibrary = Utilities:WaitForChild('StatesLibrary')
local Assets = VFXs:WaitForChild('Assets')
local DefaultAnimations = Assets:WaitForChild('Default'):WaitForChild('Animations')
local EventBus = require(NetWork:WaitForChild('EventBus'))
local Listhener = require(script.Listhener)

local LocalPlayerInterfaces = require(Interfaces:WaitForChild('LocalPlayerInterfaces'))
local AnimationsInterfaces = require(Interfaces:WaitForChild('AnimationsInterfaces'))

local Animator = {}

type IAnimation = AnimationsInterfaces.IAnimationsComponent


local CFGs = 
	{
		['Idle'] = 
		{
			Name = 'Idle';
			Priority = Enum.AnimationPriority.Idle.Name;
			_Name = 'DefaultIdle';

			Settings = 
			{
				Speed = 1;
				Weight = 1;
				FadeTime = .1;
			}
		};
		
		['Walk'] = 
		{
			Name = 'Walk';
			Priority = Enum.AnimationPriority.Movement.Name;
			_Name = 'DefaultWalk';

			Settings = 
			{
				Speed = 1;
				Weight = 1;
				FadeTime = .1;
			}

		};
		['Jump'] = 
		{
			Name = 'Jump';
			Priority = Enum.AnimationPriority.Action.Name;
			_Name = 'DefaultJump';

			Settings = 
			{
				Speed = 1;
				Weight = 1;
				FadeTime = .1;
			}
		};
		['Fall'] = 
		{
			Name = 'Fall';
			Priority = Enum.AnimationPriority.Action.Name;
			_Name = 'DefaultFall';

			Settings = 
			{
				Speed = 1;
				Weight = 1;
				FadeTime = .1;
			}
		};
		['LandHard'] = 
		{
			Name = 'LandHard';
			Priority = Enum.AnimationPriority.Action.Name;
			_Name = 'DefaultLandHard';

			Settings = 
			{
				Speed = 1;
				Weight = 1;
				FadeTime = .1;
			}
		};
	}


local DefaultSettings = 
	{
		Played = true;
		Speed = 1;
		Weight = 1;
		FadeTime = .1;
	}
local DefaultSettingsWithoutPlayed = 
	{
		Played = false;
		Speed = 1;
		Weight = 1;
		FadeTime = .1;
	}

local function DestroyAnimate(self: LocalPlayerInterfaces.IClientPlayerComponent)
	local Character: Model = self.Instance.Character
	
	if (Character:FindFirstChild('Animate')) then
		Character.Animate:Destroy()
	end
end

function Animator.InitAnimations(self: LocalPlayerInterfaces.IClientPlayerComponent)
	local Character: Model = self.Instance.Character
	local ClientData = self.ClientData
	local Humanoid: Humanoid = Character:FindFirstChildOfClass('Humanoid')
	DestroyAnimate(self)
	
	local Animate = AnimationsComponent.new(Character)
	Animate:Load(DefaultAnimations.Idle,CFGs.Idle):Play(CFGs.Idle)
	Animate:Load(DefaultAnimations.Walk,CFGs.Walk)
	Animate:Load(DefaultAnimations.Jump,CFGs.Jump)
	Animate:Load(DefaultAnimations.Fall,CFGs.Fall)
	Animate:Load(DefaultAnimations.LandHard,CFGs.LandHard)
	
	local States = StateManager:New(
		{
			FOLDER = StatesLibrary:FindFirstChild('Animations');
			SECTION_NAME = 'Movement';
			STATE_NAME = 'Animator';
			UPDATE = true;
			IGNORE = true;
			LOCK_MODE = false;
			LAUNCH = true;
			BEHAVIOR_NAME = 'Default';
			UPDATE_TIME = 1/60;
			['Player'] = self;
			PARENT = Character;
		})
	
	local Count = CountHadnler.Create('JumpCount',1,2)
	Listhener.Subscribe(Animate,ClientData,Count)
	
	Humanoid.Died:Once(function()
		--States:Destroy()
		Animate:Destroy()
	end)

end

function Animator.InitNPCAnimations(NPC: Model)
	local Humanoid: Humanoid = NPC:FindFirstChildOfClass('Humanoid')
	
	task.wait(5)
	
	local Animate = AnimationsComponent.new(NPC)
	Animate:Load(DefaultAnimations.Idle,CFGs.Idle):Play(CFGs.Idle)
	Animate:Load(DefaultAnimations.Walk,CFGs.Walk)
	Animate:Load(DefaultAnimations.Jump,CFGs.Jump)
	Animate:Load(DefaultAnimations.Fall,CFGs.Fall)
	Animate:Load(DefaultAnimations.LandHard,CFGs.LandHard)
	
	local MainBus = EventBus.new('Player')
	
	--local States = StateManager:New(
	--	{
	--		FOLDER = StatesLibrary:FindFirstChild('NPcAnimations');
	--		SECTION_NAME = 'NPCMovement';
	--		STATE_NAME = 'Animator';
	--		UPDATE = true;
	--		LOCK_MODE = false;
	--		LAUNCH = true;
	--		BEHAVIOR_NAME = 'Default';
	--		UPDATE_TIME = 1/60;
	--		['NPC'] = NPC;
	--		PARENT = NPC;
	--	})
	

	
	Humanoid.Died:Once(function()
		Animate:Destroy()
	end)

end

return Animator