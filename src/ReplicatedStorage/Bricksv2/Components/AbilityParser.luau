
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Bricks = ReplicatedStorage:WaitForChild('Bricksv2')
local Components = Bricks:WaitForChild('Components')

local AbilityParseObject = require(script.Parent.AbilityParseObject)
local Registry = require(Components:WaitForChild('Registry'))
local TreeNode = require(Components:WaitForChild('TreeNode'))
local Parser = require(Components:WaitForChild('Parser'))


local AbilityParser = {}
AbilityParser.__index = AbilityParser
setmetatable(AbilityParser, { __index = Parser })

function AbilityParser.new()
	local self = setmetatable(Parser.new(), AbilityParser)
	return self
end

function AbilityParser:TransferIntoNodes(structure: any, parent: typeof(AbilityParseObject.new()))
	local children = {}

	local splitted = string.split(structure.Name :: string, '.')
	if (#splitted < 2) then return end

	for key, child in pairs(structure) do
		if (typeof(key) ~= 'number') then continue end
		local childNode = self:TransferIntoNodes(child, parent)
		table.insert(children, childNode)
	end

	local rootNode = TreeNode.new({
		type = splitted[1],
		name = splitted[2],
		children = children,
		config = structure.Config,
		tag = structure.Tag,
		requestedTags = structure.RequestedTags,
		sendParams = structure.SendParams, 
	})

	local scope = parent.ScopeRegistry:Get(splitted[1])

	rootNode.InjectedCallback = function()
		if (not scope) then return end
		return scope(parent, rootNode)
	end

	return rootNode
end

function AbilityParser:Execute(structure: any)
	local block = self:TransferIntoNodes(structure, AbilityParseObject.new())
	return block:Execute()
end

function AbilityParser:Create(structure: any)
	local block = AbilityParseObject.new()
	block.Tree = self:TransferIntoNodes(structure)
	return block
end

return AbilityParser