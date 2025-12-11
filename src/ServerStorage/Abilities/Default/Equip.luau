local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Registry = require(ReplicatedStorage.Bricksv2.Components.Registry)

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
			
			{

			Name = 'Action.SpawnProjectile';
			Tag = '111';

			Config = {
				Speed = 1,
				Direction = Vector3.new(0,0,1),
				StartVelocity = 10,
				Damage = 15,
			}

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
			Name = 'Action.SetAbilityCoolDown';
			Config = {Status = false};
		};

		};
		
	}    
}

return {
	Ability = ability,
	Registry = registry,
}