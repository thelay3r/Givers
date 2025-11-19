local RunService = game:GetService('RunService')
local ReplicatedStorage = game:GetService('ReplicatedStorage')

local Shared = ReplicatedStorage:WaitForChild('Shared')
local Interfaces = Shared:WaitForChild('Interfaces')
local Utilities = Shared:WaitForChild('Utilities')
local UtilModules = Utilities:WaitForChild('Modules')
local NetWork = Utilities:WaitForChild('NetWork')

local Animations = Shared.VFXs.Assets.Default.Animations

local TaskManager = require(UtilModules:WaitForChild('TaskManager'))
local AssetsHelper = require(UtilModules:WaitForChild('AssetsHelper'))
local Replica = require(NetWork:WaitForChild('VfxReplica'))

local AbilityInterfaces = require(Interfaces:WaitForChild('AbilityInerfaces'))
local AnimationInterfaces = require(Interfaces:WaitForChild('AnimationsInterfaces'))
local StatesInterfaces = require(Interfaces:WaitForChild('StatesInterfaces'))
local LocalPlayerInterfaces = require(Interfaces:WaitForChild('LocalPlayerInterfaces'))

local Packets = require(NetWork:WaitForChild('Packets'))
local Replicator = require(NetWork:WaitForChild('Replicator'))
local AssetsHelper = require(UtilModules:WaitForChild('AssetsHelper'))
local SpeedComponent = require(UtilModules:WaitForChild('SpeedController'))
local CountHandler = require(UtilModules:WaitForChild('CountHandler'))
local AnimationsComponent = require(UtilModules:WaitForChild('AnimationsComponent'))
local BiezeModule = require(UtilModules:WaitForChild('BiezeModule'))

type IAbility = AbilityInterfaces.IAbilityComponent
type IPlayer = LocalPlayerInterfaces.IClientPlayerComponent

local PackAbility = Packets.PackAbility

local States = {}

States.Vaulting = {
		Vault = function(self: StatesInterfaces.IStatesComponent, args: {})
		  	local Player: IPlayer = self.args.Entity
		  	local ClientData = Player.ClientData
		  	local CharacterData = ClientData.CharacterData
		  	local StatusEffects = ClientData.StatusEffects

		  	local Character = CharacterData.Character
		  	local Humanoid = CharacterData.Humanoid
		  	local HumanoidRootPart = CharacterData.HumanoidRootPart

		    local SpeedController = SpeedComponent.new(Character)

		    local Animate = AnimationsComponent.new(Character)

		  	local Vault: Part = args.Vault
		  	local PlayerPosition: Vector3 = args.PlayerPosition
		  	local PlayerCFrame: CFrame = args.PlayerCFrame
		   
			local DestroyTime = 0.325
			local AnimSpeed = 1
		   
		  	Humanoid.JumpPower = 0
		   
			PackAbility:Fire(
				{
					Scope = 'Movement';
					Name = 'Vault';
					State = 'OnStart'
				})
		   
		  	StatusEffects.Vaulting = true
		  	StatusEffects.AutoRotate = false
			Vault.CanCollide = false
			
		local Num = CountHandler.Create('VaultAnim', 1, 2)
			
			local VaultData: AnimationInterfaces.Data = {
				Name = 'Vault';
				Priority = Enum.AnimationPriority.Action2.Name;
				_Name = 'DefaultVault';
				
				Settings = {
					Speed = AnimSpeed;
				}
			}
				
		Animate:Load(Animations['Vault_'..Num()], {
			Name = 'Vault';
			Priority = Enum.AnimationPriority.Action2.Name;
			_Name = 'DefaultVault_'..Num();

			Settings = {
				Speed = AnimSpeed;
			}
			})
			Animate:Swap({
				Name = 'Vault';
				Priority = Enum.AnimationPriority.Action2.Name;
				_Name = 'DefaultVault_'..Num();

				Settings = {
					Speed = AnimSpeed;
				}
			})
			
			Num:Increment()

			if not StatusEffects.IsRunning then
				
			SpeedController:Amplify(
				{
					Name = 'Vault';
					Percent = -100;

				})
				
			   local ToVaultPos = (Vault.Position - HumanoidRootPart.Position).Unit
			   HumanoidRootPart.CFrame = CFrame.lookAt(HumanoidRootPart.Position, HumanoidRootPart.Position + ToVaultPos)
			   
			local BodyVelocity = AssetsHelper.CreateBodyVelocity({
				Instance = {
					Parent = HumanoidRootPart,
					MaxForce = Vector3.new(20000, 20000, 20000),
					Velocity = HumanoidRootPart.CFrame.LookVector * 23 + Vector3.new(0, 13, 0) ,
				},
				Settings = {
					DestroyTime = DestroyTime,
				}
			})
			   
			else
				
				DestroyTime = 0.25
				
				AnimSpeed = 0.325 / DestroyTime * 0.9
				
				Animate:AdjustSpeed(VaultData, AnimSpeed)
				
			local BodyVelocity = AssetsHelper.CreateBodyVelocity({
				Instance = {
					Parent = HumanoidRootPart,
					MaxForce = Vector3.new(20000, 20000, 20000),
					Velocity = HumanoidRootPart.CFrame.LookVector * 25 + Vector3.new(0, 14, 0) ,
				},
				Settings = {
					DestroyTime = DestroyTime,
				}
			})
			   
			DestroyTime = 0.325
			   
			end

		   	TaskManager:CreateTask(Humanoid, 'ReturnToDefault', DestroyTime, function()
			
			if not StatusEffects.IsRunning then
				
				SpeedController:Revert(
					{
						Name = 'Vault';
						Recursive = false;
					})
				
			end
			
			Humanoid.JumpPower = 50
			
			PackAbility:Fire(
				{
					Scope = 'Movement';
					Name = 'Vault';
					State = 'OnEnd'
				})
			
			StatusEffects.Vaulting = false
			
			StatusEffects.AutoRotate = true
			Vault.CanCollide = true

		   end)

		end;
};

