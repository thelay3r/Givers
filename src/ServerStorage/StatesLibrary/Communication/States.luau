local ReplicatedStorage = game:GetService('ReplicatedStorage')

local Shared = ReplicatedStorage:WaitForChild('Shared')
local Utilities = Shared:WaitForChild('Utilities')
local NetWork = Utilities:WaitForChild('NetWork')
local Interfaces = Shared:WaitForChild('Interfaces')

local StatesInterfaces = require(Interfaces:WaitForChild('StatesInterfaces'))

local Replicator = require(NetWork:WaitForChild('Replicator'))

local States = {}

States.Replicate = {
	Replicate = function(self: StatesInterfaces.IStatesComponent)
		local Entity = self.args.Entity
		local Player = game.Players:GetPlayerFromCharacter(Entity.SessionData.CharacterData.Character)
		
		Replicator:GetRemote('Global'):Fire(Player, 'ReplicateAbilities',
			{
				Abilities = table.clone(Entity.SessionData.Abilities);
				Packs = table.clone(Entity.SessionData.Packs);
			}
		)
	end,
}

return States
