local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Bricks = ReplicatedStorage:WaitForChild('Bricksv2')

local Components = Bricks:WaitForChild('Components')
local Data = Bricks:WaitForChild('Data')
local _Registries = Data:WaitForChild('Registries')

local Registry = require(Components:WaitForChild('Registry'))
local _AbilityParser = require(Components:WaitForChild('AbilityParser'))

local scopeRegistry = Registry.new()

local function traversePath(obj, path)
    if not path then return obj end
    for _, key in ipairs(path) do
        if not obj then break end
        obj = obj[key]
    end
    return obj
end

scopeRegistry:Register('Abilities', function(self, node) 
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
	
	return true
end)

scopeRegistry:Register('Ability', function(self, node) 
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
	
	return true
end)

return scopeRegistry