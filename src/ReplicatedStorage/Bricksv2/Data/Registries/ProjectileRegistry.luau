
local ServerScriptService = game:GetService('ServerScriptService')
local Bricks = ServerScriptService:WaitForChild('Bricksv2')

local Components = Bricks:WaitForChild('Components')
local Data = Bricks:WaitForChild('Data')
local Registries = Data:WaitForChild('Registries')

local Registry = require(Components:WaitForChild('Registry'))
local AbilityParser = require(Components:WaitForChild('AbilityParser'))

local behaviorRegistry = Registry.new()

behaviorRegistry:Register('OnHit', function(self, node) 
	print(self.Tags) 
	--print('root created', self)
end)

behaviorRegistry:Register('LinearSpeedUp',function(self,node)
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

behaviorRegistry:Register('SpawnProjectile',function(self,node)
	local Part = Instance.new('Part')
	local BodyVelocity = Instance.new('BodyVelocity')

	Part.Position = Vector3.new(0,50,0)
	BodyVelocity.Parent = Part
	
	BodyVelocity.Velocity = Vector3.new(0,-node.Config.Speed,0)
	Part.Parent = workspace
	
	node.Config['Part'] = Part
end)

return behaviorRegistry