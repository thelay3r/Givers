return {
	Name = 'Action.Root';
	Tag = 'Main',
	Config = {},
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
			}

		}
	};      
}