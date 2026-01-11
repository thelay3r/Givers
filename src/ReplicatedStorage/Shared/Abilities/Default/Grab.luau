local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Registry = require(ReplicatedStorage.Bricksv2.Components.Registry)
local Bricks = ReplicatedStorage.Bricksv2

local _Components = Bricks:WaitForChild('Components')
local Data = Bricks:WaitForChild('Data')
local _Registries = Data:WaitForChild('Registries')


local registry = Registry.new()

registry.Inject = {
	'Grab'
}

local ability = {
	Name = 'Action.Root';
	Tag = 'Main',
	Config = 
	{
		Name = 'Grab';

		KeyCode = Enum.KeyCode.V;

		Duration = 1e10;
		MinDuration = .5,
		CoolDown = 1.5;
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
					Name = 'Condition.UpGrab';
					{
						Name = 'Action.CheckGrab';
						Tag = 'CheckGrab'
					};
				};
				{
					Name = 'Condition.GrabDown';
					{
						Name = 'Action.UnGrab';
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