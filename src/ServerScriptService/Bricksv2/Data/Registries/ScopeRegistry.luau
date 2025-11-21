local ServerScriptService = game:GetService('ServerScriptService')
local Bricks = ServerScriptService:WaitForChild('Bricksv2')

local Components = Bricks:WaitForChild('Components')
local Data = Bricks:WaitForChild('Data')
local Registries = Data:WaitForChild('Registries')

local Registry = require(Components:WaitForChild('Registry'))
local AbilityParser = require(Components:WaitForChild('AbilityParser'))

local scopeRegistry = Registry.new()

scopeRegistry:Register('Action', function(self, node) 
	for key, tag in pairs(node.RequestedTags or {}) do
		node.Additional[key] = self.Tags[tag] or {}
	end

	local behavior = self.BehaviorRegistry:Get(node.Name)
	if (behavior) then behavior(self, node) end
	if (node.Tag) then
		self.Tags[node.Tag] = node.Config --! maybe make tags immutable
	end

	for _, child in (node.Children or {}) do
		child:Execute()
	end
end)

scopeRegistry:Register('Condition', function(self,node) 

	for key, tag in pairs(node.RequestedTags or {}) do
		node.Additional[key] = self.Tags[tag] or {}
	end

	local validate = self.ConditionRegistry:Get(node.Name)
	if (validate) then validate = validate(self,node) end

	
	if not validate then return end
	for _, child in (node.Children or {}) do 
		child:Execute()
	end
	
	return validate
end)

scopeRegistry:Register('EventAction', function(self, node) 
	local behavior = self.BehaviorRegistry:Get(node.Name)
	if (behavior) then behavior(self, node) end

	for _, child in (node.Children or {}) do
		child:Execute()
	end
end)

scopeRegistry:Register('Event', function(self, node) 
	--local behavior = self.BehaviorRegistry:Get(node.Name)
	--if (behavior) then behavior(self, node) end
	if (self.Events[node.Tag]) then warn(node.Tag..' already exists!'); return end
	self.Events[node.Tag] = node
end)

return scopeRegistry