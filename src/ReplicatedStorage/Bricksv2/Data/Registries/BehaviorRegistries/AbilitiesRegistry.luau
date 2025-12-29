
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local _RunService = game:GetService("RunService")
local Bricks = ReplicatedStorage:WaitForChild('Bricksv2')

local Components = Bricks:WaitForChild('Components')
local Data = Bricks:WaitForChild('Data')
local _Registries = Data:WaitForChild('Registries')

local AssetsHelper = require(ReplicatedStorage.Shared.Utilities.Modules.AssetsHelper)
local TaskManager = require(ReplicatedStorage.Shared.Utilities.Modules.TaskManager)
local Replicator = require(ReplicatedStorage.Shared.Utilities.NetWork.Replicator)
local Registry = require(Components:WaitForChild('Registry'))
local _AbilityParser = require(Components:WaitForChild('AbilityParser'))

local AbilityFolder = Data:WaitForChild('Abilities')
local _BlackList = require(AbilityFolder:WaitForChild('BlackList'))

local BindableGlobal = Replicator:GetRemote('BindableGlobal')

local behaviorRegistry = Registry.new()

behaviorRegistry:Register('Root', function(self, node)  
end)

behaviorRegistry:Register('SlideStop', function(self, node)
	local owner = self.Tags['Owner']
	local SlideTag = self.Tags['SlideStart']

	
	local Character = owner.Instance.Character :: Model
	local Humanoid = Character:FindFirstChildOfClass('Humanoid') :: Humanoid
	local _RootPart = Character:FindFirstChild('HumanoidRootPart') :: BasePart

	Humanoid.HipHeight = 0
	SlideTag.BodyVelocity:Destroy()
	SlideTag.BodyGyro:Destroy()
	

end)

behaviorRegistry:Register('SlideJump', function(self,node)
	local owner = self.Tags['Owner']

	local Character = owner.Instance.Character :: Model
	local Humanoid = Character:FindFirstChildOfClass('Humanoid') :: Humanoid
	local RootPart = Character:FindFirstChild('HumanoidRootPart') :: BasePart

	BindableGlobal:Connect('SlideJump', function()
		BindableGlobal:Disconnect('SlideJump')

		self:Execute({
			Name = 'Action.TriggerEvent';
			Config = {
				TagName = 'OnStop';
			}
		})

		self:Execute({
			Name = 'Network.PlayBindableEvent';
			Config = {
				EventName = 'PlayVFX';
				EventData = {
					VFXType = 'Animations.Slide';
					State = 'Jump';
					Pack = 'Default';

				};
			};
		})

		local slide = self.Tags['SlideStart']
		
		
		RootPart:ApplyImpulse(slide.SlideVelocity * RootPart.AssemblyMass * Vector3.new(1,0,1) + Vector3.new(0, 60, 0) * RootPart.AssemblyMass)

		
		TaskManager:CreateTask(RootPart, 'DelayJumpPower', .2, function()
			Humanoid.JumpPower = 50
		end)
		
		
	end)
end)

behaviorRegistry:Register('UnBindSlideJump', function(self,node)
	BindableGlobal:Disconnect('SlideJump')
end)

behaviorRegistry:Register('SlideStart', function(self, node)
	local owner = self.Tags['Owner']
	local config = node.Config

	local Character = owner.Instance.Character :: Model
	local Humanoid = Character:FindFirstChildOfClass('Humanoid') :: Humanoid
	local RootPart = Character:FindFirstChild('HumanoidRootPart') :: BasePart

	local rayResult = node.Additional['RayResult']['RayResult']

	Humanoid.HipHeight = -2
	Humanoid.JumpPower = 0

	local BodyVelocity = self:Execute(
		{
			Name = 'Action.BodyVelocity';
			Config = 
			{
				MaxForce = Vector3.new(45000,15000,45000);
				P = 95000;
				DestroyTime = 1e10;
				Velocity = Vector3.one;
				Parent = RootPart;
			};
		}) :: BodyVelocity

	local BodyGyro = self:Execute(
		{
			Name = 'Action.BodyGyro';
			Config = 
			{
				MaxTorque = Vector3.one * 3e4;
				P = 1000;
				D = 250;
				DestroyTime = 1e10;
				CFrame = CFrame.new(Vector3.zero);
				Parent = RootPart;
			};
		}) :: BodyGyro

	local prevY = RootPart.Position.Y
	local rightVector = RootPart.CFrame.RightVector
	local updateLookVector = rightVector:Cross(rayResult.Normal)
	
	local cast
	local angle = math.clamp(math.deg(math.acos(RootPart.CFrame.UpVector:Dot(rayResult.Normal))),20,config.MaxForce) 
	
	local speedMod = math.clamp(config.BaseSpeed + angle/2,config.DefaultSpeed,10)
	
	local newCFrame = CFrame.fromMatrix(RootPart.Position, rightVector, rayResult.Normal, updateLookVector)
	BodyGyro.CFrame = newCFrame

	TaskManager:CreateTask(self, 'Slide', 0, function(a0)  
		while task.wait(1/60) do
			cast = AssetsHelper.FastCast({
				Direction = Vector3.new(0,-8,0);
				Position = RootPart.Position;
				Character = Character;
			})

			if not cast then
				continue
			end

			rightVector = RootPart.CFrame.RightVector
			updateLookVector = rightVector:Cross(cast.Normal)
			newCFrame = CFrame.fromMatrix(RootPart.Position, rightVector, cast.Normal, updateLookVector)
			BodyGyro.CFrame = BodyGyro.CFrame:Lerp(newCFrame, 1/10) 

			local CurrentlyY = RootPart.Position.Y
			local DeltaY = (CurrentlyY - prevY) / config.Delta

			local speedModifier = math.clamp(config.BaseSpeed * speedMod, 0, config.MaxSpeed)

			prevY = CurrentlyY
			BodyVelocity.Velocity = (RootPart.CFrame.LookVector * speedModifier) - Vector3.new(0,75,0)
			
			node.Config['SlideVelocity'] = BodyVelocity.Velocity + Vector3.new(0,75,0)

			if speedMod < 1 then
				self:Execute({
						Name = 'Action.TriggerEvent';
						Config = {
							TagName = 'OnStop';
						};
					})
				return
			end

			local fastCast = AssetsHelper.FastCast({
				Position =  RootPart.Position;
				Direction = RootPart.CFrame.LookVector * 4;
				Character = Character;
			})
			if fastCast then
				--[[
				if speedMod > 15 then
					self:Execute({
						Name = 'Network.PlayVFX';
						Config = {
							VFXType = 'Slide.Client';
							Client = true;
							EventData = {
								State = 'Lobo';
								Pack = 'Default';
							};
						};
					})
				end
				]]
				speedMod = 0
				continue
			end

			if DeltaY < -1 then
				speedMod = math.clamp(speedMod + config.VerticalAcceleration * (1/60), config.MinSpeed, config.MaxSpeed)
				continue
			end

			if DeltaY > 1 then
				speedMod = math.clamp(speedMod - config.VerticalDecceleration * (1/60), config.MinSpeed, config.MaxSpeed)
				continue
			end

			if (DeltaY > -1 and DeltaY < 1) then
				speedMod = math.clamp(speedMod - config.HorizontalDecceleration * (1/60), config.MinSpeed, config.MaxSpeed)
				continue
			end
		end

	end)

	node.Config['BodyVelocity'] = BodyVelocity;
	node.Config['BodyGyro'] = BodyGyro;

end)



return behaviorRegistry