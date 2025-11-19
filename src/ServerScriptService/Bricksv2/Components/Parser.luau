
local ServerScriptService = game:GetService('ServerScriptService')
local Bricks = ServerScriptService:WaitForChild('Bricksv2')
local Components = Bricks:WaitForChild('Components')

local Registry = require(Components:WaitForChild('Registry'))
local TreeNode = require(Components:WaitForChild('TreeNode'))

local Parser = {}
Parser.__index = Parser

function Parser.new()
	local self = setmetatable({
		ScopeRegistry = Registry.new(),
		Events = {},
		Tags = {},
		Tree = nil,
	}, Parser)

	return self
end

function Parser:TransferIntoNodes()
	-- to be implemented by subclasses
end

return Parser