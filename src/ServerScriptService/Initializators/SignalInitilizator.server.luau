local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ServerScriptService = game:GetService('ServerScriptService')
--local ServerStorage = game:GetService('ServerStorage')

local Shared = ReplicatedStorage:WaitForChild('Shared')
local Interfaces = Shared:WaitForChild('Interfaces')
local Utilities = Shared:WaitForChild('Utilities')
local NetWork = Utilities:WaitForChild('NetWork')

local ServerComponents = ServerScriptService:WaitForChild('Components')

local TaskManager = require(ReplicatedStorage.Shared.Utilities.Modules.TaskManager)
local EntityInterfaces = require(Interfaces:WaitForChild('EntityInterfaces'))
-- Server

local Packets = require(NetWork:WaitForChild('Packets'))
local Replicator = require(NetWork:WaitForChild('Replicator'))
local EntitiesComponent = require(ServerComponents:WaitForChild('EntitiesStorage'))
local EntityComponent = require(ServerScriptService.Components.EntityComponent)


local Ability = Packets.Ability
local ReplicateKeys = Packets.ReplicateKeys

local BindableGlobal = Replicator:GetRemote('BindableGlobal')


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

	local ability = Entity:GetAbility(args.Name)
	if not ability then return end
	local node = ability.Instance.Tree
	local config = node.Config
	local PlayerPressed = if args.State == 'OnStart' then true else false
	config.PlayerPressed = PlayerPressed

	if args.Blocked then
		return
	end
	ability[args.State](ability)

end)


BindableGlobal:Connect('SetUp', function(UserId: string)
	
	local Entity = EntityComponent.GetEntity(UserId) :: EntityInterfaces.IEntityComponent
	Entity:AppendAbility('Default','Equip')
	Entity:AppendAbility('Fists','M1')
	Entity:AppendAbility('Fists','Critical')
	Entity:AppendPassive('Default', 'Stun')

	print(Entity)
end)
