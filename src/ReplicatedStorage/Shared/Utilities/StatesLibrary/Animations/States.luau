local ReplicatedStorage = game:GetService('ReplicatedStorage')

local Shared = ReplicatedStorage:WaitForChild('Shared')
local Interfaces = Shared:WaitForChild('Interfaces')
local Utilities = Shared:WaitForChild('Utilities')
local NetWork = Utilities:WaitForChild('NetWork')
local Modules = Utilities:WaitForChild('Modules')

local Replica = require(NetWork:WaitForChild('VfxReplica'))
local TaskManager = require(Modules:WaitForChild('TaskManager'))
local CountHandler = require(Modules:WaitForChild('CountHandler'))
local ILocalPlayer = require(Interfaces:WaitForChild('LocalPlayerInterfaces'))
local StatesInterfaces = require(Interfaces:WaitForChild('StatesInterfaces'))
local AnimationsComponent = require(Modules:FindFirstChild('AnimationsComponent'))

local VFX = Shared:WaitForChild('VFXs')
local Assets = VFX:WaitForChild('Assets')
local Animations = Assets:WaitForChild('Default'):WaitForChild('Animations')

local States = {}

local CFGs = 
	{
		['Idle'] = 
		{
			Name = 'Idle';
			Priority = Enum.AnimationPriority.Idle.Name;
			_Name = 'DefaultIdle';

			Settings = 
			{
				Speed = 1;
				Weight = 1;
				FadeTime = .1;
			}
		};

		['Walk'] = 
		{
			Name = 'Walk';
			Priority = Enum.AnimationPriority.Movement.Name;
			_Name = 'DefaultWalk';

			Settings = 
			{
				Speed = 1;
				Weight = 1;
				FadeTime = .1;
			}

		};
		['Jump'] = 
		{
			Name = 'Jump';
			Priority = Enum.AnimationPriority.Action.Name;
			_Name = 'DefaultJump';

			Settings = 
			{
				Speed = 1;
				Weight = 1;
				FadeTime = .1;
			}
		};
		['Fall'] = 
		{
			Name = 'Fall';
			Priority = Enum.AnimationPriority.Action.Name;
			_Name = 'DefaultFall';

			Settings = 
			{
				Speed = 1;
				Weight = 1;
				FadeTime = .1;
			}
		};
		['LandHard'] = 
		{
			Name = 'LandHard';
			Priority = Enum.AnimationPriority.Action.Name;
			_Name = 'DefaultLandHard';

			Settings = 
			{
				Speed = 1;
				Weight = 1;
				FadeTime = .1;
			}
		};
	}

States.Walk = {
	TrueAction = function(self: StatesInterfaces.IStatesComponent)
		local Player : ILocalPlayer.IClientPlayerComponent = self.args.Player
		local ClientData = Player.ClientData
		local CharacterData = ClientData.CharacterData
		local Character = CharacterData.Character
		local Humanoid: Humanoid = CharacterData.Humanoid
		local rootPart: BasePart = CharacterData.HumanoidRootPart
		
		local Animate = AnimationsComponent.new(Character)
		if Animate:IsPlaying(CFGs.Walk) then return end
		Animate:Play(CFGs.Walk)
		
		local SessionData = Player.SessionData
		local StatusEffects = SessionData.StatusEffects
		

		TaskManager:CreateTask(Player,'WalkDirection',0,function()
			local deadZone = .05
			while true do
				task.wait(1/30)
				local MoveDirection = Humanoid.MoveDirection
				if (MoveDirection == Vector3.zero) or (StatusEffects.IsRunning) or (not StatusEffects.CanBodySimulation) then continue end
				local moveMagnitude = (MoveDirection * Vector3.new(1, 0, 1)).Magnitude

				local forward = rootPart.CFrame.LookVector
				local right = rootPart.CFrame.RightVector

				local forwardAmount = MoveDirection:Dot(forward)
				local rightAmount = MoveDirection:Dot(right)
			

				
				forwardAmount = math.clamp(forwardAmount,-1,1)
				rightAmount = math.clamp(rightAmount,-1,1)

				
				forwardAmount = (math.abs(forwardAmount) > deadZone and forwardAmount or 0)
				
				
				if forwardAmount < 0 then
					Animate:AdjustSpeed(CFGs.Walk,-1)
				else
					Animate:AdjustSpeed(CFGs.Walk,1)
				end
			end
		end)
		
		
	end,
	
	FalseAction = function(self: StatesInterfaces.IStatesComponent)
		local Player : ILocalPlayer.IClientPlayerComponent = self.args.Player
		local ClientData = Player.ClientData
		local CharacterData = ClientData.CharacterData
		local Character = CharacterData.Character
		
		TaskManager:CancelTask(Player,'WalkDirection')
		
		local Animate = AnimationsComponent.new(Character)
		if not Animate:IsPlaying(CFGs.Walk) then return end
		Animate:Stop(CFGs.Walk)
	end,
}

States.Jump = {
	TrueAction = function(self: StatesInterfaces.IStatesComponent)
		if true then return end
		local Player : ILocalPlayer.IClientPlayerComponent = self.args.Player
		local ClientData = Player.ClientData
		local CharacterData = ClientData.CharacterData
		local Character = CharacterData.Character
		local Count = CountHandler.Create('JumpCounter',0,2)
		

	end,

	FalseAction = function(self: StatesInterfaces.IStatesComponent)
	
	end,
}

States.Fall = {
	TrueAction = function(self: StatesInterfaces.IStatesComponent)
		local Player : ILocalPlayer.IClientPlayerComponent = self.args.Player
		local ClientData = Player.ClientData
		local CharacterData = ClientData.CharacterData
		local Character = CharacterData.Character

		local Animate = AnimationsComponent.new(Character)
		if Animate:IsPlaying(CFGs.Jump) or Animate:IsPlaying(CFGs.Fall) then return end
		
		Animate:Play(CFGs.Fall)

		--ClientData.Ticks['FallTime'] = tick()	
	end,

	FalseAction = function(self: StatesInterfaces.IStatesComponent)
		local Player : ILocalPlayer.IClientPlayerComponent = self.args.Player
		local ClientData = Player.ClientData
		local CharacterData = ClientData.CharacterData
		local Character = CharacterData.Character
		local Humanoid = CharacterData.Humanoid

		local Animate = AnimationsComponent.new(Character)
		if not Animate:IsPlaying(CFGs.Fall) then return end
		
		local fallDuration = tick() - (ClientData.Ticks['FallTime']  or 0)
		
		Animate:Stop(CFGs.Fall)
		
		if fallDuration >= 5555555555 then
			Animate:Play(CFGs.LandHard)
			
			
			Humanoid.WalkSpeed = 4
			
			TaskManager:CreateTask(self, 'FallWalkSpeed', 1, function()
				Humanoid.WalkSpeed = 16
			end)
		end
		ClientData.Ticks['FallTime'] = nil
	end,
}






return States
