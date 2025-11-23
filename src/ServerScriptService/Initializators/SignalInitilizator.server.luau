local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ServerScriptService = game:GetService('ServerScriptService')
--local ServerStorage = game:GetService('ServerStorage')

local Shared = ReplicatedStorage:WaitForChild('Shared')
local Interfaces = Shared:WaitForChild('Interfaces')
local Utilities = Shared:WaitForChild('Utilities')
local UtilModules = Utilities:WaitForChild('Modules')
local NetWork = Utilities:WaitForChild('NetWork')

local Services = ServerScriptService:WaitForChild('Services')
local ServerComponents = ServerScriptService:WaitForChild('Components')

local nameOf = require(ReplicatedStorage.Shared.Utilities.Modules.Fusion.Utility.nameOf)
local EntityInterfaces = require(Interfaces:WaitForChild('EntityInterfaces'))
-- Server

local StateManager = require(UtilModules:WaitForChild('StateManager'))
local Packets = require(NetWork:WaitForChild('Packets'))
local Replicator = require(NetWork:WaitForChild('Replicator'))
local EntiyComponent = require(ServerComponents:WaitForChild('EntityComponent'))
local EntitiesComponent = require(ServerComponents:WaitForChild('EntitiesStorage'))
local AbilityHandler = require(ServerComponents:WaitForChild('AbilityHandler'))


local DefaultAbility = Packets.DefaultAbility
local Ability = Packets.Ability
local PackAbility = Packets.PackAbility
local ReplicateKeys = Packets.ReplicateKeys

ReplicateKeys.OnServerEvent:Connect(function(Player, args)
	local Entity: EntityInterfaces.IEntityComponent = EntitiesComponent:Get(Player.UserId)

	if not Entity then return end
	
	if args.State == 'Begin' then
		Entity.SessionData.PressedKeys[args.Key] = args.Key
	else
		Entity.SessionData.PressedKeys[args.Key] = nil
	end
	
end)



Ability.OnServerEvent:Connect(function(Player, args)
	local Entity: EntityInterfaces.IEntityComponent = EntitiesComponent:Get(Player.UserId)
	if not Entity then return end

	local ability = Entity:GetAbility(args.Name)
	if not ability then return end
	ability[args.State](ability)

end)


Replicator:GetRemote('BindableGlobal'):Connect('SetUp', function(UserId: string)
	
	local Entity: EntityInterfaces.IEntityComponent = EntitiesComponent:Get(UserId)

end)