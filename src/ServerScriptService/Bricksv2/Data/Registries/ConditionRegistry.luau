local ServerScriptService = game:GetService('ServerScriptService')
local Bricks = ServerScriptService:WaitForChild('Bricksv2')

local Components = Bricks:WaitForChild('Components')
local Data = Bricks:WaitForChild('Data')
local Registries = Data:WaitForChild('Registries')

local Registry = require(Components:WaitForChild('Registry'))
local AbilityParser = require(Components:WaitForChild('AbilityParser'))

local conditionRegisrty = Registry.new()

conditionRegisrty:Register('TriggerEvent', function(self, node)  
	if (not self.Events) then return end
	local handler = self.ScopeRegistry:Get('EventAction')

	local selectedBlock = self.Events[node.Config.TagName]
	selectedBlock.TriggerArgs = node.Config

	--selectedBlock.Config = node.Config

	self.Tags[node.Config.TagName] = node.Config

	if handler then handler(self, selectedBlock) end
	--print(node.Config.TagName, self.Tags)
	-- print(self)
end)



conditionRegisrty:Register('==', function(self, node)  
	return node.Config.arg1 == node.Config.arg2
end)

conditionRegisrty:Register('>=', function(self, node)  
	return node.Config.arg1 >= node.Config.arg2
end)

conditionRegisrty:Register('>', function(self, node)  
	return node.Config.arg1 > node.Config.arg2
end)

conditionRegisrty:Register('<', function(self, node)  
	return node.Config.arg1 < node.Config.arg2
end)

conditionRegisrty:Register('<=', function(self, node)  
	return node.Config.arg1 <= node.Config.arg2
end)

conditionRegisrty:Register('LinearSpeedUp',function(self,node)
	local Part: BasePart = node.Additional['ProjectileInfo'].Part
	if not Part then return end
	local BodyVelocity = Part:FindFirstChildOfClass('BodyVelocity')
	if not BodyVelocity then return end
	task.spawn(function()
		for i=1,10 do
			BodyVelocity.Velocity *= 1.1
			task.wait(1/10)
		end
	end)
end)

conditionRegisrty:Register('SpawnProjectile',function(self,node)
	local Part = Instance.new('Part')
	local BodyVelocity = Instance.new('BodyVelocity')

	Part.Position = Vector3.new(0,50,0)
	BodyVelocity.Parent = Part
	
	BodyVelocity.Velocity = Vector3.new(0,-node.Config.Speed,0)
	Part.Parent = workspace
	
	node.Config['Part'] = Part
	
	Part.Touched:Connect(function(otherPart)
		self:Execute(
			{
				Name = 'Action.TriggerEvent',
				Config = {
					part = otherPart,
					TagName = node.Config.OnHitTag
					
				}
			})
	end)
end)

conditionRegisrty:Register('Hello', function(self, node)
	--print(node.Additional['OnHit'])
	--print('hello', node.Config)
end)

conditionRegisrty:Register('TriggerPassive', function(self, node)
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

return conditionRegisrty