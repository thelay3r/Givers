local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Registry = require(ReplicatedStorage.Bricksv2.Components.Registry)
local Bricks = ReplicatedStorage.Bricksv2

local _Components = Bricks:WaitForChild('Components')
local Data = Bricks:WaitForChild('Data')
local _Registries = Data:WaitForChild('Registries')


local registry = Registry.new()

registry.Inject = {
    'Hit'
}

local passive = {
	Name = 'Action.Root';
	Tag = 'Main',
	Config = 
	{
        LastStunTime = 0;
		Priority = 1;
	},
	{
		Name = 'Event.OnHit';
		Tag = 'OnHit';
		{
			Name = 'Action.Hit';
		}
	}
}

return {
	Passive = passive,
	Registry = registry,
}