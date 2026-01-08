
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local RunService = game:GetService("RunService")
local Bricks = ReplicatedStorage:WaitForChild('Bricksv2')

local Components = Bricks:WaitForChild('Components')
local Data = Bricks:WaitForChild('Data')
local _Registries = Data:WaitForChild('Registries')

local TaskManager = require(ReplicatedStorage.Modules.Utilities.TaskManager)
local Registry = require(Components:WaitForChild('Registry'))
local _AbilityParser = require(Components:WaitForChild('AbilityParser'))



local behaviorRegistry = Registry.new()

behaviorRegistry:Register('Root', function(self, node)  
end)

behaviorRegistry:Register('SetAbilityActive', function(self, node)
	local Main = self.Tags['Main']
	Main.IsActive = node.Config.Status
	if not node.Config.Status then return end
	Main.CastTime = tick()
end)

behaviorRegistry:Register('SetAbilityPressed', function(self, node)
	local Main = self.Tags['Main']
	Main.Pressed = node.Config.Status
end)

behaviorRegistry:Register('SetUsed', function(self, node)
	local Main = self.Tags['Main']
	Main.LastUsed = tick()
end)

behaviorRegistry:Register('SetRootCoolDown', function(self, node)
	local Main = self.Tags['Main']
	Main.CoolDown = node.Config.CoolDown
end)



behaviorRegistry:Register('AbilityStatus', function(self,node) 
	local newCfg = node.Config
	if not newCfg['Ignore'] then
		newCfg['Ignore'] = {}
	end


	newCfg['Ignore']['CoolDown'] = true
	newCfg['Ignore']['SelfActive'] = true
	newCfg['Ignore']['IsActive'] = true

	local startTime = tick()
	local MainConfig = self.Tags['Main']
	local duration = (MainConfig.Duration) or (1) 
	local minDuration = (MainConfig.MinDuration) or (0)
	

	TaskManager:CreateThread(node, 'RunServiceStatus',RunService.Heartbeat:Connect(function(dt: number)
		local currentTime = tick()
		local elapsed = currentTime - startTime

		local isTimeExpired = elapsed >= duration

		local isMinDurationPassed = elapsed >= minDuration
		local isInputReleased = not MainConfig.Pressed
		local shouldManualStop = (isInputReleased) and isMinDurationPassed

		local Validate = self:Execute(
			{
				Name = 'Condition.RunTimeCheck?';
				RequestedTags = {['Owner'] = 'Owner'};
				Config = newCfg;
			})
		
		local isInvalid = not Validate
		if isInvalid or isTimeExpired or shouldManualStop then
			self:Execute({
				Name = 'Action.TriggerEvent';
				Config = { TagName = 'OnStop',['node'] = node };
			})

			self:Execute({
				Name = 'Action.TriggerEvent';
				Config = { TagName = 'OnDurationEnd' , ['node'] = node };
			})
			
		end
	end))
end)


behaviorRegistry:Register('ResetCoolDown', function(self, node)
	node:GetRoot().Config.LastUsed = 0
end)

return behaviorRegistry

--[[

		local currentTime = tick()
		local elapsed = currentTime - startTime


		local isTimeExpired = elapsed >= duration


		local isMinDurationPassed = elapsed >= minDuration
		local isInputReleased = not MainConfig.Pressed 
		local shouldManualStop = isMinDurationPassed and isInputReleased

		local Validate = self:Execute(
			{
				Name = 'Condition.BlackList?';
				RequestedTags = {['Owner'] = 'Owner'};
				Config = newCfg;

			})

		local isInvalid = not Validate

		if isInvalid or isTimeExpired or shouldManualStop then

			self:Execute({
				Name = 'Action.TriggerEvent';
				Config = { TagName = 'OnStop' };
			})

			self:Execute({
				Name = 'Action.TriggerEvent';
				Config = { TagName = 'OnDurationEnd' };
			})
			
		end

]]