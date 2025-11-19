
local ServerScriptService = game:GetService('ServerScriptService')
local Bricks = ServerScriptService:WaitForChild('Bricksv2')
local Components = Bricks:WaitForChild('Components')

local Registry = require(Components:WaitForChild('Registry'))
local TreeNode = require(Components:WaitForChild('TreeNode'))
local Parser = require(Components:WaitForChild('Parser'))


local AbilityParser = {}
AbilityParser.__index = AbilityParser
setmetatable(AbilityParser, { __index = Parser })

function AbilityParser.new()
	local self = setmetatable(Parser.new(), AbilityParser)
	self.BehaviorRegistry = Registry.new()

	return self
end

function AbilityParser:TransferIntoNodes(structure: any)
	local children = {}

	local splitted = string.split(structure.Name :: string, '.')
	if (#splitted < 2) then return end

	for key, child in pairs(structure) do
		if (typeof(key) ~= 'number') then continue end
		local childNode = self:TransferIntoNodes(child, key)
		table.insert(children, childNode)
	end

	local rootNode = TreeNode.new({
		type = splitted[1],
		name = splitted[2],
		children = children,
		config = structure.Config,
		tag = structure.Tag,
		requestedTags = structure.RequestedTags
	})

	local scope = self.ScopeRegistry:Get(splitted[1])

	rootNode.InjectedCallback = function()
		if (not scope) then return end
		scope(self, rootNode)
	end

	return rootNode
end

function AbilityParser:Execute(structure: any)
	local block = self:TransferIntoNodes(structure)
	block:Execute()
end

function AbilityParser:Create(structure: any)
	self.Tree = self:TransferIntoNodes(structure)
	return self
end

function AbilityParser:Build()
	self.Tree:Execute()
end

return AbilityParser