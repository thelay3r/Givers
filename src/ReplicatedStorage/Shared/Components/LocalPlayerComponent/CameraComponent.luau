local ReplicatedStorage = game:GetService('ReplicatedStorage')
local TweenService = game:GetService('TweenService')
local RunService = game:GetService('RunService')

local Shared = ReplicatedStorage:WaitForChild('Shared')
local Interfaces = Shared:WaitForChild('Interfaces')

local Utilities = Shared:WaitForChild('Utilities')
local Modules = Utilities:WaitForChild('Modules')

local CameraShaker = require(Modules:WaitForChild('CameraShaker'))
local TaskManager = require(Modules:WaitForChild('TaskManager'))


local LocalPlayerInterfaces = require(Interfaces:WaitForChild('LocalPlayerInterfaces'))


local PlayerCamera = workspace.CurrentCamera

local CameraComponent = {}

function CameraComponent.StopWobbling(self: LocalPlayerInterfaces.IClientPlayerComponent)
	TaskManager:CancelThread(self,'CameraWobbling')
	
	local Humanoid: Humanoid = self.ClientData.CharacterData.Humanoid
	local camera: Camera = self.ClientData.Camera.WorkspaceCamera
	
	Humanoid.CameraOffset = Humanoid.CameraOffset:Lerp(Vector3.zero,.05)
	
end

function CameraComponent.LaunchWobbling(self: LocalPlayerInterfaces.IClientPlayerComponent,data)
	
	local Humanoid: Humanoid = self.ClientData.CharacterData.Humanoid
	local camera: Camera = self.ClientData.Camera.WorkspaceCamera
	
	TaskManager:CreateThread(self,'CameraWobbling',RunService.Heartbeat:Connect(function(dt)
	
		if Humanoid.MoveDirection == Vector3.zero then Humanoid.CameraOffset = Humanoid.CameraOffset:Lerp(Vector3.zero,.05) TaskManager:CancelThread(self,'CameraWobbling') return end
		local _time = tick()
		
		local x = math.cos(_time*10)/4
		local y = math.abs(math.sin(_time*10)/5)
		
		local result = Vector3.new(x,y,0)
		Humanoid.CameraOffset = Humanoid.CameraOffset:Lerp(result,.05)
		
	end))
	
end

function CameraComponent.ChangeFOV(self: LocalPlayerInterfaces.IClientPlayerComponent,data)
	local camera: Camera = self.ClientData.Camera.WorkspaceCamera
	local lastFOV = camera.FieldOfView

	if not data.useTween then camera.FieldOfView = data.FOV return end
	
	local TweenData = data.TweenInfo_S
	
	local CameraTween = TweenService:Create(camera,TweenData,
		{
			FieldOfView = data.FOV
		})
	
	CameraTween:Play()
	if not data.ReturnFOV then return end
	
	local EndedTweenData = data.TweenInfo_E
	
	CameraTween.Completed:Once(function()
		local endedTween = TweenService:Create(camera,EndedTweenData,
			{
				FieldOfView = lastFOV
			})
		endedTween:Play()
	end)
end

function CameraComponent.InitCamera(self: LocalPlayerInterfaces.IClientPlayerComponent)
	
	local camera = CameraShaker.new(Enum.RenderPriority.Camera.Value +1,function(cf)
		PlayerCamera.CFrame *= cf
	end)
	camera:Start()
	
	self.ClientData.Camera = 
		{
			WorkspaceCamera = PlayerCamera;
			Shaker = camera;
		}
	
	return self
end




return CameraComponent
