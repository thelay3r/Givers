local ReplicatedStorage = game:GetService('ReplicatedStorage')

local Shared = ReplicatedStorage:WaitForChild('Shared')
local Utilites = Shared:WaitForChild('Utilities')
local Modules = Utilites:WaitForChild('Modules')
local TableHelper = require(Modules:WaitForChild('TableHelper'))
local Interfaces = Shared:WaitForChild('Interfaces')

local animator: Animator



local AnimatorData = {
	
	Character = nil :: Model;
	Animator = nil :: Animator;
	Tracks = 
		{
			[Enum.AnimationPriority.Core.Name] = {};
			[Enum.AnimationPriority.Idle.Name] = {};
			[Enum.AnimationPriority.Movement.Name] = {};
			[Enum.AnimationPriority.Action.Name] = {};
			[Enum.AnimationPriority.Action2.Name] = {};
			[Enum.AnimationPriority.Action3.Name] = {};
			[Enum.AnimationPriority.Action4.Name] = {};
		}
}

return function(): typeof(AnimatorData)
	return TableHelper:DeepTableClone(AnimatorData)
end