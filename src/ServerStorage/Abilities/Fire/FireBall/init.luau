local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ServerScriptService = game:GetService('ServerScriptService')

local Shared = ReplicatedStorage:WaitForChild('Shared')
local Templates = Shared:WaitForChild('Templates')
local Interfaces = Shared:WaitForChild('Interfaces')

local EntityInterfaces = require(Interfaces:WaitForChild('EntityInterfaces'))
local AbilityInteraces = require(Interfaces:WaitForChild('AbilityInerfaces'))

export type IAbility = typeof(AbilitiesTemplate())

local ServerComponents = ServerScriptService:WaitForChild('Components')
local AbstractAbilities = require(ServerComponents:WaitForChild('AbstractAbilities'))

local EntityComponent = require(ServerComponents:WaitForChild('EntityComponent'))
local EntitiesComponent = require(ServerComponents:WaitForChild('EntitiesStorage'))
local AbilityComponent = require(ServerComponents:WaitForChild('EntityComponent'):WaitForChild('AbilityComponent'))

local Shared = ReplicatedStorage:WaitForChild('Shared')

local CFG = require(script.Config)

return function(UserId: string)
	
	local Entity: EntityInterfaces.IEntityComponent = EntitiesComponent:Get(UserId)
	
	local Ability: AbilityInteraces.IAbilitypreset = AbilityComponent:CreateAbility(Entity)
	Ability:LoadCFG(CFG)
	
	Ability.Functions.Start = function()
		print('StarFireBall')
	end
	
	Ability.Functions.End = function()
		print('EndFireBall')
		Entity.SessionData.StatusEffects.Click = false
	end
	
	return Ability
end