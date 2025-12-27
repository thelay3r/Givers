local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Bricks = ReplicatedStorage.Bricksv2

local _Components = Bricks:WaitForChild('Components')
local Data = Bricks:WaitForChild('Data')
local _Registries = Data:WaitForChild('Registries')
local TaskManager = require(ReplicatedStorage.Shared.Utilities.Modules.TaskManager)
local Registry = require(_Components.Registry)


local registry = Registry.new()


registry:Register('Vaulting', function(self,node)
	local Owner = self.Tags['Owner']
	local _Instance = Owner.Instance
	local Character = _Instance.Character :: Model
	local RootPart = Character:FindFirstChild('HumanoidRootPart'):: BasePart
	local raycast = node.Additional['RayResult']['RayResult']
	if not raycast then return end
	local rayInstance = raycast.Instance :: BasePart
	if not rayInstance:HasTag('Vault') then return end
	rayInstance.CanCollide = false 

	Character:FindFirstChildOfClass('Humanoid').JumpPower = 0

	self:Execute(
		{
			Name = 'Action.DestroyBodyVelocity';
			Config = {
				Part = 'HumanoidRootPart'
			}
		})
	self:Execute(
		{
			Name = 'Action.BodyVelocity';
			Config = 
			{
				MaxForce = Vector3.one * 15000;
				P = 15000;
				DestroyTime = .2;
				Velocity = RootPart.CFrame.LookVector * 25 + RootPart.CFrame.UpVector * 10;
				Parent = RootPart;
			};
		})
	TaskManager:CreateTask(node, 'CanCollideOff', .3, function(a0)
		rayInstance.CanCollide = true 
		Character:FindFirstChildOfClass('Humanoid').JumpPower = 50
	end)
end)

return registry