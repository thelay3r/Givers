local ServerScriptService = game:GetService('ServerScriptService')
local ReplicatedStorage = game:GetService('ReplicatedStorage')

local Shared = ReplicatedStorage:WaitForChild('Shared')
local Interfaces = Shared:WaitForChild('Interfaces')

local AbilityInterfaces = require(Interfaces:WaitForChild('AbilityInerfaces'))
local StatesInterfaces = require(Interfaces:WaitForChild('StatesInterfaces'))

local States = require(script.Parent.States)

local Behaviors = {}

Behaviors.Abilities = {
	TypeCheck = {
		priority = 1;

		check = function(self: StatesInterfaces.IStatesComponent)
			local Ability: AbilityInterfaces.IAbilityComponent = self.args.Ability

			if Ability.Config.Type == 'Toggle' then
				return true
			else
				return false
			end

		end,

		trueaction = function(self: StatesInterfaces.IStatesComponent)
			States.Abilities.Toggle(self)
		end,

		falseaction = function(self: StatesInterfaces.IStatesComponent)
			States.Abilities.Hold(self)
		end,
	};
	
};

return Behaviors
