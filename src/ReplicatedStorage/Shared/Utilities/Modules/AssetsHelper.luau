local TweenService = game:GetService('TweenService')
local RunService = game:GetService('RunService')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Shared = ReplicatedStorage:WaitForChild('Shared')
local Interfaces = Shared:WaitForChild('Interfaces')
local Utilities = Shared:WaitForChild('Utilities')
local UtilModules = Utilities:WaitForChild('Modules')

local AssethelperInterfaces = require(Interfaces:WaitForChild('AssetHelperInterfaces'))

type IBodyVelocity = AssethelperInterfaces.IBodyVelocity
type ITrail = AssethelperInterfaces.ITrail

local TaskManager = require(UtilModules:WaitForChild('TaskManager'))

local AssetsHelper = {}

function AssetsHelper.CreateBodyVelocity(Data)
	
	local BodyVelocity = Instance.new('BodyVelocity')
	
	BodyVelocity:SetAttribute('Priority', Data.Instance.Priority or 1)
	
	BodyVelocity.Parent = Data.Instance.Parent
	BodyVelocity.MaxForce = Data.Instance.MaxForce
	BodyVelocity.P = Data.Instance.P
	BodyVelocity.Velocity = Data.Instance.Velocity or Vector3.zero
	
	TaskManager:CreateTask(BodyVelocity, 'Destroy', (Data.Instance.DestroyTime) or 1, function()
		BodyVelocity:Destroy()
	end)
	
	return BodyVelocity
	
end

function AssetsHelper.CreateTrail(Data: ITrail)
	local Trail = Data.Propertis.Instance:Clone()
	Trail.Parent = workspace.Map.VFXs
	Data.Propertis.Instance = Trail
	
	local tweld = Instance.new('Weld')
	tweld.Parent = Trail
	
	tweld.Part0 = Data.Propertis.Parent
	tweld.Part1 = Trail
	tweld.C0 = Data.Propertis.C0 or CFrame.new(0, 0, 0)
	tweld.C1 = Data.Propertis.C1 or CFrame.new(0, 0, 0)
	
	if Data.Settings.ChangeLifeTime then
		TaskManager:CreateTask(Trail, 'LifeTimeChanging', Data.Settings.ChangeLifeTime, function()
			Trail.Trail.Lifetime = Data.Settings.LifeTime
		end)
	end
	
	if Data.Settings.DisableTime then
		TaskManager:CreateTask(Trail, 'Disable', Data.Settings.DisableTime, function()
			Trail.Trail.Enabled = false
		end)
	end
	
	if Data.Settings.DestroyTime then
		TaskManager:CreateTask(Trail, 'Remove', Data.Settings.DestroyTime, function()
			Trail:Destroy()
		end)
	end
	
	return Data
	
end

return AssetsHelper
