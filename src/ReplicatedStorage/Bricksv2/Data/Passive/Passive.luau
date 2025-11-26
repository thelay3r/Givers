local ServerScriptService = game:GetService('ServerScriptService')
local Bricks = ServerScriptService:WaitForChild('Bricksv2')

local Components = Bricks:WaitForChild('Components')
local Data = Bricks:WaitForChild('Data')
local Registries = Data:WaitForChild('Registries')

local Registry = require(Components:WaitForChild('Registry'))
local PassiveParser = require(Components:WaitForChild('PassiveParser'))

local behaviorRegistry = require(Registries:WaitForChild('PassiveBehaviorRegistry'))
local scopeRegistry = require(Registries:WaitForChild('ScopeRegistry'))

local parser = PassiveParser.new()

parser.BehaviorRegistry = behaviorRegistry
parser.ScopeRegistry = scopeRegistry

local passive = parser:Create({
	Name = 'Event.Test',
	Tag = 'Test123',
	{
		Name = 'Action.Hello',
		RequestedTags = {['Projectile'] = 'Test123'},
		Config = {
			123,
		}
	}
})

passive:Build()

return passive