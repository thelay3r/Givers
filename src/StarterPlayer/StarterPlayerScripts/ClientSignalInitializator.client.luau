local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Players = game:GetService('Players')

local Shared = ReplicatedStorage:WaitForChild('Shared')
local Components = Shared:WaitForChild('Components')
local Interfaces = Shared:WaitForChild('Interfaces')
local Utilities = Shared:WaitForChild('Utilities')
local Utilmodules = Utilities:WaitForChild('Modules')
local NetWork = Utilities:WaitForChild('NetWork')
local VFXs = Shared:WaitForChild('VFXs')
local VFXReplica = VFXs:WaitForChild('Replica')

local AbilityInterfaces = require(Interfaces:WaitForChild('AbilityInerfaces'))
local LocalPlayerComponent = require(Components:WaitForChild('LocalPlayerComponent'))
local LocalPlayerInterfaces = require(Interfaces:WaitForChild('LocalPlayerInterfaces'))

type ILocalAbility = AbilityInterfaces.IAbilityComponent

local Replicator = require(NetWork:WaitForChild('Replicator'))
local PacketManager = require(NetWork:WaitForChild('Packets'))
local Replica = require(NetWork:WaitForChild('ReplicaClient'))

local Animator = require(Utilmodules:WaitForChild('Animator'))

local Player: LocalPlayerInterfaces.IClientPlayerComponent = LocalPlayerComponent:GetPlayer()

PacketManager['ReplicateAbilities'].OnClientEvent:Connect(function(abilities: {ILocalAbility})
	Player = LocalPlayerComponent:GetPlayer()
	Player:UpdateAbilities(abilities)
end)

Replicator:GetRemote('BindableGlobal'):Connect('Movement', function(args: {})
	Player = LocalPlayerComponent:GetPlayer()
	
	repeat if (not Player) or (not Player.ClientData) then
			Player = LocalPlayerComponent:GetPlayer()
			task.wait(0.5)
		end
	until (Player) and (Player.ClientData)
	
	local Movement = Player:GetPack('Movement')
	local Ability: ILocalAbility = Movement[args.Name]
	
	if args.Input == Ability.Key.Name then
		Ability[args.State](Ability)
	end
	
end)

Replicator:GetRemote('Global'):Connect('ReplicateAbilities', function(args: {})
	Player = LocalPlayerComponent:GetPlayer()
	repeat if (not Player) or (not Player.ClientData) then
			Player = LocalPlayerComponent:GetPlayer()
			task.wait(0.5)
		end
	until (Player) and (Player.ClientData)
end)

Replicator:GetRemote('VFX'):Connect('ReplicateNPCAnimations', function(args: {})
	Animator.InitNPCAnimations(args.NPC)
end)

Replicator:GetRemote('VFX'):Connect('VFX', function(args: {}, ...)
	
	if not (VFXReplica[args.Pack]) then return warn('Cannot find required pack.') end
	
	local Pack = VFXReplica[args.Pack]
	
	if not (Pack[args.Name]) then warn('VFX is nil.') return end
	
	local VFXModule = require(Pack[args.Name])
	
	if not (VFXModule[args.Func]) then warn('Function is nil.') return end
	
	VFXModule[args.Func](...)
	
end)

Replicator:GetRemote('BindableGlobal'):Connect('VFX', function(args: {}, ...)

	if not (VFXReplica[args.Pack]) then return warn('Cannot find required pack.') end

	local Pack = VFXReplica[args.Pack]

	if not (Pack[args.Name]) then warn('VFX is nil.') return end

	local VFXModule = require(Pack[args.Name])

	if not (VFXModule[args.Func]) then warn('Function is nil.') return end

	VFXModule[args.Func](...)

end)

Replica.OnNew('StatusEffects', function(replica)
	print(Replica)
	Replica.RequestData()
end)