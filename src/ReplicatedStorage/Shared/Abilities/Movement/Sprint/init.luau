local ReplicatedStorage = game:GetService('ReplicatedStorage')

local Shared = ReplicatedStorage:WaitForChild('Shared')
local Components = Shared:WaitForChild('Components')
local Utilities = Shared:WaitForChild('Utilities')
local UtilModules = Utilities:WaitForChild('Modules')
local Templates = Shared:WaitForChild('Templates')
local Interfaces = Shared:WaitForChild('Interfaces')

local StatesLibrary = Shared:WaitForChild('StatesLibrary')
local AbilitiesStates = StatesLibrary:WaitForChild('Abilities')

local PlayerInterfaces = require(Interfaces:WaitForChild('LocalPlayerInterfaces'))
local AbilityInteraces = require(Interfaces:WaitForChild('AbilityInerfaces'))

local StateManager = require(UtilModules:WaitForChild('StateManager'))
local PlayerComponent = require(Components:WaitForChild('LocalPlayerComponent'))
local AbilityComponent = require(UtilModules:WaitForChild('ClientAbilities'))
local SpeedComponent = require(UtilModules:WaitForChild('SpeedController'))
local TaskManager = require(UtilModules:WaitForChild('TaskManager'))
local AnimationsComponent = require(UtilModules:WaitForChild('AnimationsComponent'))

local VFXs = Shared:WaitForChild('VFXs')
local Assets = VFXs:WaitForChild('Assets')
local DefaultAssets = Assets:WaitForChild('Default')
local Animations = DefaultAssets:WaitForChild('Animations')


type IPlayer = PlayerInterfaces.IClientPlayerComponent

local CFG = require(script.Config)

return function(Player: PlayerInterfaces.IClientPlayerComponent)

	local Ability: AbilityInteraces.IAbilityComponent = AbilityComponent:CreateAbility(Player)
	Ability:LoadCFG(CFG)

	local VaultState = StateManager:New(
		{
			FOLDER = AbilitiesStates.Movement;
			SECTION_NAME = 'Vaulting';
			Entity = Player;
			LAUNCH = false;
			Ability = Ability;
		}
	)

	Ability.Functions.Start = function()
		
		local ClientData = Player.ClientData
		local CharacterData = ClientData.CharacterData
		local Character = CharacterData.Character
		local Humanoid = CharacterData.Humanoid
		local Animate = AnimationsComponent.new(Character)
		
		local _,data = Animate:Load(Animations.Run,
			{
				Name = 'Walk';
				_Name = 'DefaultRun';
				Priority = Enum.AnimationPriority.Movement.Name;
			})
		
		Animate:Swap(
			{
				Name = 'Walk';
				_Name = 'DefaultRun';
				Priority = Enum.AnimationPriority.Movement.Name;
				
			})
		
		Player.ClientData.StatusEffects.IsRunning = true
		Player:LaunchWobbling()
		Player:ChangeFOV(
			{
				useTween = true;
				FOV = 85;
				TweenInfo_S = TweenInfo.new(.8,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut)
				
			})
		
		local SpeedController = SpeedComponent.new(Character)
		
		TaskManager:CreateTask(Player, 'VaultCheck', nil, function()
			while true do
				VaultState:CheckBehavior()
				task.wait(1/10)
			end
		end)
		
		TaskManager:CreateTask(Player, 'SpeedSwap', nil, function()
			for i = 1,10 do
				SpeedController:Amplify(
					{
						Name = 'Run';
						Percent = 10;
						InitSpeed = 12;

					})
				Animate:AdjustSpeed(data,Humanoid.WalkSpeed/24)
				task.wait(1/25)
			end
		end)
	end

	Ability.Functions.SpecialStart = function()

		local ClientData = Player.ClientData
		local CharacterData = ClientData.CharacterData
		local Character = CharacterData.Character
		local Humanoid = CharacterData.Humanoid
		local Animate = AnimationsComponent.new(Character)

		local _,data = Animate:Load(Animations.Run,
			{
				Name = 'Walk';
				_Name = 'DefaultRun';
				Priority = Enum.AnimationPriority.Movement.Name;
			})

		Animate:Swap(
			{
				Name = 'Walk';
				_Name = 'DefaultRun';
				Priority = Enum.AnimationPriority.Movement.Name;

			})

		Player.ClientData.StatusEffects.IsRunning = true
		Player:LaunchWobbling()
		Player:ChangeFOV(
			{
				useTween = false;
				FOV = 85;

			})

		local SpeedController = SpeedComponent.new(Character)

		TaskManager:CreateTask(Player, 'VaultCheck', nil, function()
			while true do
				VaultState:CheckBehavior()
				task.wait(1/10)
			end
		end)

		TaskManager:CreateTask(Player, 'SpeedSwap', nil, function()
			SpeedController:Amplify(
				{
					Name = 'Run';
					Percent = 100;
					InitSpeed = 12;

				})
			Animate:AdjustSpeed(data,Humanoid.WalkSpeed/24)
		end)
	end

	Ability.Functions.End = function()
		
		local ClientData = Player.ClientData
		local CharacterData = ClientData.CharacterData
		local StatusEffects = ClientData.StatusEffects
		local Character = CharacterData.Character
		local Humanoid = CharacterData.Humanoid

        if not StatusEffects.IsRunning then return end

		local Animate = AnimationsComponent.new(Character)
		TaskManager:CancelTask(Player, 'SpeedSwap')
		TaskManager:CancelTask(Player, 'VaultCheck')
		local SpeedController = SpeedComponent.new(Character)
		
		--if Ability:CheckBlacklist(Ability.Config.Blacklist) then return end
		
		SpeedController:Revert(
			{
				Name = 'Run';
				Recursive = false;
			})

		local _,data =Animate:Load(Animations.Run,
			{
				Name = 'Walk';
				_Name = 'DefaultRun';
				Priority = Enum.AnimationPriority.Movement.Name;
			})
		Animate:Swap(
			{
				Name = 'Walk';
				_Name = 'DefaultWalk';
				Priority = Enum.AnimationPriority.Movement.Name;

			})
		
		
		--Humanoid.WalkSpeed = 12
		Player.ClientData.StatusEffects.IsRunning = false
		Player:StopWobbling()

		if not StatusEffects.Dashing then
			Player:ChangeFOV(
				{
					useTween = true;
					FOV = 70;
					TweenInfo_S = TweenInfo.new(.45,Enum.EasingStyle.Sine,Enum.EasingDirection.Out)

				})
		end
	end

	return Ability
end