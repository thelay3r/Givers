local ReplicatedStorage = game:GetService('ReplicatedStorage')

local Shared = ReplicatedStorage:WaitForChild('Shared')
local Components = Shared:WaitForChild('Components')
local Utilities = Shared:WaitForChild('Utilities')
local UtilModules = Utilities:WaitForChild('Modules')
local Templates = Shared:WaitForChild('Templates')
local Interfaces = Shared:WaitForChild('Interfaces')

local StatesLibrary = Shared:WaitForChild('StatesLibrary')
local AbilitiesStates = StatesLibrary:WaitForChild('Abilities')

local PlayerInterfaces = require(Interfaces:WaitForChild('LocalPlayerInterfaces'))
local AbilityInteraces = require(Interfaces:WaitForChild('AbilityInerfaces'))

local StateManager = require(UtilModules:WaitForChild('StateManager'))
local PlayerComponent = require(Components:WaitForChild('LocalPlayerComponent'))
local AbilityComponent = require(UtilModules:WaitForChild('ClientAbilities'))

local TaskManager = require(UtilModules:WaitForChild('TaskManager'))
local AnimationsComponent = require(UtilModules:WaitForChild('AnimationsComponent'))

local VFXs = Shared:WaitForChild('VFXs')
local Assets = VFXs:WaitForChild('Assets')
local DefaultAssets = Assets:WaitForChild('Default')
local Animations = DefaultAssets:WaitForChild('Animations')


type IPlayer = PlayerInterfaces.IClientPlayerComponent

local CFG = require(script.Config)

return function(Player: PlayerInterfaces.IClientPlayerComponent)

	local Ability: AbilityInteraces.IAbilityComponent = AbilityComponent:CreateAbility(Player)
	Ability:LoadCFG(CFG)

	local state = StateManager:New(
		{
			FOLDER = AbilitiesStates.Movement;
			SECTION_NAME = 'Vaulting';
			Entity = Player;
			LAUNCH = false;
			Ability = Ability;
		}
	)
	
	local ClientData = Player.ClientData

	Ability.Functions.Start = function()
		if not ClientData.StatusEffects.IsRunning then
			state:CheckBehavior()
		end
	end

	Ability.Functions.End = function()
		
	end

	return Ability
end