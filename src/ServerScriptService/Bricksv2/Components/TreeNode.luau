local nodeCount = 0 --! come up with a better solution

local TreeNode = {}
TreeNode.__index = TreeNode

function TreeNode.new(config: any)
	local self = setmetatable({
		Id = nodeCount,
		Tag = (config and config.tag) or nil,
		Type = (config and config.type) or nil,
		Name = (config and config.name) or nil,
		Config = config.config or {},
		RequestedTags = (config and config.requestedTags or {}),
		Additional = {},
		Children = (config and config.children) or {},
		Parent = nil,
		InjectedCallback = (config and config.callback) or nil,
	}, TreeNode)

	-- ensure parent links for provided children
	for _, child in ipairs(self.Children) do
		if (not child) then continue end
		child.Parent = self
	end

	nodeCount += 1

	return self
end

function TreeNode:GetPath(): string
	local path = {}
	local current = self

	while current do
		table.insert(path, 1, (current.Type or "") .. (current.Name or ""))
		current = current.Parent
	end

	-- join with "/" for readability
	return table.concat(path, "/")
end

function TreeNode:GetRoot()
	local current = self

	while current.Parent do
		current = current.Parent
	end
	return current
end

function TreeNode:Execute()
	if (not self.InjectedCallback) then return end
	return self.InjectedCallback()
end

return TreeNode