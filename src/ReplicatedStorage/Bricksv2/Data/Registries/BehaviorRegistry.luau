local ReplicatedStorage = game:GetService('ReplicatedStorage')
local RunService = game:GetService("RunService")

local Bricks = ReplicatedStorage:WaitForChild('Bricksv2')

local Shared = ReplicatedStorage:WaitForChild('Shared')
local Utilities = Shared:WaitForChild('Utilities')
local UtilModules = Utilities:WaitForChild('Modules')
local NetWork = Utilities:WaitForChild('NetWork')
local AssetsHelper = require(ReplicatedStorage.Shared.Utilities.Modules.AssetsHelper)
local BiezeModule = require(ReplicatedStorage.Shared.Utilities.Modules.BiezeModule)
local TaskManager = require(ReplicatedStorage.Shared.Utilities.Modules.TaskManager)
local BodyMovers = require(ReplicatedStorage.Shared.VFXs.Replica.VFXs.BodyMovers)
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

local Angles1 = {
	Front = {0, 60};
	Back = {120, 180};
};
	
local Angles2 = {
	Right = {0, 60};
	Left = {120, 180};
}

local function CheckAngle(Angle)

end

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

behaviorRegistry:Register('SmoothBodyVelocity', function(self,node)
	local config = node.Config
	local addition = node.Additional
	local BodyVelocityTag = addition['BodyVelocity']
	local DashConfig = addition['Velocity']
	local Body = BodyVelocityTag.BodyVelocityInstance
	if not Body then return end

	warn(BodyVelocityTag)
	local FrameRate = config.FrameRate;
	local totalTime = config.TotalTime;
	local Frames = totalTime/FrameRate;

	local easing = (config.EasingDirection) or (Enum.EasingStyle.Sine)
	local direction = (config.EasingDirection) or (Enum.EasingDirection.In)

	local t:BodyVelocity
	
	TaskManager:CreateTask(node, 'SmoothBodyVelocity', 0, function(a0)  
		for i=1, Frames do 
			if (not Body) or (not Body.Parent) then break end
			local t = i/Frames
			local lerp = BiezeModule.lerp(config.SPoint, config.EPoint, t, easing, direction)
			Body.Velocity = Body.Parent.CFrame[BodyVelocityTag.Force] * (BodyVelocityTag.VectorSpeed * lerp)
			print(Body.Parent.CFrame[BodyVelocityTag.Force] * (BodyVelocityTag.VectorSpeed * lerp))
			task.wait(FrameRate)
		end
	end)


end)

behaviorRegistry:Register('BodyVelocity', function(self,node)
	local Parent = node.Config.Parent
	if not Parent then return end


	local BodyVelocityCFG = node.Config.BodyVelocity
	local DashCFG = node.Config.DashConfig
	local BodyVelocity = AssetsHelper.CreateBodyVelocity(
		{
			Instance = 
			{
				Priority = BodyVelocityCFG.Priority;
				Parent = Parent;
				MaxForce = BodyVelocityCFG.MaxForce;
				P = BodyVelocityCFG.P;
				Velocity = Parent.CFrame[DashCFG.Vector] * ((BodyVelocityCFG.Speed) or (50)) * (DashCFG.Speed)
			};
			Settings = 
			{
				DestroyTime = BodyVelocityCFG.DestroyTime;
			};
		})

	node.Config['BodyVelocityInstance'] = BodyVelocity
	node.Config['VectorSpeed'] = ((BodyVelocityCFG.Speed) or (50)) * (DashCFG.Speed)
	node.Config['Force'] = DashCFG.Vector
	
end)

behaviorRegistry:Register('GetDashDirection', function(self,node) 

	local Entity = node.Additional['Owner']
	if not Entity then return end

	local Character = Entity.Instance.Character
	local HumanoidRootPart = Character and Character:FindFirstChild('HumanoidRootPart')
	if not HumanoidRootPart then return end

	local SPEED = 50
	local COEFFICIENT = 1.2

	local function getDirectionFromAngle(angle: number, anglesConfig: {[string]: {number}}): string?
		for direction, range in pairs(anglesConfig) do
			if angle >= range[1] and angle <= range[2] then
				return direction
			end
		end
		return nil
	end

	local velocity = HumanoidRootPart.Velocity.Unit
	local cframe = HumanoidRootPart.CFrame

	local lookAngle = math.deg(math.acos(cframe.LookVector:Dot(velocity)))
	local rightAngle = math.deg(math.acos(cframe.RightVector:Dot(velocity)))

	local direction1 = getDirectionFromAngle(lookAngle, Angles1)
	local direction2 = getDirectionFromAngle(rightAngle, Angles2)

	local mainDirection = direction1 or direction2 or 'Front'

	local DIRECTION_VECTORS = {
		Front = 'LookVector',
		Back = 'LookVector',
		Left = 'RightVector',
		Right = 'RightVector',
	}

	local DIRECTION_SPEED_MULTIPLIERS = {
		Front = 1,
		Back = -1,
		Left = -1,
		Right = 1,
	}

	local _vector = DIRECTION_VECTORS[mainDirection]
	local speed = (DIRECTION_SPEED_MULTIPLIERS[mainDirection] or 1)

	node.Config['MainDirection'] = mainDirection;
	node.Config['Vector'] = _vector;
	node.Config['Speed'] = speed;

end)

behaviorRegistry:Register('Wait', function(self, node)  
	task.wait(node.Config.Wait)
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