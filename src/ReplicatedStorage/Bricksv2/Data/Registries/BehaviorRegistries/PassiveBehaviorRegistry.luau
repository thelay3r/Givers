
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Bricks = ReplicatedStorage:WaitForChild('Bricksv2')

local Components = Bricks:WaitForChild('Components')
local Data = Bricks:WaitForChild('Data')
local _Registries = Data:WaitForChild('Registries')

local Registry = require(Components:WaitForChild('Registry'))
local _AbilityParser = require(Components:WaitForChild('AbilityParser'))

local behaviorRegistry = Registry.new()

behaviorRegistry:Register('TriggerEvent', function(self, node)  
	if (not self.Events) then return end
	local handler = self.ScopeRegistry:Get('EventAction')

	local selectedBlock = self.Events[node.Config.TagName]
		if not selectedBlock then
		self:Execute({
			Name = 'Event.'..node.Config.TagName;
			Tag = node.Config.TagName;
		})
		selectedBlock = self.Events[node.Config.TagName]
	end
	selectedBlock.TriggerArgs = node.Config

	self.Tags[node.Config.TagName] = node.Config

	if handler then handler(self, selectedBlock) end
end)

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