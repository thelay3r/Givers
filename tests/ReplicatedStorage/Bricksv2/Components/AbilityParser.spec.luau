local t = require("itsfrank/frktest")
local loader = require("tests/helpers/loader")

-- Build mocks matching AbilityParser's dependencies and Roblox pieces
local function makeMocks(opts)
	opts = opts or {}

	-- Fake TreeNode
	local TreeNode = {}
	TreeNode.__index = TreeNode
	function TreeNode.new(data)
		local self = setmetatable({}, TreeNode)
		for k, v in pairs(data or {}) do self[k] = v end
		return self
	end

	-- Fake AbilityParseObject
	local ExecuteResult = opts.ExecuteResult or { ok = true, value = 123 }
	local APO = {}
	APO.__index = APO
	function APO.new()
		local self = setmetatable({}, APO)
		self.ScopeRegistry = {
			_map = opts.scopeMap or {},
			Get = function(reg, key)
				return reg._map[key]
			end,
		}
		self._executed = false
		return self
	end
	function APO:Execute()
		self._executed = true
		return ExecuteResult
	end

	-- Fake Parser base
	local Parser = {}
	Parser.__index = Parser
	function Parser.new()
		return setmetatable({}, Parser)
	end

	-- Registry (unused in current AbilityParser but required)
	local Registry = {}

	-- Fake minimal Roblox API and layout to satisfy module's top-level code
	local fakeGame = {
		Services = {
			ReplicatedStorage = {
				WaitForChild = function(self, name)
					-- Return nested tables to handle Bricksv2/Components
					if name == "Bricksv2" then
						return {
							WaitForChild = function(_, n)
								if n == "Components" then
									return {
										WaitForChild = function(_, cname)
											-- Not used directly here; require uses script.Parent.*
											return {}
										end,
									}
								end
								return {}
							end,
						}
					end
					return {}
				end,
			},
		},
		GetService = function(self, name)
			return self.Services[name]
		end,
	}

	-- Build a fake 'script' table with Parent containing our dependency modules
	local dependencyTable = {
		AbilityParseObject = APO,
		Registry = Registry,
		TreeNode = TreeNode,
		Parser = Parser,
	}

	-- Custom require that maps our dependency access by identity
	local function fakeRequire(target)
		-- AbilityParser does: require(script.Parent.AbilityParseObject) etc
		if target == dependencyTable.AbilityParseObject then return APO end
		if target == dependencyTable.Registry then return Registry end
		if target == dependencyTable.TreeNode then return TreeNode end
		if target == dependencyTable.Parser then return Parser end
		-- Fallback if a path string is used
		if type(target) == "string" then
			-- Allow requiring our helper again if needed
			if target == "tests/helpers/loader" then return loader end
		end
		error("Unknown require target: " .. tostring(target))
	end

	local scriptMock = {
		Parent = dependencyTable,
	}

	local inject = {
		require = fakeRequire,
		script = scriptMock,
		game = fakeGame,
	}

	return {
		inject = inject,
		mocks = {
			TreeNode = TreeNode,
			AbilityParseObject = APO,
			Parser = Parser,
			Registry = Registry,
		},
	}
end

local function loadAbilityParser(inject)
	return loader.loadModule("src/ReplicatedStorage/Bricksv2/Components/AbilityParser.luau", inject)
end

