local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Modules = ReplicatedStorage:WaitForChild('Modules')
local NetWork = Modules.NetWork

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
