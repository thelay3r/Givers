local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Registry = require(ReplicatedStorage.Bricksv2.Components.Registry)
local Bricks = ReplicatedStorage.Bricksv2

local _Components = Bricks:WaitForChild('Components')
local Data = Bricks:WaitForChild('Data')
local _Registries = Data:WaitForChild('Registries')


local registry = Registry.new()

registry.Inject = {
    'Parry'
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
		Name = 'Event.OnBlockCast';
		Tag = 'OnBlockCast';
		{
			Name = 'Condition.OnCoolDown?';
			{
				Name = 'Action.Parry';
			},
			{
				Name = 'Action.SetUsed';
			}
		}
	},
	{
		Name = 'Event.OnHit';
		Tag = 'OnHit';
		{
			Name = 'Action.ParryHit';
		}
	}
}

return {
	Passive = passive,
	Registry = registry,
}