local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Bricks = ReplicatedStorage.Bricksv2

local _Components = Bricks:WaitForChild('Components')
local Data = Bricks:WaitForChild('Data')
local _Registries = Data:WaitForChild('Registries')
local AssetsHelper = require(ReplicatedStorage.Shared.Utilities.Modules.AssetsHelper)
local Registry = require(_Components.Registry)

local registry = Registry.new()



local Angles1 = {
	Front = {0, 60};
	Back = {120, 180};
};
	
local Angles2 = {
	Right = {0, 60};
	Left = {120, 180};
}

registry:Register('DashBodyVelocity', function(self,node)
	local Parent = self.Tags['Owner'].Instance.Character:FindFirstChild('HumanoidRootPart') :: BasePart
	local DashCFG = self.Tags['DashDirection']
	if not Parent then return end


	local BodyVelocityCFG = node.Config.BodyVelocity
	--local DashCFG = node.Config.DashConfig
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

registry:Register('FeintDash', function(self,node)
	
	local bodyVelocity = node.Additional['BodyVelocity']
	local _instance = bodyVelocity.BodyVelocityInstance :: BodyVelocity
	if not _instance then return end
	_instance:Destroy()

	self:Execute(
		{
			Name = 'Network.PlayVFX';
			SendParams = {
                    ['Player'] = {From = 'Owner', Path = {'Instance'}}
                };
			Config = 
			{
				VFXType = 'Animations.Dash';
				Client = true;
                EventData = {
                    State = 'Cancel';
                    Pack = 'Movement';
                };
			};
		})
		self:Execute({
			Name = 'Network.PlayVFX';
			SendParams = {
                 ['Player'] = {From = 'Owner', Path = {'Instance'}}
            };
			Config = 
			{
				VFXType = 'Dash.Cancel';
				Client = true;
                EventData = {
                    State = 'Start';
                    Pack = 'Movement';
                };
			};
		})

end)

registry:Register('GetDashDirection', function(self,node) 
	local Entity = node.Additional['Owner']
	if not Entity then return end

	local Character = Entity.Instance.Character
	local HumanoidRootPart = Character and Character:FindFirstChild('HumanoidRootPart')
	if not HumanoidRootPart then return end


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
		Back = 1,
		Left = 1,
		Right = 1,
	}

	local _vector = DIRECTION_VECTORS[mainDirection]
	local speed = (DIRECTION_SPEED_MULTIPLIERS[mainDirection] or 1)

	node.Config['MainDirection'] = mainDirection;
	node.Config['Vector'] = _vector;
	node.Config['Speed'] = speed;

end)

return registry