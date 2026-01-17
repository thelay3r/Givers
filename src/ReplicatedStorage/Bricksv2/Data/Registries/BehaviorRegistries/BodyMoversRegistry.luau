
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Bricks = ReplicatedStorage:WaitForChild('Bricksv2')

local Components = Bricks:WaitForChild('Components')
local Data = Bricks:WaitForChild('Data')
local Registries = Data:WaitForChild('Registries')

local PlayerInterfaces = require(ReplicatedStorage.Shared.Interfaces.PlayerInterfaces)
local AssetsHelper = require(ReplicatedStorage.Shared.Utilities.Modules.AssetsHelper)
local BiezeModule = require(ReplicatedStorage.Shared.Utilities.Modules.BiezeModule)
local TaskManager = require(ReplicatedStorage.Shared.Utilities.Modules.TaskManager)
local Registry = require(Components:WaitForChild('Registry'))
local AbilityParser = require(Components:WaitForChild('AbilityParser'))

local AbilityFolder = Data:WaitForChild('Abilities')
local BlackList = require(AbilityFolder:WaitForChild('BlackList'))


local BodyMoversRegistry = Registry.new()

BodyMoversRegistry:Register('Root', function(self, node)  
end)

BodyMoversRegistry:Register('BodyGyro', function(self,node)
	local config = node.Config
	local Parent = config.Parent
	if not Parent then return end

	local BodyGyro = AssetsHelper.CreateBodyGyro(
		{
			Instance = 
			{
				Priority = (config.Priority) or 1;
				Parent = Parent;
				MaxTorque = config.MaxTorque;
				P = config.P;
				D = config.D;
				CFrame = config.CFrame;
			};
			Settings = 
			{
				DestroyTime = config.DestroyTime;
			};
		})

	return BodyGyro
end)

BodyMoversRegistry:Register('BodyVelocity', function(self,node)
	local config = node.Config
	local Parent = config.Parent
	if not Parent then return end


	
	local BodyVelocity = AssetsHelper.CreateBodyVelocity(
		{
			Instance = 
			{
				Priority = (config.Priority) or 1;
				Parent = Parent;
				MaxForce = config.MaxForce;
				P = config.P;
				Velocity = config.Velocity;
			};
			Settings = 
			{
				DestroyTime = config.DestroyTime;
			};
		})

	return BodyVelocity
end)

BodyMoversRegistry:Register('UnitSmoothVelocity', function(self,node)
	local config = node.Config
	local addition = node.Additional
	local BodyVelocityTag = addition['BodyVelocity']
	local Body = BodyVelocityTag.BodyVelocityInstance
	if not Body then return end


	local FrameRate = config.FrameRate;
	local totalTime = config.TotalTime;
	local Frames = totalTime/FrameRate;

	local easing = (config.EasingDirection) or (Enum.EasingStyle.Sine)
	local direction = (config.EasingDirection) or (Enum.EasingDirection.In)
	local Humanoid = Body.Parent.Parent:FindFirstChild('Humanoid')
	if not Humanoid then return end
	local Unit

	TaskManager:CreateTask(node, 'UnitSmoothVelocity', 0, function(a0)  
		local lastHumanoidDirection
		for i=1, Frames do 
			if (not Body) or (not Body.Parent) then break end
			Unit = if (Humanoid.MoveDirection ~= Vector3.zero) then Humanoid.MoveDirection.Unit else (lastHumanoidDirection or Body.Parent.CFrame[BodyVelocityTag.Force])

			local t = i/Frames
			local lerp = BiezeModule.lerp(config.SPoint, config.EPoint, t, easing, direction)
			Body.Velocity = Unit * (BodyVelocityTag.VectorSpeed * lerp)
			if Humanoid.MoveDirection ~= Vector3.zero then
				lastHumanoidDirection = Humanoid.MoveDirection.Unit
			end
			task.wait(FrameRate)
		end
	end)


end)

BodyMoversRegistry:Register('DestroyBodyVelocity', function(self,node)
	local Owner = self.Tags['Owner']
	local _Instance = Owner.Instance
	local Character = _Instance.Character :: Model
	local RootPart = Character:FindFirstChild('HumanoidRootPart')::BasePart
	local cfg = node.Config

	local body = Character[cfg.Part] :: BasePart
	if not body then return end
	local velocity = body:FindFirstChildOfClass('BodyVelocity')
	if not velocity then return end
	velocity:Destroy()
end)

BodyMoversRegistry:Register('SmoothBodyVelocity', function(self,node)
	local config = node.Config
	local addition = node.Additional
	local BodyVelocityTag = addition['BodyVelocity']
	local DashConfig = addition['Velocity']
	local Body = BodyVelocityTag.BodyVelocityInstance
	if not Body then return end

	local FrameRate = config.FrameRate;
	local totalTime = config.TotalTime;
	local Frames = totalTime/FrameRate;

	local easing = (config.EasingDirection) or (Enum.EasingStyle.Sine)
	local direction = (config.EasingDirection) or (Enum.EasingDirection.In)


	TaskManager:CreateTask(node, 'SmoothBodyVelocity', 0, function(a0)  
		for i=1, Frames do 
			if (not Body) or (not Body.Parent) then break end
			local t = i/Frames
			local lerp = BiezeModule.lerp(config.SPoint, config.EPoint, t, easing, direction)
			Body.Velocity = Body.Parent.CFrame[BodyVelocityTag.Force] * (BodyVelocityTag.VectorSpeed * lerp)
			task.wait(FrameRate)
		end
	end)
end)

return BodyMoversRegistry
