local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ServerScriptService = game:GetService('ServerScriptService')
--local ServerStorage = game:GetService('ServerStorage')

local Shared = ReplicatedStorage:WaitForChild('Shared')
local Interfaces = Shared:WaitForChild('Interfaces')
local Utilities = Shared:WaitForChild('Utilities')
local NetWork = Utilities:WaitForChild('NetWork')

local ServerComponents = ServerScriptService:WaitForChild('Components')

local Ragdoll = require(ReplicatedStorage.Shared.Utilities.Modules.Ragdoll)
local SpeedController = require(ReplicatedStorage.Shared.Utilities.Modules.SpeedController)
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

		if args.Key == 'Space' then
		Entity.SessionData.StatusEffects.AfterSpace = true
		TaskManager:CreateTask(Player, 'SpaceHold', 2, function(a0) 
			 Entity.SessionData.StatusEffects.AfterSpace = false
		end)
	end

	else
		Entity.SessionData.PressedKeys[args.Key] = nil
	end
	
end)

Replicator:GetRemote('Global'):Connect('SpeedAmplify', function(player: Player,data)
	local Entity = EntityComponent.GetEntity(player.UserId) :: EntityInterfaces.IEntityComponent
	Entity.SpeedController.Data.Cache[data.Name] = data
end)

Replicator:GetRemote('GlobalFunction'):Connect('ValideSpeed', function()
	return true
end)

Replicator:GetRemote('Global'):Connect('SpeedRevert', function(player: Player,Name)
	local Entity = EntityComponent.GetEntity(player.UserId)
	if not Entity.SpeedController.Data.Cache[Name] then return end
	-- table.clear(Entity.SpeedController.Data.Cache[Name]) 
	-- Entity.SpeedController.Data.Cache[Name] = nil
	Entity:SetSpeedData('Cache',nil,Name)
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
	local Character = Entity.Instance.Character :: Model
	local Humanoid = Character:WaitForChild('Humanoid') :: Humanoid
	Humanoid.WalkSpeed = 12
	Humanoid.UseJumpPower = true
	
	Entity.SpeedController = SpeedController.new(Entity)
	Entity:AppendAbility('Default','Equip')
	Entity:AppendAbility('Fists','M1')
	Entity:AppendAbility('Fists','Critical')
	Entity:AppendAbility('Fists','Block')
	Entity:AppendPassive('Default', 'Stun')
	Entity:AppendPassive('Default', 'Block')
	Entity:AppendPassive('Default', 'Parry')
	Entity:AppendPassive('Default', 'Hit')
	Entity:AppendPassive('Default', 'TestAttack')
	Ragdoll:Setup(Character)
	--Ragdoll:Enabled(Character)
end)
