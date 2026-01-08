local ReplicatedStorage = game:GetService("ReplicatedStorage")
local _RunService = game:GetService("RunService")
local Bricks = ReplicatedStorage:WaitForChild('Bricksv2')
local Shared = ReplicatedStorage:WaitForChild('Shared')
local Interfaces = Shared:WaitForChild('Interfaces')
local PlayerInterfaces = require(ReplicatedStorage.Shared.Interfaces.PlayerInterfaces)
local _AssetsHelper = require(ReplicatedStorage.Modules.Utilities.AssetsHelper)
local TableHelper = require(ReplicatedStorage.Modules.Utilities.TableHelper)
local _TaskManager = require(ReplicatedStorage.Modules.Utilities.TaskManager)
local _IEntity = require(Interfaces:WaitForChild('EntityInterfaces'))

local Data = Bricks:WaitForChild('Data')
local AbilityFolder = Data:WaitForChild('Abilities')
local BlackList = require(AbilityFolder:WaitForChild('BlackList'))
local RunTimeList = require(AbilityFolder:WaitForChild('RunTimeList'))

local Components = Bricks:WaitForChild('Components')
local _Registries = Data:WaitForChild('Registries')

local Registry = require(Components:WaitForChild('Registry'))
local _AbilityParser = require(Components:WaitForChild('AbilityParser'))

local conditionRegistry = Registry.new()

type IEntity = _IEntity.IEntityComponent;

conditionRegistry:Register('==', function(self, node)  
	return node.Config.arg1 == node.Config.arg2
end)

conditionRegistry:Register('>=', function(self, node)  
	return node.Config.arg1 >= node.Config.arg2
end)

conditionRegistry:Register('>', function(self, node)  
	return node.Config.arg1 > node.Config.arg2
end)

conditionRegistry:Register('<', function(self, node)  
	return node.Config.arg1 < node.Config.arg2
end)

conditionRegistry:Register('OnCoolDown?', function(self,node)
	local nodeConfig = self.Tags['Main']
	local lastUsed = (nodeConfig.LastUsed) or (0)
	if tick() - lastUsed <= nodeConfig.CoolDown then return false end	
	return true
end)

conditionRegistry:Register('ResumeRun?',function(self,node)

	local owner = self.Tags['Owner']
	local ClientData = owner.ClientData
	local PressedKeys = ClientData.PressedKeys
	if not PressedKeys['W'] then 
		return false 
	end
	
	local RunAbility = owner:GetAbility('Run')
	local config = RunAbility.Instance.Tags['AcceleratMoveSpeed']
	config.AccelerationTime = .1
	RunAbility['OnStart'](RunAbility)
	config.AccelerationTime = .4


	return true
end)

conditionRegistry:Register('IsActive?', function(self,node)  

	local RootCFG = self.Tags['Main']
	return RootCFG.IsActive
end)

conditionRegistry:Register('IsEquipped?', function(self,node)  

	local Entity = self.Tags['Owner'] :: PlayerInterfaces.IServerPlayerComponent
	local session = Entity.SessionData
	return if session.CurrentEquipped ~= 'none' then true else false
end)

conditionRegistry:Register('RayCheck',function(self,node)
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


conditionRegistry:Register('DurationElapsed', function(self,node)  
	local elapsed = tick() - (self.Tags['Main'].CastTime or tick())
	local minDuration = self.Tags['Main'].MinDuration or 0
	return elapsed >= minDuration
end)

conditionRegistry:Register('RunTimeCheck?', function(self,node)
	
	local Entity : any & IEntity = node.Additional['Owner']
	local nodeConfig = node.Config
	local IgnoreList = (nodeConfig.Ignore) or ({})

	local RootCFG = self.Tags['Main']

	
	local sessionData = (Entity.SessionData)
	
	for _,v in pairs((nodeConfig['WhiteList'] or {})) do
		if (sessionData.StatusEffects[v] == false) then
			return false
		end
	end

	for _,v in pairs(RunTimeList) do 
		if (sessionData.StatusEffects[v] == true) and (not IgnoreList[v]) then 
			return false
		end
	end
	
	return true
end)

conditionRegistry:Register('BlackList?', function(self,node)
	
	local Entity : any & IEntity = node.Additional['Owner']
	local nodeConfig = node.Config
	local IgnoreList = (nodeConfig.Ignore) or ({})

	local RootCFG = self.Tags['Main']

	
	local sessionData = (Entity.SessionData)
	-- if IgnoreList.SelfActive then
	-- 	IgnoreList['ActiveSkill'] = true
	-- end

	for _,v in pairs(BlackList) do 
		if (sessionData.StatusEffects[v] == true) and (not IgnoreList[v]) then 
			return false
		end
	end
	

	if IgnoreList['IsActive'] then return true end
	if RootCFG.IsActive then return false end
	
	return true
end)


conditionRegistry:Register('CheckBlackList', function(self,node)

	local Status = self:Execute(
		{
			Name = 'Condition.BlackList?';
			RequestedTags = {['Owner'] = 'Owner'};
			Config = TableHelper:DeepTableClone(node.Config);
		})
	if not Status then return end
	
	local CoolDown = self:Execute({
			Name = 'Condition.OnCoolDown?';
			RequestedTags = {
				['Owner'] = 'Owner';
			},
		})
	
	if not CoolDown then return false end

	self:Execute({
		Name = 'Action.AbilityStatus';
		RequestedTags = {['Main'] = 'Main'};
		Config = TableHelper:DeepTableClone(node.Config);
	})
	return if (CoolDown and Status) then true else false
end)

conditionRegistry:Register('<=', function(self, node)  
	return node.Config.arg1 <= node.Config.arg2
end)

return conditionRegistry