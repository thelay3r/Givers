return {
	Name = 'Action.Root';
	Tag = 'Main',
	Config = 
	{
		KeyCode = Enum.KeyCode.E;

		Duration = 1;
		CoolDown = 5;
		LastUsed = 0;
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
			RequestedTags = {['OnStart'] = 'OnStart'},
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
}