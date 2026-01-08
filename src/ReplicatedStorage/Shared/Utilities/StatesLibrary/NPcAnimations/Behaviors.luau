local ReplicatedStorage = game:GetService('ReplicatedStorage')

local Shared = ReplicatedStorage:WaitForChild('Shared')
local Interfaces = Shared:WaitForChild('Interfaces')

local StatesInterfaces = require(Interfaces:WaitForChild('StatesInterfaces'))
local ILocalPlayer = require(Interfaces:WaitForChild('LocalPlayerInterfaces'))
local IAnimator = require(Interfaces:WaitForChild('AnimationsInterfaces'))

local States = require(script.Parent.States)

local Behaviors = {}


Behaviors.NPCMovement = {
	Walk = {
		priority = 1;
		check = function(self: StatesInterfaces.IStatesComponent)
			local NPC: Model = self.args.NPC
			
			local Humanoid: Humanoid = NPC:FindFirstChildOfClass('Humanoid')
			local HumanoidRootPart: BasePart = NPC:FindFirstChild('HumanoidRootPart') or NPC.PrimaryPart

			local MoveSpeed = HumanoidRootPart.AssemblyLinearVelocity.Magnitude
			if MoveSpeed < 1 then return false end
			return true
		end,
		trueaction = function(self: StatesInterfaces.IStatesComponent)
			States['NPCWalk'].TrueAction(self)
		end,

		falseaction = function(self: StatesInterfaces.IStatesComponent)
			States['NPCWalk'].FalseAction(self)
		end,
	};

	Fall = {
		priority = 2;
		MassCheck = true;
		check = function(self: StatesInterfaces.IStatesComponent)
			local NPC: Model = self.args.NPC

			local Humanoid: Humanoid = NPC:FindFirstChildOfClass('Humanoid')
			local HumanoidRootPart: BasePart = NPC:FindFirstChild('HumanoidRootPart') or NPC.PrimaryPart


			return Humanoid:GetState() == Enum.HumanoidStateType.Freefall
		end,
		trueaction = function(self: StatesInterfaces.IStatesComponent)
			States['NPCFall'].TrueAction(self)
		end,

		falseaction = function(self: StatesInterfaces.IStatesComponent)
			States['NPCFall'].FalseAction(self)
		end,
	};

	Jump = {
		priority = 3;
		ignore = true;
		check = function(self: StatesInterfaces.IStatesComponent)
			local NPC: Model = self.args.NPC

			local Humanoid: Humanoid = NPC:FindFirstChildOfClass('Humanoid')
			local HumanoidRootPart: BasePart = NPC:FindFirstChild('HumanoidRootPart') or NPC.PrimaryPart

			if Humanoid.JumpPower <= 0 then return false end


			if Humanoid:GetState() ~= Enum.HumanoidStateType.Freefall and Humanoid.Jump then
				return true
			end

			return false
		end,
		trueaction = function(self: StatesInterfaces.IStatesComponent)
			States['NPCJump'].TrueAction(self)
		end,

		falseaction = function(self: StatesInterfaces.IStatesComponent)
			return
		end,
	};
}

return Behaviors
