local RagDoll = {}
local Players = game:GetService("Players")

local PhysicsService = game:GetService("PhysicsService")
local RunSerivce = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local Workspace = game:GetService("Workspace")
local ragParts = script.RagdollParts:GetChildren()

local RunServiceTable = {}

local CollisionParts = {
	"Right Leg",
	"Right Arm",
	"Left Leg",
	"Left Arm",
	"Head",

}



function RagDoll:Setup(Character : Model)


	local humanoid = Character:FindFirstChild("Humanoid")

	Character.Head.Size = Vector3.new(1, 1, 1)
	humanoid.BreakJointsOnDeath = false
	humanoid.RequiresNeck = false

	local clones = {}
	
	for _, v in ipairs(ragParts) do
		clones[v.Name] = v:Clone()
	end

	local folder1 = Instance.new("Folder")
	folder1.Name = "RagdollConstraints"
	
	for _, v in pairs(clones) do
		if v:IsA("Attachment") then
			v.Parent = Character[v:GetAttribute("Parent")]
		elseif v:IsA("BallSocketConstraint") then
			v.Attachment0 = clones[v:GetAttribute("0")]
			v.Attachment1 = clones[v:GetAttribute("1")]
			v.Parent = folder1
		end
	end
	
	folder1.Parent = Character
	
	local value;
	local folder2 = Instance.new("Folder")
	folder2.Name = "Motors"
	
	for _, v in ipairs(Character.Torso:GetChildren()) do
		if v:IsA("Motor6D") then
			value = Instance.new("ObjectValue")
			value.Name = v.Name
			value.Value = v
			value.Parent = folder2
		end
	end
	
	folder2.Parent = folder1
end


function RagDoll:Enabled(Character : Model)

	local HumanoidRootPart = Character.PrimaryPart :: BasePart
	local Humanoid : Humanoid = Character:WaitForChild('Humanoid') :: Humanoid
	
	--HumanoidRootPart:ApplyImpulse(Vector3.new(50,-5,1))
	
	
	Humanoid:SetStateEnabled(Enum.HumanoidStateType.Physics,true)
	Humanoid:ChangeState(Enum.HumanoidStateType.Physics)
	Humanoid.AutoRotate = false
	Humanoid.PlatformStand = true
	
	
	if Humanoid.Health <= 0  then
		Humanoid:ChangeState(Enum.HumanoidStateType.Dead)
	end
		
	for _, v in ipairs(Character:WaitForChild('RagdollConstraints').Motors:GetChildren()) do
		v.Value.Enabled = false
	end
		
	task.delay(.05,function()
		for _, v : BasePart in pairs(Character:GetChildren()) do
			for _, part in pairs(CollisionParts) do
				if v.Name == part then
					v.CanCollide = true
					v.Massless = true
				end
			end
		end
	end)
end

function RagDoll:Disabled(Character : Model)

	
	local HumanoidRootPart : Part = Character.PrimaryPart
	local Humanoid : Humanoid = Character.Humanoid
	
	if Humanoid.Health >= 1 then

		for _, v in ipairs(Character.RagdollConstraints.Motors:GetChildren()) do
			v.Value.Enabled = true
		end
		

		
		Humanoid.AutoRotate = true
		Humanoid.PlatformStand = false
		Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
		HumanoidRootPart.CFrame = CFrame.new(HumanoidRootPart.Position + Vector3.new(0, .1, 0)) * CFrame.Angles(0, math.rad(HumanoidRootPart.Orientation.Y), 0)

		
	end
end

return RagDoll