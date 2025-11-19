local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ServerScriptService = game:GetService('ServerScriptService')
local ServerStorage = game:GetService('ServerStorage')

local Shared = ReplicatedStorage:WaitForChild('Shared')
local Utilities = Shared:WaitForChild('Utilities')
local UtilModules = Utilities:WaitForChild('Modules')
local Templates = Shared:WaitForChild('Templates')
local Interfaces = Shared:WaitForChild('Interfaces')

local StatesLibrary = ServerStorage:WaitForChild('StatesLibrary')
local AbilitiesStates = StatesLibrary:WaitForChild('Abilities')

local States = AbilitiesStates[script.Parent.Name]['States']
local Behaviors = AbilitiesStates[script.Parent.Name]['Behaviors']

local EntityInterfaces = require(Interfaces:WaitForChild('EntityInterfaces'))
local AbilityInteraces = require(Interfaces:WaitForChild('AbilityInerfaces'))

local ServerComponents = ServerScriptService:WaitForChild('Components')

local StateManager = require(UtilModules:WaitForChild('StateManager'))
local EntityComponent = require(ServerComponents:WaitForChild('EntityComponent'))
local EntitiesComponent = require(ServerComponents:WaitForChild('EntitiesStorage'))
local AbilityComponent = require(ServerComponents:WaitForChild('EntityComponent'):WaitForChild('AbilityComponent'))

local CFG = require(script.Config)

return function(UserId: string)

	local Entity: EntityInterfaces.IEntityComponent = EntitiesComponent:Get(UserId)

	local Ability: AbilityInteraces.IAbilitypreset = AbilityComponent:CreateAbility(Entity)
	Ability:LoadCFG(CFG)

	local state = StateManager:New(
		{
			FOLDER = AbilitiesStates.Fists;
			SECTION_NAME = 'Equip';
			Entity = Entity;
			BEHAVIOR_NAME = 'EquipCheck';
			LAUNCH = false;
		}
	)

	Ability.Functions.Start = function()
		print('START')
		state:CheckBehavior()
	end

	Ability.Functions.End = function()
		print('END_FUNC')
	end

	return Ability
end