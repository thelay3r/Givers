local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ServerScriptService = game:GetService('ServerScriptService')
--local ServerStorage = game:GetService('ServerStorage')

local Shared = ReplicatedStorage:WaitForChild('Shared')
local Interfaces = Shared:WaitForChild('Interfaces')
local Utilities = Shared:WaitForChild('Utilities')
local NetWork = Utilities:WaitForChild('NetWork')

local ServerComponents = ServerScriptService:WaitForChild('Components')

local EntityInterfaces = require(Interfaces:WaitForChild('EntityInterfaces'))
-- Server

local Packets = require(NetWork:WaitForChild('Packets'))
local Replicator = require(NetWork:WaitForChild('Replicator'))
local EntitiesComponent = require(ServerComponents:WaitForChild('EntitiesStorage'))
local EntityComponent = require(ServerScriptService.Components.EntityComponent)


local Ability = Packets.Ability
local ReplicateKeys = Packets.ReplicateKeys

local BindableGlobal = Replicator:GetRemote('BindableGlobal')

BindableGlobal:Connect('PlayVFX', function()
	
	
	
end)

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
	local Entity = EntitiesComponent:Get(Player.UserId) :: EntityInterfaces.IEntityComponent
	if not Entity then return end

	print(args)
	local ability = Entity:GetAbility(args.Name)
	if not ability then return end
	print(ability)
	ability[args.State](ability)

end)


BindableGlobal:Connect('SetUp', function(UserId: string)
	
	local Entity = EntitiesComponent:Get(UserId) :: EntityInterfaces.IEntityComponent
	print(EntitiesComponent:Get(tostring(UserId)),UserId)
	Entity:AppendAbility('Default','Equip')
	Entity:AppendAbility('Fists','M1')

end)

BindableGlobal:Connect('PlayVFX',function(args)
	if not args.FirePosition then args.FirePosition = Vector3.zero end

	Replicator:GetRemote('VFX'):FireInRadius(args.FirePosition,512, args)
end)