local ReplicatedStorage = game:GetService('ReplicatedStorage')
local RunService = game:GetService("RunService")

local Bricks = ReplicatedStorage:WaitForChild('Bricksv2')

local Modules = ReplicatedStorage:WaitForChild('Modules')
local Utilities = Modules:WaitForChild('Utilities')
local Physics = Modules:WaitForChild('Physics')
local Controllers = Modules:WaitForChild('Controllers')
local NetWork = Modules:WaitForChild('NetWork')
local RegistryManager = require(ReplicatedStorage.Bricksv2.Components.RegistryManager)
local AssetsHelper = require(Utilities.AssetsHelper)
local BiezeModule = require(Physics.BiezeModule)
local TaskManager = require(Utilities.TaskManager)
local SpeedComponent = require(Controllers:WaitForChild('SpeedController'))
local Replicator = require(NetWork:WaitForChild('Replicator'))

local Components = Bricks:WaitForChild('Components')
local Data = Bricks:WaitForChild('Data')
local _Registries = Data:WaitForChild('Registries')

local Registry = require(Components:WaitForChild('Registry'))
local _AbilityParser = require(Components:WaitForChild('AbilityParser'))

local behaviorRegistry = Registry.new()
local GlobalBindable = Replicator:GetRemote('BindableGlobal')
local GlobalEvent = Replicator:GetRemote('Global')



behaviorRegistry:Register('Wait', function(self, node)  
	task.wait(node.Config.Wait)
end)

behaviorRegistry:Register('Extend', function(self,node): any 
	local currentlyInjected = self.BehaviorRegistry._meta
	local tbInjected = RegistryManager:GetRegistriesToInject(node.Config)

	for _, inject in pairs(tbInjected) do
		table.insert(currentlyInjected, inject)
	end
end)

behaviorRegistry:Register('Raycast', function(self,node)
	local config = node.Config

	local castData = {
		Position = config.Position;
		Direction = config.Direction;
		Character = config.Character
	}
	local cast = AssetsHelper.FastCast(castData)

	node.Config['Cast'] = cast
	if not cast then return false end
	return cast
end)


return behaviorRegistry