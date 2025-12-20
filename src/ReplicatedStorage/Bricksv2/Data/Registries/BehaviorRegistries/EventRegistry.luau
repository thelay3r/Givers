
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Bricks = ReplicatedStorage:WaitForChild('Bricksv2')

local Components = Bricks:WaitForChild('Components')
local Data = Bricks:WaitForChild('Data')
local Registries = Data:WaitForChild('Registries')

local AssetsHelper = require(ReplicatedStorage.Shared.Utilities.Modules.AssetsHelper)
local TaskManager = require(ReplicatedStorage.Shared.Utilities.Modules.TaskManager)
local Registry = require(Components:WaitForChild('Registry'))
local AbilityParser = require(Components:WaitForChild('AbilityParser'))

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
	--print(node.Config.TagName, self.Tags)
	-- print(self)
end)

behaviorRegistry:Register('OnStart', function(self,node)
	self:Execute({
		Name = 'Ability.SetStatusEffect';
		Config = {
			Effect = 'ActiveSkill';
			Status = true;
		};
	})
end)

behaviorRegistry:Register('OnDurationEnd', function(self,node)
	TaskManager:CancelAllTasks(node.TriggerArgs['node'])
	TaskManager:CancelAllThreads(node.TriggerArgs['node'])
	print('Ended?')
end)

behaviorRegistry:Register('OnStop', function(self,node)
	TaskManager:CancelAllThreads(self)
	TaskManager:CancelAllTasks(self)

	self:Execute({
		Name = 'Ability.SetStatusEffect';
		Config = {
			Effect = 'ActiveSkill';
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