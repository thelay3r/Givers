local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Shared = ReplicatedStorage:WaitForChild('Shared')
local Utilities = Shared:WaitForChild('Utilities')
local UtilModules = Utilities:WaitForChild('Modules')
local Interfaces = Shared:WaitForChild('Interfaces')

local CacheInterface = require(Interfaces:WaitForChild('CacheContainerInterface'))

local CacheContainer = {}
CacheContainer.__index = CacheContainer

type ICache = typeof(CacheContainer)

local Container = {}

function CacheContainer.GetScope(self: ICache, Scope: any)
	if not Container[Scope] then
		Container[Scope] = {}
	end
	
	return Container[Scope]
end

--Prototype will be clonned
function CacheContainer.CreateInstance(self: ICache, Scope: any, Prototype: Instance): Instance
	local scope = self:GetScope(Scope)
	local instance = self:GetInstance(Scope)
	
	if (not instance) then instance = Prototype:Clone() end
	return instance
end

function CacheContainer.AddInstanceToCache(self: ICache, Scope: any, Object: Instance)
	local scope = self:GetScope(Scope)
	Object.Parent = nil
	table.insert(scope, Object)
end

function CacheContainer.GetInstance(self: ICache, Scope: any): Instance?
	local scope = self:GetScope(Scope)
	if (#scope < 1) then warn(`f{Scope} doesnt exist!`) end
	return table.remove(scope)
end


return CacheContainer
