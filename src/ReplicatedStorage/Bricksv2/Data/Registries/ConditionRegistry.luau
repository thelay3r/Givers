local ReplicatedStorage = game:GetService("ReplicatedStorage")
local _TracerService = game:GetService("TracerService")
local Bricks = ReplicatedStorage:WaitForChild('Bricksv2')
local Shared = ReplicatedStorage:WaitForChild('Shared')
local Interfaces = Shared:WaitForChild('Interfaces')
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

conditionRegisrty:Register('CheckCoolDown', function(self,node)
	local nodeConfig = node.Additional['Main']
	local lastUsed = (nodeConfig.LastUsed) or (0)
	if tick() - lastUsed <= nodeConfig.CoolDown then return false end
	nodeConfig.lastUsed = tick()
	
	return true
end)

conditionRegisrty:Register('IsActive?', function(self,node)  

	local RootCFG = node.Additional['Ability']
	return RootCFG.IsActive
end)

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
	if IgnoreList['CoolDown'] then return true end

	local CoolDown = self:Execute(
		{
			Name = 'Condition.CheckCoolDown';
			RequestedTags = {
				['Main'] = 'Main';
				['Owner'] = 'Owner';
			},
		})

	return if (CoolDown and true) then true else false
end)

conditionRegisrty:Register('CheckBlackList', function(self,node)
	
	local Status = self:Execute(
		{
			Name = 'Condition.BlackList?';
			RequestedTags = {['Owner'] = 'Owner'};
			Config = node.Config;
		})

	self:Execute(
		{
			Name = 'Ability.AbilityStatus';
			RequestedTags = {['Main'] = 'Main'};

		})

	return Status
end)

conditionRegisrty:Register('<=', function(self, node)  
	return node.Config.arg1 <= node.Config.arg2
end)

return conditionRegisrty