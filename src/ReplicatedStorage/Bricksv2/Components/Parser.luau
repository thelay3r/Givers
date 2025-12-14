
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Bricks = ReplicatedStorage:WaitForChild('Bricksv2')
local Components = Bricks:WaitForChild('Components')

local Registry = require(Components:WaitForChild('Registry'))
local TreeNode = require(Components:WaitForChild('TreeNode'))

local Parser = {}
Parser.__index = Parser

function Parser.new()
	local self = setmetatable({}, Parser)

	return self
end

function Parser:TransferIntoNodes()
	-- to be implemented by subclasses
end

return Parser