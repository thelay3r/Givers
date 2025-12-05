
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

behaviorRegistry:Register('SetCoolDown', function(self, node)
	node:GetRoot().Config.LastUsed = tick()
end)

behaviorRegistry:Register('AbilityStatus', function(self,node)  

	TaskManager:CreateThread(self, 'RunServiceStatus',RunService.Heartbeat:Connect(function(dt: number)
		if not self:Execute(
			{
				Name = 'Condition.BlackList?';
				RequestedTags = {['Owner'] = 'Owner'};
				Config = 
				{
					Ignore = 
					{
						['CoolDown'] = true
					}
				}
			})
			then
				print(node:GetRoot().Children['1'])
			end
	end))


end)


behaviorRegistry:Register('ResetCoolDown', function(self, node)
	node:GetRoot().Config.LastUsed = 0
end)

return behaviorRegistry