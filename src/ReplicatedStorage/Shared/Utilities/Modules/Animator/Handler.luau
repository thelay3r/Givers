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

local Handler = {}

function Handler.OnRunJump(Animate,ClientData,Count)
	Animate:Load(DefaultAnimations.JumpRun1,{
		Name = 'Jump';
		_Name = DefaultAnimations.JumpRun1.Name;
		Priority = Enum.AnimationPriority.Action.Name;
		Settings = 
			{
				['Speed']= 1;
				['Weight']= 1;
				['FadeTime']= .1;
			}
	})

	Animate:Load(DefaultAnimations.JumpRun2,{
		Name = 'Jump';
		_Name = DefaultAnimations.JumpRun2.Name;
		Priority = Enum.AnimationPriority.Action.Name;
		Settings = 
			{
				['Speed']= 1;
				['Weight']= 1;
				['FadeTime']= .1;
			}
	})

	Animate:Swap(
		{
			Name = 'Jump';
			_Name = 'JumpRun'..Count();
			Priority = Enum.AnimationPriority.Action.Name;
		})
	Count:Increment()
end

function Handler.OnJump(Animate,ClientData,Count)
	if ClientData.StatusEffects.IsRunning then return Handler.OnRunJump(Animate,ClientData,Count) end

	Animate:Swap(
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
		})
	
end




return Handler
