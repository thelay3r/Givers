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

local EntityInterfaces = require(Interfaces:WaitForChild('EntityInterfaces'))
-- Server

local StateManager = require(UtilModules:WaitForChild('StateManager'))
local Packets = require(NetWork:WaitForChild('Packets'))
local Replicator = require(NetWork:WaitForChild('Replicator'))
local EntiyComponent = require(ServerComponents:WaitForChild('EntityComponent'))
local EntitiesComponent = require(ServerComponents:WaitForChild('EntitiesStorage'))

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

DefaultAbility.OnServerEvent:Connect(function(Player, args)
	local Entity: EntityInterfaces.IEntityComponent = EntitiesComponent:Get(Player.UserId)
	
	if not Entity then return end
	
	local Pack
	
	-- if Entity.SessionData.CurrentEquipped == 'none' then
	-- 	Pack = AbilityComponent.GetPack(Entity, 'Default')
	-- 	if (Pack[args.Name]) then
	-- 		if args.State == 'OnEnd' and Pack[args.Name].Config.Type == 'Toggle' then return end
	-- 		Pack[args.Name][args.State](Pack[args.Name])
	-- 	end
	-- else
	-- 	Pack = AbilityComponent.GetPack(Entity, Entity.SessionData.CurrentEquipped)
	-- 	if (Pack[args.Name]) then
	-- 		if args.State == 'OnEnd' and Pack[args.Name].Config.Type == 'Toggle' then return end
	-- 		Pack[args.Name][args.State](Pack[args.Name])
	-- 	end
	-- end
	
end)

Ability.OnServerEvent:Connect(function(Player, args)
	local Entity: EntityInterfaces.IEntityComponent = EntitiesComponent:Get(Player.UserId)

	if not Entity then return end

	--if not Entity.SessionData.Abilities[args.Scope][args.Name] then return end

	-- local Ability = AbilityComponent.GetAbility(Entity, args.Scope, args.Name)
	-- if args.State == 'OnEnd' and Ability.Config.Type == 'Toggle' then return end
	-- Ability[args.State](Ability)
end)

PackAbility.OnServerEvent:Connect(function(Player, args)
	local Entity: EntityInterfaces.IEntityComponent = EntitiesComponent:Get(Player.UserId)

    if not Entity then return end

	--if not Entity.SessionData.Packs[args.Scope][args.Name] then return end

	-- local Pack = AbilityComponent.GetPack(Entity, args.Scope)
	
	-- if not (Pack[args.Name]) then return end
	
	-- local Ability = Pack[args.Name]
	
	-- if args.State == 'OnEnd' and Ability.Config.Type == 'Toggle' then return end
	-- Ability[args.State](Ability)
end)

Replicator:GetRemote('BindableGlobal'):Connect('SetUp', function(UserId: string)
	
	local Entity: EntityInterfaces.IEntityComponent = EntitiesComponent:Get(UserId)
	
	--if Entity.SessionData.Equipment.Weapon == 'none' or nil then return end
	
	-- local DefaultPath = AbilitiesFolder:WaitForChild('Default')
	-- local StylePath = AbilitiesFolder:WaitForChild(Entity.SessionData.Equipment.Style)
	-- local MovementPath = AbilitiesFolder:WaitForChild('Movement')
	
	-- local StylePack = Entity:AddPack(StylePath)
	-- local DefaultPack = Entity:AddPack(DefaultPath)
	-- local MovementPack = Entity:AddPack(MovementPath)
	
	-- --local WeaponPack = Entity:AddPack(AbilitiesFolder)
	
	-- local FireBallAbility = Entity:AddAbility(ServerStorage:FindFirstChild('Abilities'):FindFirstChild('Fire'), 'FireBall')
	-- StateManager:New(
	-- 	{
	-- 		FOLDER = StatesLibraryS['Communication'];
	-- 		SECTION_NAME = 'Replicate';
	-- 		LOCK_MODE = false;
	-- 		IGNORE = true;
	-- 		LAUNCH = false;
	-- 		Entity = Entity;
	-- 	}
	-- )
	
end)