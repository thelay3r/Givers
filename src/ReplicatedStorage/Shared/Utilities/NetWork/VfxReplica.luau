local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage.Shared
local Utilities = Shared.Utilities
local NetWork = Utilities.NetWork

local Replicator = require(NetWork:FindFirstChild("Replicator"))

local VFXReplica = {}



function VFXReplica:Fire(BasePart : BasePart,Radius : number, SignalName: string, ...)
	local Position = BasePart.Position
	Replicator:GetRemote("VFX"):FireInRadius(Position,Radius,SignalName,...)
end

function VFXReplica:SingleFire(Player : Player, SignalName: string, ...)
	if type(Player) ~= "userdata" then
		local Character = Player.Character.PrimaryPart
		VFXReplica:Fire(Character,500,...)
		return
	end
	Replicator:GetRemote("VFX"):Fire(Player,SignalName,...)
end



return VFXReplica
