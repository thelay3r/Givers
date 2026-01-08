local ReplicatedStorage = game:GetService('ReplicatedStorage')
local RunService = game:GetService('RunService')

local Modules = ReplicatedStorage:WaitForChild('Modules')
local Handlers = Modules:WaitForChild('Handlers')
local Shared = ReplicatedStorage:WaitForChild('Shared')
local NetWork = Modules:WaitForChild('NetWork')
local Utilities = Modules:WaitForChild('Utilities')
local Interfaces = Shared:WaitForChild('Interfaces')

local Enums = require(Utilities.Enums)
local TaskManager = require(Utilities:FindFirstChild('TaskManager'))
local AnimationsComponent = require(Utilities.Animator:FindFirstChild('AnimationsComponent'))
local StateManager = require(Utilities:FindFirstChild('StateManager'))
local CountHadnler = require(Handlers:WaitForChild('CountHandler'))

local VFXs = Shared:WaitForChild('VFXs')
local StatesLibrary = Utilities:WaitForChild('StatesLibrary')
local Assets = VFXs:WaitForChild('Assets')
local DefaultAnimations = Assets:WaitForChild('Default'):WaitForChild('Animations')

local Handler = {}

function Handler.OnRunJump(Animate,ClientData,Count)
	Animate:Load(DefaultAnimations.JumpRun1,{
		Name = 'Jump';
		_Name = DefaultAnimations.JumpRun1.Name;
		Priority = Enum.AnimationPriority.Action2.Name;
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
		Priority = Enum.AnimationPriority.Action2.Name;
		Settings = 
			{
				['Speed']= 1;
				['Weight']= 1;
				['FadeTime']= .1;
			}
	})

	Animate:Play(
		{
			Name = 'Jump';
			_Name = 'JumpRun'..Count();
			Priority = Enum.AnimationPriority.Action2.Name;
		})
	Count:Increment()
end

function Handler.OnJump(Animate,ClientData,Count)
	Animate:Play(
		{
			Name = 'Jump';
			Priority = Enum.AnimationPriority.Action2.Name;
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
