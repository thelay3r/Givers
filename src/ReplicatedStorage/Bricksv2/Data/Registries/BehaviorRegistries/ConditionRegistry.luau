local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Bricks = ReplicatedStorage:WaitForChild('Bricksv2')
local Shared = ReplicatedStorage:WaitForChild('Shared')
local Interfaces = Shared:WaitForChild('Interfaces')
local PlayerInterfaces = require(ReplicatedStorage.Shared.Interfaces.PlayerInterfaces)
local AssetsHelper = require(ReplicatedStorage.Shared.Utilities.Modules.AssetsHelper)
local TaskManager = require(ReplicatedStorage.Shared.Utilities.Modules.TaskManager)
local _IEntity = require(Interfaces:WaitForChild('EntityInterfaces'))

local Data = Bricks:WaitForChild('Data')
local AbilityFolder = Data:WaitForChild('Abilities')
local BlackList = require(AbilityFolder:WaitForChild('BlackList'))

local Components = Bricks:WaitForChild('Components')
local _Registries = Data:WaitForChild('Registries')

local Registry = require(Components:WaitForChild('Registry'))
local _AbilityParser = require(Components:WaitForChild('AbilityParser'))

local conditionRegisrty = Registry.new()

type IEntity = _IEntity.IEntityComponent;

conditionRegisrty:Register('==', function(self, node)  
	return node.Config.arg1 == node.Config.arg2
end)

conditionRegisrty:Register('>=', function(self, node)  
	return node.Config.arg1 >= node.Config.arg2
end)

conditionRegisrty:Register('>', function(self, node)  
	return node.Config.arg1 > node.Config.arg2
end)

conditionRegisrty:Register('<', function(self, node)  
	return node.Config.arg1 < node.Config.arg2
end)

conditionRegisrty:Register('OnCoolDown?', function(self,node)
	local nodeConfig = self.Tags['Main']
	local lastUsed = (nodeConfig.LastUsed) or (0)
	if tick() - lastUsed <= nodeConfig.CoolDown then return false end	
	return true
end)

conditionRegisrty:Register('ResumeRun?',function(self,node)

	local owner = self.Tags['Owner']
	local ClientData = owner.ClientData
	local PressedKeys = ClientData.PressedKeys
	if not PressedKeys['W'] then 
		return false 
	end
	
	return true
end)

conditionRegisrty:Register('IsActive?', function(self,node)  

	local RootCFG = self.Tags['Main']
	return RootCFG.IsActive
end)

conditionRegisrty:Register('IsEquipped?', function(self,node)  

	local Entity = self.Tags['Owner'] :: PlayerInterfaces.IServerPlayerComponent
	local session = Entity.Replica.Data.Session
	print(session)
	return if session.CurrentEquipped ~= 'none' then true else false
end)

conditionRegisrty:Register('RayCheck',function(self,node)
	local Owner = self.Tags['Owner']
	local _Instance = Owner.Instance
	local Character = _Instance.Character :: Model
	local RootPart = Character:FindFirstChild('HumanoidRootPart') :: BasePart
	local Config = node.Config

	local cast = self:Execute({
		Name = 'Action.Raycast';
		Config = {
			Position = RootPart.Position;
			Direction = RootPart.CFrame[(Config.Vector) or 'LookVector'] * (Config.Range or 1);
			Character = Character
		}
	})

	if not cast then return false end

	node.Config['RayResult'] = {
		Instance = cast.Instance;
		Normal = cast.Normal;
		Position = cast.Position;
		Distance = cast.Distance;
	}

	return cast
end)

--[[conditionRegisrty:Register('RootRayCheck',function(self,node)
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
end)]]



conditionRegisrty:Register('BlackList?', function(self,node)
	
	local Entity : any & IEntity = node.Additional['Owner']
	local nodeConfig = node.Config
	local IgnoreList = (nodeConfig.Ignore) or ({})

	local RootCFG = node:GetRoot().Config
	
	if RootCFG.IsActive then return false end
	
	local sessionData = (Entity.SessionData) or (Entity.Replica.Data.Session)

	for _,v in pairs(BlackList) do 
		if (sessionData.StatusEffects[v] == true) and (not IgnoreList[v]) then 
			return false
		end
	end
	


	
	return true
end)

--[[conditionRegisrty:Register('CheckVault', function(self,node)
	local Owner = self.Tags['Owner']
	TaskManager:CreateTask(self, 'CheckVaultRun', 0,function(a0) 
		while task.wait(1/30) do
			local ability = Owner:GetAbility('Vault')
			ability['OnStart'](ability)
		end
	end)
end)]]

conditionRegisrty:Register('CheckBlackList', function(self,node)
	local Status = self:Execute(
		{
			Name = 'Condition.BlackList?';
			RequestedTags = {['Owner'] = 'Owner'};
			Config = node.Config;
		})

	self:Execute(
		{
			Name = 'Action.AbilityStatus';
			RequestedTags = {['Main'] = 'Main'};
			Config = node.Config;
		})

	local CoolDown = self:Execute(
		{
			Name = 'Condition.OnCoolDown?';
			RequestedTags = {
				['Owner'] = 'Owner';
			},
		})

	return if (CoolDown and Status) then true else false
end)

conditionRegisrty:Register('<=', function(self, node)  
	return node.Config.arg1 <= node.Config.arg2
end)

return conditionRegisrty