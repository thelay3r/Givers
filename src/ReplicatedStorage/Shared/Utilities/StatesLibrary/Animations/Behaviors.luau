local ReplicatedStorage = game:GetService('ReplicatedStorage')

local Shared = ReplicatedStorage:WaitForChild('Shared')
local Interfaces = Shared:WaitForChild('Interfaces')

local StatesInterfaces = require(Interfaces:WaitForChild('StatesInterfaces'))
local ILocalPlayer = require(Interfaces:WaitForChild('LocalPlayerInterfaces'))
local IAnimator = require(Interfaces:WaitForChild('AnimationsInterfaces'))

local States = require(script.Parent.States)

local Behaviors = {}

Behaviors.Movement = {
	Walk = {
		priority = 1;
		check = function(self: StatesInterfaces.IStatesComponent)
			local Player : ILocalPlayer.IClientPlayerComponent = self.args.Player
			local ClientData = Player.ClientData
			local CharacterData = ClientData.CharacterData
			local Humanoid = CharacterData.Humanoid
			
			local MoveDirection = Humanoid.MoveDirection
			if (MoveDirection == Vector3.zero) or Humanoid.WalkSpeed <= 0 then return false end
			return true
		end,
		trueaction = function(self: StatesInterfaces.IStatesComponent)
			States['Walk'].TrueAction(self)
		end,

		falseaction = function(self: StatesInterfaces.IStatesComponent)
			States['Walk'].FalseAction(self)
		end,
	};
	
	Fall = {
		priority = 2;
		MassCheck = true;
		check = function(self: StatesInterfaces.IStatesComponent)
			local Player : ILocalPlayer.IClientPlayerComponent = self.args.Player
			local ClientData = Player.ClientData
			local CharacterData = ClientData.CharacterData
			local Humanoid = CharacterData.Humanoid
			
			
			return Humanoid:GetState() == Enum.HumanoidStateType.Freefall
		end,
		trueaction = function(self: StatesInterfaces.IStatesComponent)
			States['Fall'].TrueAction(self)
		end,

		falseaction = function(self: StatesInterfaces.IStatesComponent)
			States['Fall'].FalseAction(self)
		end,
	};
	
	Jump = {
		priority = 3;
		ignore = true;
		check = function(self: StatesInterfaces.IStatesComponent)
			local Player : ILocalPlayer.IClientPlayerComponent = self.args.Player
			local ClientData = Player.ClientData
			local CharacterData = ClientData.CharacterData
			local Humanoid = CharacterData.Humanoid
			
			if Humanoid.JumpPower <= 0 then return false end
			
			
			if Player.ClientData.PressedKeys['Space'] and Humanoid:GetState() ~= Enum.HumanoidStateType.Freefall then
				return true
			end
			
			return false
		end,
		trueaction = function(self: StatesInterfaces.IStatesComponent)
			States['Jump'].TrueAction(self)
		end,

		falseaction = function(self: StatesInterfaces.IStatesComponent)
			return
		end,
	};
	
}

return Behaviors
