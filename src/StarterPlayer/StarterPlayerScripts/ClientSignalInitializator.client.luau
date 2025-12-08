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

local _AbilityHandler = require(ReplicatedStorage.Shared.Utilities.Modules.AbilityHandler)
local LocalPlayerComponent = require(Components:WaitForChild('LocalPlayerComponent'))
local LocalPlayerInterfaces = require(Interfaces:WaitForChild('LocalPlayerInterfaces'))


local Replicator = require(NetWork:WaitForChild('Replicator'))
local _PacketManager = require(NetWork:WaitForChild('Packets'))
local Replica = require(NetWork:WaitForChild('ReplicaClient'))

local Packets = require(NetWork:WaitForChild('Packets'))
local AbilityPacket = Packets.Ability

local Animator = require(Utilmodules:WaitForChild('Animator'))

local Player: LocalPlayerInterfaces.IClientPlayerComponent = LocalPlayerComponent:GetPlayer()

local BindableGlobal = Replicator:GetRemote('BindableGlobal')

Replicator:GetRemote('Global'):Connect('ReplicateAbilities', function(args)
	Player = LocalPlayerComponent:GetPlayer()
	repeat if (not Player) or (not Player.ClientData) then
			Player = LocalPlayerComponent:GetPlayer()
			task.wait(0.5)
		end
	until (Player) and (Player.ClientData)
end)

Replicator:GetRemote('VFX'):Connect('ReplicateNPCAnimations', function(args)
	Animator.InitNPCAnimations(args.NPC)
end)

Replicator:GetRemote('VFX'):Connect('VFX', function(args, ...)
	
	if not (VFXReplica[args.Pack]) then return warn('Cannot find required pack.') end
	
	local Pack = VFXReplica[args.Pack]
	
	if not (Pack[args.Name]) then warn('VFX is nil.') return end
	
	local VFXModule = require(Pack[args.Name])
	
	if not (VFXModule[args.Func]) then warn('Function is nil.') return end
	
	VFXModule[args.Func](...)
	
end)

BindableGlobal:Connect('VFX', function(args, ...)

	if not (VFXReplica[args.Pack]) then return warn('Cannot find required pack.') end

	local Pack = VFXReplica[args.Pack]

	if not (Pack[args.Name]) then warn('VFX is nil.') return end

	local VFXModule = require(Pack[args.Name])

	if not (VFXModule[args.Func]) then warn('Function is nil.') return end

	VFXModule[args.Func](...)

end)

Replica.OnNew('StatusEffects', function(replica)
	Replica.RequestData()
end)

BindableGlobal:Connect('PlayerInitialized', function(args)
	Player = LocalPlayerComponent:GetPlayer()
	Player:AppendAbility('Movement','Run')
	Player:AppendAbility('Movement','Dash')
	Player:AppendAbility('Movement','Vault')
	Player:AppendAbility('Movement','Slide')
end)

BindableGlobal:Connect('LocalAbility', function(args)
	_Player = LocalPlayerComponent:GetPlayer()
	if not _Player.ClientData.Abilities[args.Name] then return end
	local abilityName = _Player.ClientData.Abilities[args.Name].Name
	local ability = _Player:GetAbility(abilityName)
	print(abilityName)
	print(args.State)
	ability[args.State](ability)
end)


BindableGlobal:Connect('ServerAbility', function(args)
	local _Player = LocalPlayerComponent:GetPlayer()
	local ClientReplica = _Player.Replica
	local sessionData = ClientReplica.Data.Session
	local Abilities = sessionData.Abilities
	local ability = Abilities[args.Name]
	
	AbilityPacket:Fire(
		{
			Name = ability.Name;
			State = args.State;
		})

end)