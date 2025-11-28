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

local behaviorRegistry = Registry.new()
local GlobalBindable = Replicator:GetRemote('BindableGlobal')
local GlobalEvent = Replicator:GetRemote('Global')

behaviorRegistry:Register('TriggerEvent', function(self, node) 
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

behaviorRegistry:Register('OnHit', function(self, node) 
	print(self.Tags) 
	--print('root created', self)
end)

behaviorRegistry:Register('SetAbilityActive', function(self, node)
	node:GetRoot().Config.IsActive = node.Config.Status
end)

behaviorRegistry:Register('SetCoolDown', function(self, node)
	node:GetRoot().Config.LastUsed = tick()
end)

behaviorRegistry:Register('ResetCoolDown', function(self, node)
	node:GetRoot().Config.LastUsed = 0
end)

behaviorRegistry:Register('Wait', function(self, node)  
	task.wait(node.Config.Wait)
end)

behaviorRegistry:Register('PlayVFX', function(self,node) 

	if (RunService:IsClient()) and (not node.Config.Client) then
		print(node.Config)
		GlobalEvent:Fire('PlayVFX',node.Config)
	else
		GlobalBindable:BindableFire('PlayVFX',node.Config)
	end

end)

behaviorRegistry:Register('DeAcceleratMoveSpeed', function(self,node)
	local Entity = node.Additional['Owner']
	if not Entity then return end
	local config = node.Additional['Config']
	local Character = Entity.Instance.Character

	if config['Accelerat'] then
		task.cancel(config['Accelerat'] )
		config['Accelerat'] = nil
	end

	local Speed = SpeedComponent.new(Character)
	Speed:Revert(
		{
			Name = config.Name or ('AcceleratMoveSpeed')..Character.Name;
			Recursive = false;
		})
end)

behaviorRegistry:Register('AcceleratMoveSpeed', function(self,node)
	local Entity = node.Additional['Owner']
	if not Entity then return end
	local config = node.Config
	local Character = Entity.Instance.Character

	local Speed = SpeedComponent.new(Character)
	local targetSpeed = config.BaseSpeed * (config.Acceleration or 1)
	local updTime = config.AccelerationTime * 60
		
	local diff = targetSpeed - config.BaseSpeed
	local speedPerFrame = diff / (updTime)
	local percentPerFrame = (speedPerFrame / config.BaseSpeed) * 100

	node.Config['Accelerat'] = task.spawn(function() 
		for i=1, updTime do
			Speed:Amplify(
				{
					Name = (config.Name) or ('AcceleratMoveSpeed')..Character.Name;
					Type = 'Buff';
					Percent = percentPerFrame;
					InitSpeed = config.BaseSpeed;
				})
			task.wait(1/60)
		end
		node.Config['Accelerat'] = nil
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

behaviorRegistry:Register('Hello', function(self, node)
	--print(node.Additional['OnHit'])
	--print('hello', node.Config)
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