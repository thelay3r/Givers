local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Shared = ReplicatedStorage:WaitForChild('Shared')
local Interfaces = Shared:WaitForChild('Interfaces')

local LocalPlayerInterfaces = require(Interfaces:WaitForChild('LocalPlayerInterfaces'))
type ILocalPlayer = LocalPlayerInterfaces.IClientPlayerComponent

local Player: ILocalPlayer

local PlayerStorage = {}

function PlayerStorage.SharePlayer(self: ILocalPlayer)
	Player = self
end

function PlayerStorage:GetPlayer()
	return Player
end

return PlayerStorage
