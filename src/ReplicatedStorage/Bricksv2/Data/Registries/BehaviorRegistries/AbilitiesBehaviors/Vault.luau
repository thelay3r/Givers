local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Bricks = ReplicatedStorage.Bricksv2

local _Components = Bricks:WaitForChild('Components')
local Data = Bricks:WaitForChild('Data')
local _Registries = Data:WaitForChild('Registries')
local AssetsHelper = require(ReplicatedStorage.Shared.Utilities.Modules.AssetsHelper)
local TaskManager = require(ReplicatedStorage.Shared.Utilities.Modules.TaskManager)
local Registry = require(_Components.Registry)


local registry = Registry.new()

registry:Register('CheckVault', function(self,node)
	local Owner = self.Tags['Owner']
	local _Instance = Owner.Instance
	local Character = _Instance.Character :: Model
	local RootPart = Character:FindFirstChild('HumanoidRootPart'):: BasePart

	TaskManager:CreateTask(self, 'VaultChecking', 0, function(a0)  
			while task.wait(1/30) do
			
				local raycast = self:Execute({
				Name = 'Action.Raycast',
				Config = {
					Position = RootPart.Position,
					Direction = RootPart.CFrame.LookVector * 5 + Vector3.new(0, -2, 0),
					Character = Character,
				}
			})
			if not raycast then continue end

			local rayInstance = raycast.Instance :: BasePart
			if not rayInstance:HasTag('Vault') then continue end


			local ability = Owner:GetAbility('Vault')
			ability['OnStart'](ability)
		end
	
	end)

	

	return true
end)

registry:Register('RootRayCheck',function(self,node)
	local Owner = self.Tags['Owner']
	local _Instance = Owner.Instance
	local Character = _Instance.Character :: Model
	local RootPart = Character:FindFirstChild('HumanoidRootPart') :: BasePart
	local cfg = node.Config

	local castData = {
		Position = RootPart.Position;
		Direction = RootPart.CFrame.LookVector * (cfg.Range or 1);
		Character = Character
	}
	local cast = AssetsHelper.FastCast(castData)
	if not cast then  return false end
	if not cast.Instance:HasTag('Vault') then return false end
	
	local RootPartPosition = RootPart.Position
	local InstancePosition = cast.Instance.Position
	local InstanceSize = cast.Instance.Size

	local Diff = (InstancePosition.Y + InstanceSize.Y/2) - RootPartPosition.Y
	if math.abs(Diff) > 1.5 then return false end

	node.Config['RayResult'] = {
		Instance = cast.Instance;
		Normal = cast.Normal;
		Position = cast.Position;
		Distance = cast.Distance;
	}
	return cast
end)

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