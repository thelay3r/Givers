local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Registry = require(ReplicatedStorage.Bricksv2.Components.Registry)
local Bricks = ReplicatedStorage.Bricksv2

local _Components = Bricks:WaitForChild('Components')
local Data = Bricks:WaitForChild('Data')
local _Registries = Data:WaitForChild('Registries')


local registry = Registry.new()

registry.Inject = {
	'Grip'
}

local ability = {
	Name = 'Action.Root';
	Tag = 'Main',
	Config = 
	{
		Name = 'Grip';

		KeyCode = Enum.KeyCode.B;

		Duration = 1e10;
		MinDuration = 0,
		CoolDown = .1;
		LastUsed = 0;
		IsActive = false;
	},
	{
		Name = 'Event.OnStart';
		Tag = 'OnStart';
		{
			Name = 'Condition.CheckBlackList';
			{
				Name = 'Action.SetUsed';
				{
					Name = 'Condition.UpGrip';
					{
						Name = 'Action.CheckGrip';
						Tag = 'CheckGrip'
					};
				};
				{
					Name = 'Condition.GripDown';
					{
						Name = 'Action.UnGrip';
					};
				}
			},	
		}
	}, 
}

return {
	Ability = ability,
	Registry = registry,
}