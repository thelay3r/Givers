local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ServerScriptService = game:GetService('ServerScriptService')
local ServerStorage = game:GetService('ServerStorage')

local Shared = ReplicatedStorage:WaitForChild('Shared')
local Utilities = Shared:WaitForChild('Utilities')
local NetWork = Utilities:WaitForChild('NetWork')
local UtilModules = Utilities:WaitForChild('Modules')
local Templates = Shared:WaitForChild('Templates')
local Interfaces = Shared:WaitForChild('Interfaces')

local StatesLibrary = ServerStorage:WaitForChild('StatesLibrary')
local AbilitiesStates = StatesLibrary:WaitForChild('Abilities')

local EntityInterfaces = require(Interfaces:WaitForChild('EntityInterfaces'))
local AbilityInteraces = require(Interfaces:WaitForChild('AbilityInerfaces'))

local ServerComponents = ServerScriptService:WaitForChild('Components')

local TaskManager = require(UtilModules:WaitForChild('TaskManager'))
local VFXReplica = require(NetWork:WaitForChild('VfxReplica'))
local StateManager = require(UtilModules:WaitForChild('StateManager'))
local EntityComponent = require(ServerComponents:WaitForChild('EntityComponent'))
local EntitiesComponent = require(ServerComponents:WaitForChild('EntitiesStorage'))
local AbilityComponent = require(ServerComponents:WaitForChild('EntityComponent'):WaitForChild('AbilityComponent'))

local CFG = require(script.Config)

return function(UserId: string)

	local Entity: EntityInterfaces.IEntityComponent = EntitiesComponent:Get(UserId)

	local Ability: AbilityInteraces.IAbilitypreset = AbilityComponent:CreateAbility(Entity)
	Ability:LoadCFG(CFG)

	Ability.Functions.Start = function()
		
		local SessionData = Entity.SessionData
		local StatusEffects = SessionData.StatusEffects
		local CharacterData = SessionData.CharacterData
		
		StatusEffects.Dashing = true
		
		VFXReplica:Fire(CharacterData.HumanoidRootPart,math.huge, 'VFX',
			{Pack = 'Movement',
				Name = 'Dash',
				Func = 'DashEffect'
			}, CharacterData.Character)
	end

	Ability.Functions.End = function()
		local SessionData = Entity.SessionData
		local StatusEffects = SessionData.StatusEffects
		local CharacterData = SessionData.CharacterData

		StatusEffects.Dashing = false
	end

	return Ability
end