States.Dash = {
	
	Dash = function(self: StatesInterfaces.IStatesComponent, args: {})
		
		local Player: IPlayer = self.args.Entity
		local ClientData = Player.ClientData
		local CharacterData = ClientData.CharacterData
		local StatusEffects = ClientData.StatusEffects

		local Character = CharacterData.Character
		local Humanoid = CharacterData.Humanoid
		local HumanoidRootPart = CharacterData.HumanoidRootPart
		
		local camera = workspace.CurrentCamera
		
		local Movement = ClientData.ClientAbilities.Packs['Movement']
		local Sprint: IAbility = Movement['Sprint']
		local Ability: IAbility = Movement['Dash']
		
		local SpeedController = SpeedComponent.new(Character)
		
		StatusEffects.Dashing = true
		
		PackAbility:Fire(
			{
				Scope = 'Movement';
				Name = 'Dash';
				State = 'OnStart'
			})
		
		if StatusEffects.IsRunning then
			Player:ChangeFOV(
				{
					useTween = false;
					FOV = 85;

				})
		end
		
		Sprint:OnEnd()
		
		local Speed = 50
		local coefficient = 1.2
		local lerp
		
		local Angle = HumanoidRootPart.CFrame.LookVector:Dot(HumanoidRootPart.Velocity.Unit)
		local Angle2 = HumanoidRootPart.CFrame.RightVector:Dot(HumanoidRootPart.Velocity.Unit)
		
		Angle = math.deg(math.acos(Angle))
		Angle2 = math.deg(math.acos(Angle2))
		
		local function GetDirection()
			for direction, v in pairs(Ability.Config.Angles1) do
				if Angle >= v[1] and Angle <= v[2] then
					return direction
				end
			end
			return nil
		end
		
		local function GetDirection2()
			for direction, v in pairs(Ability.Config.Angles2) do
				if Angle2 >= v[1] and Angle2 <= v[2] then
					return direction
				end
			end
			return nil
		end
		
		local function GetMainDirection(direction1, direction2)
			if not direction1 and direction2 then
				return direction2
			elseif direction1 then
				return direction1
			else
				return 'Front'
			end
		end
		
		local function GetVector(mainDirection)
			
			if mainDirection == 'Front' or mainDirection == 'Back' then
				return 'LookVector'
			elseif mainDirection == 'Left' or mainDirection == 'Right' then
				return 'RightVector'
			end
		end
		
		local function GetSpeed(mainDirection, speed)
			if mainDirection == 'Back' or mainDirection == 'Left' then
				return -speed
			else
				return speed
			end
		end
		
		local Direction1, Direction2 = GetDirection(), GetDirection2()
		
		local MainDirection = GetMainDirection(Direction1, Direction2)
		
		Replicator:GetRemote('BindableGlobal'):BindableFire('VFX',
			{Pack = 'Movement',
				Name ='Dash',
				Func = 'DashAnimation'},
			CharacterData.Character, MainDirection)
		
		local BodyVelocity = AssetsHelper.CreateBodyVelocity({
			Instance = {
				Parent = HumanoidRootPart,
				MaxForce = Vector3.new(20000, 0, 20000),
			},
			Settings = {
				DestroyTime = Ability.Config.Duration,
			}
		})
		
		TaskManager:CreateTask(Player,'SmoothChange',nil,function()
			local frameRate = 60
			local allTime = frameRate * Ability.Config.Duration
			for i=1,allTime do
				local t = i/allTime
				lerp = BiezeModule.lerp(coefficient,0,t,Enum.EasingStyle.Sine,Enum.EasingDirection.Out) * Speed
				task.wait(1/15)
			end
		end)
		
		TaskManager:CreateThread(BodyVelocity, 'DashRender', RunService.Heartbeat:Connect(function()

			if not Direction2 then
				BodyVelocity.Velocity = 
				HumanoidRootPart.CFrame[GetVector(MainDirection)] * 
				GetSpeed(MainDirection, lerp)
			elseif MainDirection ~= Direction2 then
				BodyVelocity.Velocity = 
				HumanoidRootPart.CFrame[GetVector(MainDirection)] * 
				GetSpeed(MainDirection, lerp) + HumanoidRootPart.CFrame[GetVector(Direction2)] / 2 *
				GetSpeed(Direction2, lerp) / 1.5
			else
				BodyVelocity.Velocity = 
				HumanoidRootPart.CFrame[GetVector(MainDirection)] * 
				GetSpeed(MainDirection, lerp)
			end
			
		end))
		
		SpeedController:Amplify(
			{
				Name = 'Dash';
				Percent = -100;

			})
		
		TaskManager:CreateTask(BodyVelocity, 'ReturnToDefault', Ability.Config.Duration, function()
			
			StatusEffects.Dashing = false
			
			PackAbility:Fire(
				{
					Scope = 'Movement';
					Name = 'Dash';
					State = 'OnEnd'
				})
			
			SpeedController:Revert({
				Name = 'Dash';
				Recursive = false;
			})
			
			if ClientData.PressedKeys['W'] then
				Sprint:OnSpecialStart()	
			end
			
		end)

	end;
	
};

States.Feint = {

	DashFeint = function(self: StatesInterfaces.IStatesComponent, args: {})

		local Player: IPlayer = self.args.Entity
		local ClientData = Player.ClientData
		local CharacterData = ClientData.CharacterData
		local StatusEffects = ClientData.StatusEffects

		local Character = CharacterData.Character
		local Humanoid = CharacterData.Humanoid
		local HumanoidRootPart = CharacterData.HumanoidRootPart

		local SpeedController = SpeedComponent.new(Character)

		for i, bv: BodyVelocity in pairs(HumanoidRootPart:GetChildren()) do
			if bv:IsA('BodyVelocity') then
				if bv:GetAttribute('Priority') <= 1 then
					bv:Destroy()
				end
			end
		end
		
		SpeedController:Revert({
			Name = 'Dash';
			Recursive = false;
		})
		
		PackAbility:Fire(
			{
				Scope = 'Movement';
				Name = 'DashCancel';
				State = 'OnStart'
			})

	end;

};

return States
