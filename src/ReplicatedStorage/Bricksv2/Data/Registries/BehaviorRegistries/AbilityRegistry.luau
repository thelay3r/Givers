
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local RunService = game:GetService("RunService")
local Bricks = ReplicatedStorage:WaitForChild('Bricksv2')

local Components = Bricks:WaitForChild('Components')
local Data = Bricks:WaitForChild('Data')
local Registries = Data:WaitForChild('Registries')

local TaskManager = require(ReplicatedStorage.Shared.Utilities.Modules.TaskManager)
local Registry = require(Components:WaitForChild('Registry'))
local AbilityParser = require(Components:WaitForChild('AbilityParser'))

local AbilityFolder = Data:WaitForChild('Abilities')
local BlackList = require(AbilityFolder:WaitForChild('BlackList'))


local behaviorRegistry = Registry.new()

behaviorRegistry:Register('Root', function(self, node)  
    print('New Root Behavior')
end)

behaviorRegistry:Register('SetAbilityActive', function(self, node)
	node:GetRoot().Config.IsActive = node.Config.Status
end)

behaviorRegistry:Register('SetStatusEffect', function(self,node)
	local Entity = self.Tags['Owner']
  	local sessionData = (Entity.Replica.Data.Session)
	local config = node.Config
	sessionData.StatusEffects[config.Effect] = config.Status
end)



behaviorRegistry:Register('SetCoolDown', function(self, node)
	node:GetRoot().Config.LastUsed = tick()
end)

behaviorRegistry:Register('SetRootCoolDown', function(self, node)
	local Main = self.Tags['Main']
	print(Main)
	Main.CoolDown = node.Config.CoolDown
end)

behaviorRegistry:Register('AbilityDuration', function(self,node)  
	local startTime = tick()
	local MainConfig = node.Additional.Main
	local duration = (MainConfig.Duration) or (1) 

	TaskManager:CreateThread(node, 'AbilityDuration',RunService.Heartbeat:Connect(function(dt: number)
		print('WorkOut')
		if (tick() - startTime) >= duration then
			self:Execute(
				{
					Name = 'Action.TriggerEvent';
					Config = {
						TagName = 'OnDurationEnd';
						['node'] = node;
					};
				})
				self:Execute(
				{
					Name = 'Action.TriggerEvent';
					Config = {
						TagName = 'OnStop';
						['node'] = node;
					};
				})
		end
	end))
end)

behaviorRegistry:Register('AbilityStatus', function(self,node) 
	local newCfg = node.Config
	if not newCfg['Ignore'] then
		newCfg['Ignore'] = {}
	end

	newCfg['Ignore']['CoolDown'] = true
	newCfg['Ignore']['ActiveSkill'] = true

	local startTime = tick()
	local MainConfig = node.Additional.Main
	local duration = (MainConfig.Duration) or (1) 
	
	TaskManager:CreateThread(self, 'RunServiceStatus',RunService.Heartbeat:Connect(function(dt: number)
		local Validate = self:Execute(
			{
				Name = 'Condition.BlackList?';
				RequestedTags = {['Owner'] = 'Owner'};
				Config = newCfg;

			})
		if (not Validate) or ((tick() - startTime) >= duration) then
			self:Execute(
				{
					Name = 'Action.TriggerEvent';
					Config = 
					{
							TagName = 'OnStop';
					};
				})
		end
	end))
end)


behaviorRegistry:Register('ResetCoolDown', function(self, node)
	node:GetRoot().Config.LastUsed = 0
end)

return behaviorRegistry