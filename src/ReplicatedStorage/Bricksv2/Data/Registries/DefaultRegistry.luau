
local ServerScriptService = game:GetService('ServerScriptService')
local Bricks = ServerScriptService:WaitForChild('Bricksv2')

local Components = Bricks:WaitForChild('Components')
local Data = Bricks:WaitForChild('Data')
local Registries = Data:WaitForChild('Registries')

local Registry = require(Components:WaitForChild('Registry'))
local AbilityParser = require(Components:WaitForChild('AbilityParser'))

local behaviorRegistry = Registry.new()

behaviorRegistry:Register('Wait', function(self, node)  
	task.wait(node.Config.Wait)
end)

behaviorRegistry:Register('Hello', function(self, node)
	--print(node.Additional['OnHit'])
	--print('hello', node.Config)
end)


return behaviorRegistry