
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Bricks = ReplicatedStorage:WaitForChild('Bricksv2')
local Components = Bricks:WaitForChild('Components')

local AbilityParseObject = require(Components:WaitForChild('AbilityParseObject'))
local Registry = require(Components:WaitForChild('Registry'))
local TreeNode = require(Components:WaitForChild('TreeNode'))
local Parser = require(Components:WaitForChild('Parser'))

local AbilityParser = {}
AbilityParser.__index = AbilityParser
setmetatable(AbilityParser, { __index = Parser })

type IAbilityParser = typeof(AbilityParseObject.new())


function AbilityParser.new()
	local self = setmetatable(Parser.new(), AbilityParser)
	return self
end

function AbilityParser:TransferIntoNodes(structure: any, parent: typeof(AbilityParseObject.new()))
	local children = {}
	
	if not structure.Name then return end
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

function AbilityParser:Execute(structure: any, parent: IAbilityParser)
	local tree = AbilityParser:TransferIntoNodes(structure, (parent) or (self))
	return tree:Execute()
end

function AbilityParser:Create(structure: any, parent: IAbilityParser)
	--local block = AbilityParseObject.new()
	print(parent, 'tag1')
	local oldMetaTable = getmetatable(parent)
	setmetatable(parent, {
		__index = function(t, i)
			return AbilityParser[i] or oldMetaTable[i]
		end,
	})
	
	parent.Tree = self:TransferIntoNodes(structure,parent)
	return parent
end

return AbilityParser