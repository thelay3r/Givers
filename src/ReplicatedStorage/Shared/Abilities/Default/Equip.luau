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
		KeyCode = Enum.KeyCode.E;

		Duration = 1;
		CoolDown = 5;
		LastUsed = 0;

		IsActive = false;
	},
	{
		Name = 'Event.OnStart';
		Tag = 'OnStart';
		{
			Name = 'Action.SpawnProjectile';
			Tag = '111';

			Config = {
				Speed = 1,
				Direction = Vector3.new(0,0,1),
				StartVelocity = 10,
				Damage = 15,
			};
		{
			Name = 'Condition.CheckBlackList';
			RequestedTags = {
				['OnStart'] = 'OnStart';
				['Owner'] = 'Owner';
			};

			{
				Name = 'Action.SetAbilityActive';
				Config = {Status = true};
			};
			{
				Name = 'Action.SetCoolDown';
			};

		}
		};

		
	};
	{
		Name = 'Event.OnStop';
		Tag = 'OnStop';
		{
			Name = 'Condition.IsActive?';
			RequestedTags = {['Ability'] = 'Main'};
			
			{
				Name = 'Action.SpawnProjectile';
				Config = {
					Speed = 1,
					Direction = Vector3.new(0,0,1),
					StartVelocity = 10,
					Damage = 15,
				}

			};
			{
				Name = 'Action.SetCoolDown';
				Config = {Status = false};
			};

		};
		
	}    
}

return {
	Ability = ability,
	Registry = registry,
}