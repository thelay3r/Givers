local ReplicatedStorage = game:GetService('ReplicatedStorage')

local Shared = ReplicatedStorage:WaitForChild('Shared')
local Interfaces = Shared:WaitForChild('Interfaces')
local Utilities = Shared:WaitForChild('Utilities')
local NetWork = Utilities:WaitForChild('NetWork')
local Modules = Utilities:WaitForChild('Modules')

local Replica = require(NetWork:WaitForChild('VfxReplica'))
local TaskManager = require(Modules:WaitForChild('TaskManager'))

local ILocalPlayer = require(Interfaces:WaitForChild('LocalPlayerInterfaces'))
local StatesInterfaces = require(Interfaces:WaitForChild('StatesInterfaces'))
local AnimationsComponent = require(Modules:FindFirstChild('AnimationsComponent'))

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

States.NPCWalk = {
	TrueAction = function(self: StatesInterfaces.IStatesComponent)
		local NPC: Model = self.args.NPC
		local Humanoid: Humanoid = NPC:FindFirstChildOfClass('Humanoid')
		local HumanoidRootPart: BasePart = NPC:FindFirstChild('HumanoidRootPart') or NPC.PrimaryPart

		local Animate = AnimationsComponent.new(NPC)
		if Animate:IsPlaying(CFGs.Walk) then return end
		Animate:Play(CFGs.Walk)
	end,

	FalseAction = function(self: StatesInterfaces.IStatesComponent)
		local NPC: Model = self.args.NPC
		local Humanoid: Humanoid = NPC:FindFirstChildOfClass('Humanoid')
		local HumanoidRootPart: BasePart = NPC:FindFirstChild('HumanoidRootPart') or NPC.PrimaryPart

		TaskManager:CancelTask(NPC,'WalkDirection')

		local Animate = AnimationsComponent.new(NPC)
		if not Animate:IsPlaying(CFGs.Walk) then return end
		Animate:Stop(CFGs.Walk)
	end,
}

States.NPCJump = {
	TrueAction = function(self: StatesInterfaces.IStatesComponent)
		local NPC: Model = self.args.NPC
		local Humanoid: Humanoid = NPC:FindFirstChildOfClass('Humanoid')
		local HumanoidRootPart: BasePart = NPC:FindFirstChild('HumanoidRootPart') or NPC.PrimaryPart

		local Animate = AnimationsComponent.new(NPC)
		
		if Animate:IsPlaying(CFGs.Jump) then return end
		
		Animate:Play(CFGs.Jump)

	end,

	FalseAction = function(self: StatesInterfaces.IStatesComponent)

	end,
}

States.NPCFall = {
	TrueAction = function(self: StatesInterfaces.IStatesComponent)
		local NPC: Model = self.args.NPC
		local Humanoid: Humanoid = NPC:FindFirstChildOfClass('Humanoid')
		local HumanoidRootPart: BasePart = NPC:FindFirstChild('HumanoidRootPart') or NPC.PrimaryPart

		local Animate = AnimationsComponent.new(NPC)
		if Animate:IsPlaying(CFGs.Jump) or Animate:IsPlaying(CFGs.Fall) then return end


		Animate:Play(CFGs.Fall)
		
		NPC:SetAttribute('FallTime', tick())	
	end,

	FalseAction = function(self: StatesInterfaces.IStatesComponent)
		local NPC: Model = self.args.NPC
		local Humanoid: Humanoid = NPC:FindFirstChildOfClass('Humanoid')
		local HumanoidRootPart: BasePart = NPC:FindFirstChild('HumanoidRootPart') or NPC.PrimaryPart

		local Animate = AnimationsComponent.new(NPC)
		if not Animate:IsPlaying(CFGs.Fall) then return end

		local fallDuration = tick() - (NPC:GetAttribute('FallTime')  or 0)

		Animate:Stop(CFGs.Fall)

		if fallDuration >= .45 then
			Animate:Play(CFGs.LandHard)


			Humanoid.WalkSpeed = 4

			TaskManager:CreateTask(self, 'FallWalkSpeed', 1, function()
				Humanoid.WalkSpeed = 16
			end)
		end
		NPC:SetAttribute('FallTime', nil)
	end,
}

return States
