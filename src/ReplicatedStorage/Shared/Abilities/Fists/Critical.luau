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
        Name = 'Fists_Critical';
		KeyCode = Enum.KeyCode.R;

		Duration = 1;
		MinDuration = .5;
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
					{
						Name = 'Action.SetUsed';
					};
					Name = 'Network.PlayBindableEvent';
					InjectParams = {['Player'] = 'Owner.Instance'};
					Config = {
						EventName = 'PlayVFX';
						EventData = {
							VFXType = 'Fists.Critical';
                       		State = 'Start';
                    	};
					}
				};
				{
					Name = 'Action.SetStatusEffect';
					Config = {
						Effect = 'ActiveSkill';
						Status = true; 
					};
				};
				{
					Name = 'Action.SetAbilityActive';
					Config = { Status = true; };
				};
		};
	}
	},
	{
		Name = 'Event.OnStop';
		Tag = 'OnStop';
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