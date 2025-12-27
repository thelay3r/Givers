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
						Name = 'Action.SetCoolDown';
					};
					Name = 'NetWork.PlayVFX';
					Config = {
						VFXType = 'Fists.Critical';
						VfxCFG = {
                       		State = 'Start';
							
                    	};
					}
						
				};
		};
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