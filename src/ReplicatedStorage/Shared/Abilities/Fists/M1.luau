local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Registry = require(ReplicatedStorage.Bricksv2.Components.Registry)
local Bricks = ReplicatedStorage.Bricksv2

local _Components = Bricks:WaitForChild('Components')
local Data = Bricks:WaitForChild('Data')
local _Registries = Data:WaitForChild('Registries')


local registry = Registry.new()

registry.Inject = {
	'M1Fists';
}

local ability = {
		Name = 'Action.Root';
		Tag = 'Main',
		Config = 
		{
			Name = 'Fists_M1';
			KeyCode = Enum.UserInputType.MouseButton1;

			Duration = .5;
			MinDuration = .5,
			CoolDown = .5;
			LastUsed = 0;

			IsActive = false;
		},
		{
			Name = 'Event.OnStart';
			Tag = 'OnStart';
			{	
				Name = 'Condition.IsEquipped?';
				{
					Name = 'Condition.CheckBlackList';
					{
						Name = 'Action.Combo';
						Config = {
							Combo = {
								'Fist';
							}
						},
						{
							Name = 'Action.SetUsed';
						};
						{
							Name = 'Action.SetAbilityActive';
							Config = {
								Status = true;
							};
						};
						{
							Name = 'Action.SetStatusEffect';
							Config = {
								Effect = 'ActiveSkill';
								Status = true;
							};
						};
					};
			};
		},

		
	},

	{
		Name = 'Event.OnDurationEnd'; 
		Tag = 'OnDurationEnd';
		{
			Name = 'Action.SetStatusEffect';
			Config = {
				Effect = 'ActiveSkill';
				Status = false; 
			};
		};
		{
			Name = 'Action.SetAbilityActive';
			Config = { Status = false; };
		};
	}
}

return {
	Ability = ability,
	Registry = registry,
}