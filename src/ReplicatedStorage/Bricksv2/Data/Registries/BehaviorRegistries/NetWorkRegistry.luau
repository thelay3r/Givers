local ReplicatedStorage = game:GetService('ReplicatedStorage')
local RunService = game:GetService("RunService")

local Bricks = ReplicatedStorage:WaitForChild('Bricksv2')

local Shared = ReplicatedStorage:WaitForChild('Shared')
local Modules = ReplicatedStorage:WaitForChild('Modules')
local Utilities = Modules:WaitForChild('Utilities')
local Controllers = Modules:WaitForChild('Controllers')
local NetWork = Modules:WaitForChild('NetWork')
local PlayerInterfaces = require(ReplicatedStorage.Shared.Interfaces.PlayerInterfaces)
local Enums = require(Utilities.Enums)
local SpeedComponent = require(Controllers:WaitForChild('SpeedController'))
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

local RemoteMap = {
	[Enums.EventType.Once] = function(self,node)
		local config = node.Config
		local eventData = config.EventData

		local selectedEvent = ((Replicator:GetRemote(config.Event)) or (GlobalEvent))

		assert(RunService:IsServer(),'{PlayRemoteEvent} | invocation allowed only on the server')
		selectedEvent:Fire(config['Player'], config.EventName, eventData)
	end;
	[Enums.EventType.Close] = function(self,node)
		local Owner = self.Tags['Owner'] 
		local Instance = Owner.Instance :: Player
		local Character = Instance.Character
		local RootPart = Character:FindFirstChild('HumanoidRootPart')

		local config = node.Config
		local eventData = config.EventData

		local selectedEvent = ((Replicator:GetRemote(config.Event)) or (GlobalEvent))
		assert(RunService:IsServer(),'{PlayRemoteEvent} | invocation allowed only on the server')

		local position = RootPart.Position or config.RemotePosition
		selectedEvent:FireInRadius(position, 512, config.EventName, eventData)
	end;
	[Enums.EventType.All] = function(self,node)
		local config = node.Config
		local eventData = config.EventData

		local selectedEvent = ((Replicator:GetRemote(config.Event)) or (GlobalEvent))

		if (RunService:IsClient()) then
			selectedEvent:Fire(config.EventName, eventData)
		else
			selectedEvent:FireAll(config.EventName, eventData)
		end
	end
}

NetworkRegistry:Register('TriggerEventNetwork', function(self, node) 
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
	local eventType = config.EventType
	RemoteMap[eventType](self,node)
end)

NetworkRegistry:Register('PlayVFX', function(self,node) 
	local Entity = self.Tags['Owner'] :: PlayerInterfaces.IServerPlayerComponent
	local Character = Entity.Instance.Character
	local RootPart = Character.PrimaryPart
end)

return NetworkRegistry