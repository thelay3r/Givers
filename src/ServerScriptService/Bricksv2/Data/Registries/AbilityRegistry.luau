
local ServerScriptService = game:GetService('ServerScriptService')
local Bricks = ServerScriptService:WaitForChild('Bricksv2')

local Components = Bricks:WaitForChild('Components')
local Data = Bricks:WaitForChild('Data')
local Registries = Data:WaitForChild('Registries')

local Registry = require(Components:WaitForChild('Registry'))
local AbilityParser = require(Components:WaitForChild('AbilityParser'))

local behaviorRegistry = Registry.new()

behaviorRegistry:Register('Root', function(self, node)  
    print('New Root Behavior')
end)

behaviorRegistry:Register('SetAbilityActive', function(self, node)
	node:GetRoot().Config.IsActive = node.Config.Status
end)

behaviorRegistry:Register('SetCoolDown', function(self, node)
	node:GetRoot().Config.LastUsed = tick()
end)

behaviorRegistry:Register('ResetCoolDown', function(self, node)
	node:GetRoot().Config.LastUsed = 0
end)

return behaviorRegistry