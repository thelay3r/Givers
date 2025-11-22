local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage.Shared.Abilities.Movement.Dash.Config)
return {
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
			Config = 
			{
				Ignor = 
				{
					['Stun'] = true;
				}
			};
			RequestedTags = {['OnStart'] = 'OnStart'};

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
		}
		};
		
	}    
}