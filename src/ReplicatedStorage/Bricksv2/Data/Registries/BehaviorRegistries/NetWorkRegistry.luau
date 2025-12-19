local ReplicatedStorage = game:GetService('ReplicatedStorage')
local RunService = game:GetService("RunService")

local Bricks = ReplicatedStorage:WaitForChild('Bricksv2')

local Shared = ReplicatedStorage:WaitForChild('Shared')
local Utilities = Shared:WaitForChild('Utilities')
local UtilModules = Utilities:WaitForChild('Modules')
local NetWork = Utilities:WaitForChild('NetWork')
local PlayerInterfaces = require(ReplicatedStorage.Shared.Interfaces.PlayerInterfaces)
local SpeedComponent = require(UtilModules:WaitForChild('SpeedController'))
local Replicator = require(NetWork:WaitForChild('Replicator'))

local Components = Bricks:WaitForChild('Components')
local Data = Bricks:WaitForChild('Data')
local _Registries = Data:WaitForChild('Registries')

local Registry = require(Components:WaitForChild('Registry'))
local _AbilityParser = require(Components:WaitForChild('AbilityParser'))

local NetworkRegistry = Registry.new()
local GlobalBindable = Replicator:GetRemote('BindableGlobal')
local GlobalEvent = Replicator:GetRemote('Global')
local VFXEvent = Replicator:GetRemote('VFX')


NetworkRegistry:Register('TriggerEvent', function(self, node) 
	if (not self.Events) then return end
	local handler = self.ScopeRegistry:Get('EventAction')

	local selectedBlock = self.Events[node.Config.TagName]
	
	selectedBlock.TriggerArgs = node.Config

	--selectedBlock.Config = node.Config

	self.Tags[node.Config.TagName] = node.Config

	if handler then handler(self, selectedBlock) end
end)

NetworkRegistry:Register('Feint', function(self,node) 
	GlobalBindable:Connect('Feint', function()
		self:Execute(
			{
				Name = 'Action.FeintDash';
				RequestedTags = {['BodyVelocity'] = 'BodyVelocityDash'};
			})
		GlobalBindable:Disconnect('Feint')
	end)
end)

NetworkRegistry:Register('UnBindFeint', function(self,node) 
	GlobalBindable:Disconnect('Feint')
end)

NetworkRegistry:Register('PlayBindableEvent', function(self, node)  
	local config = node.Config
	local eventData = config.EventData

	GlobalBindable:BindableFire(config.EventName, eventData)
end)

NetworkRegistry:Register('PlayRemoteEvent', function(self, node)  
	local config = node.Config
	local eventData = config.EventData

	local eventType = config.EventType
	local selectedEvent = config.Event or GlobalEvent

	-- make into enums
	if (eventType == 'One') then -- beautify this thing somehow
		if (RunService:IsClient()) then return end
		selectedEvent:Fire(config['Player'], config.EventName, eventData)
		return
	end

	if (eventType == 'Close') then
		if (RunService:IsClient()) then return end
		local position = config['Player'].Character.PrimaryPart.Position or config.RemotePosition
		-- refactor this pls ^ (asserts, etc)
		selectedEvent:FireInRadius(position, 512, config.EventName, eventData)
		return
	end

	if (RunService:IsClient()) then
		selectedEvent:Fire(config.EventName, eventData)
	else
		selectedEvent:FireAll(config.EventName, eventData)
	end

end)

NetworkRegistry:Register('PlayVFX', function(self,node) 
	local Entity = self.Tags['Owner'] :: PlayerInterfaces.IServerPlayerComponent
	local Character = Entity.Instance.Character
	local RootPart = Character.PrimaryPart

	

end)

return NetworkRegistry