return t.describe("AbilityParser", function()
	
	t.it("Should return nil when structure name has no dot", function()
		local ctx = makeMocks()
		local AbilityParser = loadAbilityParser(ctx.inject)

		local parser = AbilityParser.new()
		local res = parser:TransferIntoNodes({ Name = "InvalidName" }, ctx.mocks.AbilityParseObject.new())
		t.expect(res).toEqual(nil)
	end)

	t.it("Should build TreeNode and propagate fields", function()
		local ctx = makeMocks()
		local AbilityParser = loadAbilityParser(ctx.inject)
		local parser = AbilityParser.new()

		local structure = {
			Name = "Type.Name",
			Config = { A = 1 },
			Tag = { T = true },
			RequestedTags = { "X" },
			SendParams = { P = 0 },
		}
		local node = parser:TransferIntoNodes(structure, ctx.mocks.AbilityParseObject.new())

		t.expect(node.type).toEqual("Type")
		t.expect(node.name).toEqual("Name")
		t.expect(node.config).toEqual(structure.Config)
		t.expect(node.tag).toEqual(structure.Tag)
		t.expect(node.requestedTags).toEqual(structure.RequestedTags)
		t.expect(node.sendParams).toEqual(structure.SendParams)
	end)

	t.it("Should recursively parse numeric-indexed children", function()
		local ctx = makeMocks()
		local AbilityParser = loadAbilityParser(ctx.inject)
		local parser = AbilityParser.new()

		local structure = {
			Name = "Root.Node",
			[1] = { Name = "Child.One" },
			[2] = { Name = "Child.Two", [1] = { Name = "Leaf.End" } },
			Key = "not-child",
		}
		local node = parser:TransferIntoNodes(structure, ctx.mocks.AbilityParseObject.new())

		t.expect(#node.children).toEqual(2)
		t.expect(node.children[1].name).toEqual("One")
		t.expect(node.children[2].name).toEqual("Two")
		t.expect(#(node.children[2].children)).toEqual(1)
		t.expect(node.children[2].children[1].name).toEqual("End")
	end)

	t.it("InjectedCallback should call scope with parent and node and return result", function()
		local scopeReturn = { ok = true }
		local ctx = makeMocks({ scopeMap = {
			Root = function(parent, node)
				t.assert(parent ~= nil and node ~= nil)
				return scopeReturn
			end
		}})
		local AbilityParser = loadAbilityParser(ctx.inject)
		local parser = AbilityParser.new()

		local parent = ctx.mocks.AbilityParseObject.new()
		local node = parser:TransferIntoNodes({ Name = "Root.Node" }, parent)
		local ret = node.InjectedCallback()
		t.expect(ret).toEqual(scopeReturn)
	end)

	t.it("InjectedCallback should be safe when scope missing", function()
		local ctx = makeMocks({ scopeMap = {} })
		local AbilityParser = loadAbilityParser(ctx.inject)
		local parser = AbilityParser.new()

		local parent = ctx.mocks.AbilityParseObject.new()
		local node = parser:TransferIntoNodes({ Name = "NoScope.Node" }, parent)
		local ok, res = pcall(function()
			return node.InjectedCallback()
		end)
		t.expect(ok).toEqual(true)
		t.expect(res).toEqual(nil)
	end)

	t.it("Execute should build block and call its Execute, returning its value", function()
		local expected = { ok = true, value = 999 }
		local ctx = makeMocks({ ExecuteResult = expected })
		local AbilityParser = loadAbilityParser(ctx.inject)
		local parser = AbilityParser.new()

		local result = parser:Execute({ Name = "Root.Node" })
		t.expect(result).toEqual(expected)
	end)

	t.it("Create should return block with Tree set", function()
		local ctx = makeMocks()
		local AbilityParser = loadAbilityParser(ctx.inject)
		local parser = AbilityParser.new()

		local block = parser:Create({ Name = "Root.Node" })
		t.expect(block).toBeTruthy()
		t.expect(block.Tree).toBeTruthy()
		t.expect(block.Tree.name).toEqual("Node")
	end)

	t.it("Should tolerate missing optional fields", function()
		local ctx = makeMocks()
		local AbilityParser = loadAbilityParser(ctx.inject)
		local parser = AbilityParser.new()

		local node = parser:TransferIntoNodes({ Name = "A.B" }, ctx.mocks.AbilityParseObject.new())
		t.expect(node.config).toEqual(nil)
		t.expect(node.tag).toEqual(nil)
		t.expect(node.requestedTags).toEqual(nil)
		t.expect(node.sendParams).toEqual(nil)
	end)
end)
