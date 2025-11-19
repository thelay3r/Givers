local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Players = game:GetService('Players')

local Shared = ReplicatedStorage:WaitForChild('Shared')
local Interfaces = Shared:WaitForChild('Interfaces')

local StatesInterfaces = require(Interfaces:WaitForChild('StatesInterfaces'))

local States = require(script.Parent.States)

local Behaviors = {}

Behaviors.Replicate = {
	Replicate = {
		name = 'Replicate';
		priority = 1;
		check = function(self: StatesInterfaces.IStatesComponent)
			local Entity = self.args.Entity
			local Character = Entity.SessionData.CharacterData.Character

			if game.Players:GetPlayerFromCharacter(Character) then
				return true
			else
				return false
			end

		end,
		trueaction = function(self: StatesInterfaces.IStatesComponent)
			States['Replicate'].Replicate(self)
		end,

		falseaction = function(self: StatesInterfaces.IStatesComponent)

		end,
	};
}

return Behaviors
