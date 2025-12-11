
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Bricks = ReplicatedStorage:WaitForChild('Bricksv2')
local Components = Bricks:WaitForChild('Components')

local Registry = require(Components:WaitForChild('Registry'))
local TreeNode = require(Components:WaitForChild('TreeNode'))

local Object = {}
Object.__index = Object

local function _DestroyTree(children)
	if not children then return end
	for _, child in children do 
		_DestroyTree(child.Children)
		child:Destroy()
	end
end

function Object.new()
	local self = setmetatable({
		ScopeRegistry = Registry.new(),
        BehaviorRegistry = Registry.new(),
		Events = {},
		Tags = {},
		Threads = {},
		Tree = nil,
	}, Object)

	return self
end

function Object:Build()
	return self.Tree:Execute()
end

function Object:Destroy()
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

return Object