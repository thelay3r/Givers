local ReplicatedStorage = game:GetService('ReplicatedStorage')
local RunService = game:GetService('RunService')

local Shared = ReplicatedStorage:WaitForChild('Shared')
local Modules = ReplicatedStorage:WaitForChild('Modules')
local Utilities = Modules:WaitForChild('Utilities')

local Interfaces = Shared:WaitForChild('Interfaces')

local TaskManager = require(Utilities:FindFirstChild('TaskManager'))
local AnimationsComponent = require(Utilities:FindFirstChild('Animator'):FindFirstChild('AnimationsComponent'))
local StateManager = require(Utilities:FindFirstChild('StateManager'))

local VFXs = Shared:WaitForChild('VFXs')
local LocalPlayerInterfaces = require(Interfaces:WaitForChild('LocalPlayerInterfaces'))

local TaskManager = require(Utilities:WaitForChild('TaskManager'))


local MoveDirection = {}





function MoveDirection:InitDirection()
	local self: LocalPlayerInterfaces.IClientPlayerComponent = self
	
	local Data = self.ClientData
	local CharacterData = Data.CharacterData
	
	local Character = CharacterData.Character
	local RootPart = CharacterData.HumanoidRootPart
	local Humanoid: Humanoid = CharacterData.Humanoid
	local TorsoMotor: Motor6D = RootPart:WaitForChild('RootJoint')
	local TorsoMotorC0: CFrame = RootPart:WaitForChild('RootJoint').C0
	
	TaskManager:CreateThread(self,'MoveDirection',RunService.Heartbeat:Connect(function()
		if true then return end
		local MoveDirection = -(Humanoid.MoveDirection * Vector3.new(1,0,1))
		local Front = -MoveDirection:Dot(RootPart.CFrame.LookVector) * (Humanoid.WalkSpeed/2)
		local Right = MoveDirection:Dot(RootPart.CFrame.RightVector) * (Humanoid.WalkSpeed/2)

		local FrontAngle = math.rad(math.clamp(Front,-15,15))
		local RightAngle = math.rad(math.clamp(Right,-10,10))

		TorsoMotor.C0 = TorsoMotor.C0:Lerp(
			TorsoMotorC0 * CFrame.Angles(FrontAngle, RightAngle, 0),
			0.1
		)
	end))

end



return MoveDirection
