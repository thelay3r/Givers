
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Bricks = ReplicatedStorage:WaitForChild('Bricksv2')
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
		requestedTags = structure.RequestedTags,
		sendParams = structure.SendParams, 
	})


	local scope = self.ScopeRegistry:Get(splitted[1])

	rootNode.InjectedCallback = function()
		if (not scope) then return end
		return scope(self, rootNode)
	end

	return rootNode
end

function AbilityParser:Execute(structure: any)
	local block = self:TransferIntoNodes(structure)
	return block:Execute()
end

function AbilityParser:Create(structure: any)
	self.Tree = self:TransferIntoNodes(structure)
	return self
end

function AbilityParser:Build()
	return self.Tree:Execute()
end

local function _DestroyTree(childrens)
	if not childrens then return end
	for _,children in childrens do 
		_DestroyTree(children.Children)
		children:Destroy()
	end
end

function AbilityParser:Destroy()
	_DestroyTree(self.Tree.Children)
	self.Tree:Destroy()

	for name,v in pairs(self.ScopeRegistry.callbacks) do 
		self.ScopeRegistry.callbacks[name] = nil
	end
	for name,v in pairs(self.Tags) do 
		table.clear(v)
	end
	
	table.clear(self.ScopeRegistry)
	table.clear(self.Events)
	table.clear(self.BehaviorRegistry)

	self.Events = nil
	self.ScopeRegistry.callbacks = nil
	self.ScopeRegistry = nil
	self.BehaviorRegistry = nil
	self.Tags = nil
	self.Tree = nil
	
end

return AbilityParser