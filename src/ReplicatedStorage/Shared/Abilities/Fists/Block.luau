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
        Name = 'Fists_Block';
		KeyCode = Enum.KeyCode.F;

		Duration = 1e10;
		MinDuration = .1;
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
                    Name = 'Action.SetStatusEffect';
                    Config = {
                        Effect = 'Block';
			            Status = true;
                    }
                },
				{
					Name = 'Action.SetUsed'
				},
                {
                    Name = 'Action.SetStatusEffect';
                    Config = {
                        Effect = 'CanRun';
                        Status = false;
                    };
                };
				{
                    Name = 'Action.SetStatusEffect';
                    Config = {
                        Effect = 'ActiveSkill';
                        Status = true;
                    };
                };
				{
                    Name = 'Action.SetStatusEffect';
                    Config = {
                        Effect = 'ByPass';
                        Status = true;
                    };
                };
                {
                    Name = 'Action.SetAbilityActive';
                    Config = { Status = true; };
		        };
                {
                    Name = 'Action.PassiveTrigger';
					InjectParams = {['Victim'] = 'Owner'};
                    Config = {
                        ['Trigger'] = 'OnCast';
                    }
                };
				{
					Name = 'Network.PlayBindableEvent';
					InjectParams = {['Player'] = 'Owner.Instance'};
					Config = {
						EventName = 'PlayVFX';
						EventData = {
							VFXType = 'Fists.Block';
                       		State = 'OnStart';
                    	};
					}
				}
            }
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
			Name = 'Action.SetStatusEffect';
			Config = {
				Effect = 'ByPass';
				Status = false;
			};
		};
        {   
            Name = 'Action.SetStatusEffect';
            Config = {
                Effect = 'Block';
                Status = false;
            }
        };
		{
			Name = 'Action.SetAbilityActive';
			Config = { Status = false; };
		};
        {
			Name = 'Action.SetStatusEffect';
			Config = {
				Effect = 'CanRun';
				Status = true;
			};
		};
		{
			Name = 'Network.PlayBindableEvent';
			InjectParams = {['Player'] = 'Owner.Instance'};
			Config = {
				EventName = 'PlayVFX';
				EventData = {
					VFXType = 'Fists.Block';
					State = 'OnStop';
				};
			}
		}
	}  
}

return {
	Ability = ability,
	Registry = registry,
}