

local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Shared = ReplicatedStorage:WaitForChild('Shared')
local Components = Shared:WaitForChild('Components')
local VFXs = Shared:WaitForChild('VFXs')
local Assets = VFXs:FindFirstChild('Assets')


local Modules = ReplicatedStorage:WaitForChild('Modules')
local Utilities = Modules:WaitForChild('Utilities')
local CustomAnimator = require(Utilities:WaitForChild('Animator'):WaitForChild('AnimationsComponent'))
local TaskManager = require(Utilities:WaitForChild('TaskManager'))

local FistsVFXs = Assets:FindFirstChild('Fists')

local Animations = FistsVFXs:FindFirstChild('Animations')

local Equip = {}

local AnimationsData = require(script.AnimationsData)

Equip['Equip'] = function(Character: Model,status: boolean)
	local Animate = CustomAnimator.new(Character)

	local EquipAnimtion = Animate:Load(Animations.Equip,AnimationsData.Equip):Play(AnimationsData.Equip)
	
	
	TaskManager:CreateTask(Animate,'EquipIdle',EquipAnimtion.Length-.1,function()
		Animate:Load(Animations.Idle,AnimationsData.Idle)
		Animate:Load(Animations.Walk,AnimationsData.Walk)
		Animate:Swap(AnimationsData.Idle)
		Animate:Swap(AnimationsData.Walk)
	end)
	
	--Animator:ChangeTracks(Character, Animations)
end

Equip['Unequip'] = function(Character: Model,status: boolean)
	local Animate = CustomAnimator.new(Character)
	
	TaskManager:CancelTask(Animate,'EquipIdle')
	Animate:Stop(AnimationsData.Equip)
	Animate:Swap(
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
		})
	Animate:Swap(
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
		})
end



return Equip
