local ReplicatedStorage = game:GetService('ReplicatedStorage')
local RunService = game:GetService('RunService')

local Shared = ReplicatedStorage:WaitForChild('Shared')
local Utilities = Shared:WaitForChild('Utilities')
local UtilModules = Utilities:WaitForChild('Modules')
local VFXs = Shared:WaitForChild('VFXs')

local Animations = VFXs:WaitForChild('Assets'):WaitForChild('Movement'):WaitForChild('Dash'):WaitForChild('Animations')

local CacheContainer = require(UtilModules:WaitForChild('CacheContainer'))
local AssetsHelper = require(UtilModules:WaitForChild('AssetsHelper'))
local AnimationsComponent = require(UtilModules:WaitForChild('AnimationsComponent'))
local SoundsEmmiter = require(VFXs:WaitForChild('Modules'):WaitForChild('SoundsEmmiter'))
local Emit = require(VFXs:WaitForChild('Modules'):WaitForChild('Emit'))
local TaskManager = require(UtilModules:WaitForChild('TaskManager'))

local Dash = {}

	Dash['DashAnimation'] = function(Character: Model, DashName: string)
		
	local Animate = AnimationsComponent.new(Character)
		
	local AnimData = {
		Name = 'Dash';
		Priority = Enum.AnimationPriority.Action2.Name;
		_Name = DashName;

		Settings = {
			Speed = 1;
		}
	}
	
	Animate:Load(Animations['Dash_'..DashName], AnimData):Swap(AnimData)
	
	end

	Dash['DashEffect'] = function(Character: Model)
		
		local Humanoid: Humanoid = Character:FindFirstChildOfClass('Humanoid')
		local HumanoidRootPart: BasePart = Character:FindFirstChild('HumanoidRootPart')
		
		local Sound = SoundsEmmiter:PlaySound(VFXs.Assets.Movement.Dash.Sounds.Dash, HumanoidRootPart)
		
		local Trail1 = AssetsHelper.CreateTrail({
			Propertis = {
				Instance = VFXs.Assets.Movement.Dash.VFXs.Trail;
				Parent = Character['Left Arm'];
				C1 = CFrame.new(0, 0.75, 0)
			};
			Settings = {
				DisableTime = 0.35;
				DestroyTime = 0.7;
			};
		})
		
		local Trail2 = AssetsHelper.CreateTrail({
			Propertis = {
				Instance = VFXs.Assets.Movement.Dash.VFXs.Trail;
				Parent = Character['Right Arm'];
				C1 = CFrame.new(0, 0.75, 0)
			};
			Settings = {
				DisableTime = 0.35;
				DestroyTime = 0.7;
			};
		})
		
		local RayOrigin = HumanoidRootPart.Position
		local RayDirection = HumanoidRootPart.CFrame.UpVector * -7.5

		local Params = RaycastParams.new()

		Params.FilterType = Enum.RaycastFilterType.Exclude
		Params.FilterDescendantsInstances = {Character}
		
		local Result: RaycastResult = workspace:Raycast(RayOrigin, RayDirection, Params)
		
		if (Result) and (Result.Instance) then
			local VFX = VFXs.Assets.Movement.Dash.VFXs.dashEffect:Clone()
			VFX.Parent = workspace.Map.VFXs
			
			VFX.Anchored = true
			VFX.Position = Result.Position
			
			Emit:Emit(VFX)
			
			TaskManager:CreateTask(VFX, 'Delete', 1.7, function()
				VFX:Destroy()
			end)
			
		end

	end

	Dash['DashCancel'] = function(Character: Model)
		
	local Animate = AnimationsComponent.new(Character)
	Animate:StopByName('Dash')
	
	local AnimData = {
		Name = 'Dash_Cancel';
		Priority = Enum.AnimationPriority.Action2.Name;
		_Name = 'Cancel';

		Settings = {
			Speed = 1;
		}
	}

	Animate:Load(Animations.Cancels['Cancel'], AnimData):Swap(AnimData)
		
	end

return Dash
