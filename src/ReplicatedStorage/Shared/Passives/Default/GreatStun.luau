local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Registry = require(ReplicatedStorage.Bricksv2.Components.Registry)
local Bricks = ReplicatedStorage.Bricksv2

local _Components = Bricks:WaitForChild('Components')
local Data = Bricks:WaitForChild('Data')
local _Registries = Data:WaitForChild('Registries')


local registry = Registry.new()

registry.Inject = {
    'GreatStun'
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
		Name = 'Event.OnGreatStun';
		Tag = 'OnGreatStun';
		{
			Name = 'Condition.InIFrame?';{
				Name = 'Action.GreatStun';
			}
		}
	}
}

return {
	Passive = passive,
	Registry = registry,
}