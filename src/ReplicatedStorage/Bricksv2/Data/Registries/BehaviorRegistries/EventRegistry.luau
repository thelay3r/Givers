
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Bricks = ReplicatedStorage:WaitForChild('Bricksv2')

local Components = Bricks:WaitForChild('Components')
local Data = Bricks:WaitForChild('Data')
local _Registries = Data:WaitForChild('Registries')

local _AssetsHelper = require(ReplicatedStorage.Modules.Utilities.AssetsHelper)
local TaskManager = require(ReplicatedStorage.Modules.Utilities.TaskManager)
local Config = require(ReplicatedStorage.Modules.Physics.SmartBone.Dependencies.Config)
local Registry = require(Components:WaitForChild('Registry'))
local _AbilityParser = require(Components:WaitForChild('AbilityParser'))

local behaviorRegistry = Registry.new()

behaviorRegistry:Register('TriggerEvent', function(self, node) 
	if (not self.Events) then return end
	local handler = self.ScopeRegistry:Get('EventAction')


	local selectedBlock = self.Events[node.Config.TagName]
	if not selectedBlock then
		
		self:Execute({
			Name = 'Event.'..node.Config.TagName;
			Tag = node.Config.TagName;
		})
		selectedBlock = self.Events[node.Config.TagName]
	end
	selectedBlock.TriggerArgs = node.Config

	--selectedBlock.Config = node.Config
	self.Tags[node.Config.TagName] = node.Config

	if handler then handler(self, selectedBlock) end
end)

behaviorRegistry:Register('OnStart', function(self,node)
	self:Execute({
		Name = 'Action.SetAbilityPressed';
		Config = {
			Status = true;
		};
	})

end)

behaviorRegistry:Register('OnHit', function(self, node) 
	
end)

behaviorRegistry:Register('OnM1Start', function(self, node) 
	
end)
behaviorRegistry:Register('OnM1End', function(self, node) 
	
end)

behaviorRegistry:Register('OnDurationEnd', function(self,node)
	TaskManager:CancelAllTasks(node.TriggerArgs['node'])
	TaskManager:CancelAllThreads(node.TriggerArgs['node'])

	TaskManager:CancelAllThreads(self)
	TaskManager:CancelAllTasks(self)
	print('Ended?')
end)

behaviorRegistry:Register('OnStop', function(self,node)	
	self:Execute({
		Name = 'Action.SetAbilityPressed';
		Config = {
			Status = false;
		};
	})

end)


behaviorRegistry:Register('TriggerPassive', function(self, node)
	local info = node.Additional.Main
	
	for _, passive in pairs(info.Passives) do
		passive:Execute(
			{
				Name = 'Action.TriggerEvent',
				Config = {
					Projectile = node.Additional.Projectile,
					TagName = node.Config.PassiveEvent
				}
			})
	end
end)

return behaviorRegistry