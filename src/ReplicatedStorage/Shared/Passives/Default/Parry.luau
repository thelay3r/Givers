local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Registry = require(ReplicatedStorage.Bricksv2.Components.Registry)
local Bricks = ReplicatedStorage.Bricksv2

local _Components = Bricks:WaitForChild('Components')
local Data = Bricks:WaitForChild('Data')
local _Registries = Data:WaitForChild('Registries')


local registry = Registry.new()

registry.Inject = {
    'Block'
}

local passive = {
	Name = 'Action.Root';
	Tag = 'Main',
	Config = 
	{
		LastStunTime = 0;
		CoolDown = 2;
		Priority = 3;
	},
	{
		Name = 'Event.OnCast';
		Tag = 'OnCast';
		{
			Name = 'Condition.CheckBlackList';
			{
				Name = 'Action.Parry';
			},
			{
				Name = 'Action.SetUsed';
			}
		}
	}
}

return {
	Passive = passive,
	Registry = registry,
}