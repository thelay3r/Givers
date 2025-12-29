local ServerScriptService = game:GetService('ServerScriptService')
local Bricks = ServerScriptService:WaitForChild('Bricksv2')

local Components = Bricks:WaitForChild('Components')
local Data = Bricks:WaitForChild('Data')
local Registries = Data:WaitForChild('Registries')

local Registry = require(Components:WaitForChild('Registry'))
local AbilityParser = require(Components:WaitForChild('AbilityParser'))

local behaviorRegistry = require(Registries:WaitForChild('BehaviorRegistry'))
local scopeRegistry = require(Registries:WaitForChild('ScopeRegistry'))

local parser = AbilityParser.new()

local behaviorRegistry2 = Registry.new():Clone(behaviorRegistry)

behaviorRegistry2:Register('Root', function(...: any)  
end)

parser.BehaviorRegistry = behaviorRegistry2
parser.ScopeRegistry = scopeRegistry

local ability = parser:Create({
	Name = 'Event.OnHit',
	Tag = 'OnHit12321',
	{
		Name = 'Action.Hello',
		Tag = 'Test',
		RequestedTags = {['OnHit'] = 'OnHit12321'},
		Config = {
			test = 123,
		},
		{
			Name = 'Action.Test',
			RequestedTags = {['OnHit'] = 'OnHit12321', ['Parent'] = 'Test'},
		}
	},
})

ability:Build()

return ability