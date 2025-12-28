
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Bricks = ReplicatedStorage:WaitForChild('Bricksv2')

local Components = Bricks:WaitForChild('Components')
local Data = Bricks:WaitForChild('Data')
local _Registries = Data:WaitForChild('Registries')

local Registry = require(Components:WaitForChild('Registry'))
local _AbilityParser = require(Components:WaitForChild('AbilityParser'))

local behaviorRegistry = Registry.new()


local function hello(msg)
	print(msg)
end
behaviorRegistry:Register('Test', function(self, node)
	hello('Test')
end)
behaviorRegistry:Register('Hello', function(self, node)
	print(node)
	hello('print')
end)

return behaviorRegistry