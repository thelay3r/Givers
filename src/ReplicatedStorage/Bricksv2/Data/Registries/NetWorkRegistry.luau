local ReplicatedStorage = game:GetService('ReplicatedStorage')
local RunService = game:GetService("RunService")

local Bricks = ReplicatedStorage:WaitForChild('Bricksv2')

local Shared = ReplicatedStorage:WaitForChild('Shared')
local Utilities = Shared:WaitForChild('Utilities')
local UtilModules = Utilities:WaitForChild('Modules')
local NetWork = Utilities:WaitForChild('NetWork')
local SpeedComponent = require(UtilModules:WaitForChild('SpeedController'))
local Replicator = require(NetWork:WaitForChild('Replicator'))

local Components = Bricks:WaitForChild('Components')
local Data = Bricks:WaitForChild('Data')
local _Registries = Data:WaitForChild('Registries')

local Registry = require(Components:WaitForChild('Registry'))
local _AbilityParser = require(Components:WaitForChild('AbilityParser'))

local networkRegistry = Registry.new()
local GlobalBindable = Replicator:GetRemote('BindableGlobal')
local GlobalEvent = Replicator:GetRemote('Global')

networkRegistry:Register('TriggerEvent', function(self, node) 
	if (not self.Events) then return end
	local handler = self.ScopeRegistry:Get('EventAction')

	local selectedBlock = self.Events[node.Config.TagName]
	
	selectedBlock.TriggerArgs = node.Config

	--selectedBlock.Config = node.Config

	self.Tags[node.Config.TagName] = node.Config

	if handler then handler(self, selectedBlock) end
end)

networkRegistry:Register('Feint', function(self,node) 
	GlobalBindable:Connect('Feint', function()
		self:Execute(
			{
				Name = 'Action.FeintDash';
				RequestedTags = {['BodyVelocity'] = 'BodyVelocityDash'};
			})
		GlobalBindable:Disconnect('Feint')
	end)
end)

networkRegistry:Register('UnBindFeint', function(self,node) 
	GlobalBindable:Disconnect('Feint')
end)

networkRegistry:Register('PlayVFX', function(self,node) 
	if (RunService:IsClient()) and (not node.Config.Client) then
		GlobalEvent:Fire('PlayVFX',node.Config)
	else
		GlobalBindable:BindableFire('PlayVFX',node.Config)
	end
end)

return networkRegistry