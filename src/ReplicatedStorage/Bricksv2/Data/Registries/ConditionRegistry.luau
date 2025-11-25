local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TracerService = game:GetService("TracerService")
local Bricks = ReplicatedStorage:WaitForChild('Bricksv2')
local Shared = ReplicatedStorage:WaitForChild('Shared')
local Interfaces = Shared:WaitForChild('Interfaces')
local Config = require(ReplicatedStorage.Shared.Abilities.Movement.Dash.Config)
local _IEntity = require(Interfaces:WaitForChild('EntityInterfaces'))

local Components = Bricks:WaitForChild('Components')
local Data = Bricks:WaitForChild('Data')
local Registries = Data:WaitForChild('Registries')

local Registry = require(Components:WaitForChild('Registry'))
local AbilityParser = require(Components:WaitForChild('AbilityParser'))

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
	local lastUsed = nodeConfig.LastUsed
	if tick() - lastUsed <= nodeConfig.CoolDown then return false end
	nodeConfig.lastUsed = tick()
	print(node)
	
	return true
end)

conditionRegisrty:Register('IsActive?', function(self,node)  

	local RootCFG = node.Additional['Ability']

	return RootCFG.IsActive
end)



conditionRegisrty:Register('CheckBlackList', function(self,node)
	print(node.Additional['Owner'])
	local Entity : IEntity = node.Additional['Owner']
	local nodeConfig = node.Config
	local IgnorList = (nodeConfig.Ignor ) or ({})

	local RootCFG = node:GetRoot().Config
	if RootCFG.IsActive then return false end

	local BlackList = 
	{
		'Block';
		'Click';
		'Dashing';
		'GreatStunned';
		'IsDead';
		'NockDown';
		'Parry';
		'Ragdolled';
		'Stun';
		'Vaulting';
	}
	
	for _,v in pairs(BlackList) do 
		if (Entity.SessionData.StatusEffects[v] == true) and (not IgnorList[v]) then 
			return false
		end
	end
	
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

conditionRegisrty:Register('<=', function(self, node)  
	return node.Config.arg1 <= node.Config.arg2
end)

return conditionRegisrty