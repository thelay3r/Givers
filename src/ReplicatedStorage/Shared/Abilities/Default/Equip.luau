local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Registry = require(ReplicatedStorage.Bricksv2.Components.Registry)
local Bricks = ReplicatedStorage.Bricksv2

local _Components = Bricks:WaitForChild('Components')
local Data = Bricks:WaitForChild('Data')
local _Registries = Data:WaitForChild('Registries')


local registry = Registry.new()


local ability = {
	Name = 'Action.Root';
	Tag = 'Main',
	Config = 
	{
		Name = 'Equip';

		KeyCode = Enum.KeyCode.E;

		Duration = 1;
		MinDuration = 1,
		CoolDown = 1;
		LastUsed = 0;

		IsActive = false;
	},
	{
		Name = 'Event.OnStart';
		Tag = 'OnStart';
		{
			Name = 'Condition.CheckBlackList';
			{

				Name = 'Action.SwapWeapon';
				
			}

		}
	},
	{
		Name = 'Event.OnStop';
		Tag = 'OnStop';

		{
			Name = 'Condition.IsActive?',
		}
	}    
}

return {
	Ability = ability,
	Registry = registry,
}