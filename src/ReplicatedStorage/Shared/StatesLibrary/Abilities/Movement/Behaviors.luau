local RunService = game:GetService('RunService')
local ReplicatedStorage = game:GetService('ReplicatedStorage')

local Shared = ReplicatedStorage:WaitForChild('Shared')
local Modules = ReplicatedStorage:WaitForChild('Modules')
local NetWork = Modules:WaitForChild('NetWork')
local Interfaces = Shared:WaitForChild('Interfaces')

local Replicator = require(NetWork:WaitForChild('Replicator'))
local VFXReplica = require(NetWork:WaitForChild('VfxReplica'))

local AbilityInterfaces = require(Interfaces:WaitForChild('AbilityInerfaces'))
local StatesInterfaces = require(Interfaces:WaitForChild('StatesInterfaces'))
local LocalPlayerInterfaces = require(Interfaces:WaitForChild('LocalPlayerInterfaces'))

type IPlayer = LocalPlayerInterfaces.IClientPlayerComponent

local States = require(script.Parent.States)

local Behaviors = {}

Behaviors.Vaulting = {
	VaultCheck = {
		priority = 1;
		
		check = function(self: StatesInterfaces.IStatesComponent)
			local Player: IPlayer = self.args.Entity
			local ClientData = Player.ClientData
			local CharacterData = ClientData.CharacterData
			local StatusEffects = ClientData.StatusEffects

			local Pack = ClientData.ClientAbilities.Packs['Movement']
			local Ability: AbilityInterfaces.IAbilityComponent = Pack['Vault']

			if Ability:CheckBlacklist(Action.Config.Blacklist, {CheckCD = false;}) then return false end

            local Character = CharacterData.Character
            local HumanoidRootPart = CharacterData.HumanoidRootPart

 			if StatusEffects.Vaulting then return end

			local RayOrigin = HumanoidRootPart.Position
			local RayDirection = HumanoidRootPart.CFrame.LookVector * 7
			
			local Params = RaycastParams.new()
			
			Params.FilterType = Enum.RaycastFilterType.Exclude
			Params.FilterDescendantsInstances = {Character}
			
			local Result = workspace:Raycast(RayOrigin, RayDirection, Params)

            if not Result then return false end

			local Vault: Part = Result.Instance
			
			if not Vault:HasTag('Vault') then return end
			
			local PlayerPos = HumanoidRootPart.Position
			local VaultSize = Vault.Size
			local FinalPos = Vector3.new(PlayerPos.X, PlayerPos.Y + (VaultSize.Y / 2), PlayerPos.Z)

            local Result2 = workspace:Raycast(FinalPos, RayDirection, Params)
			if Result2 then
				
				return false
			else
				Behaviors.Vaulting.VaultCheck.trueaction(self, {
				Vault = Vault;
				PlayerPosition = PlayerPos;
				PlayerCFrame = HumanoidRootPart.CFrame;
				})
			return false
			end

		end,

		trueaction = function(self: StatesInterfaces.IStatesComponent, args: {})
			local Player: IPlayer = self.args.Entity
			local ClientData = Player.ClientData
			local StatusEffects = ClientData.StatusEffects

			States.Vaulting.Vault(self, args)

		end,

		falseaction = function(self: StatesInterfaces.IStatesComponent)
			local Ability: AbilityInterfaces.IAbilityComponent = self.args.Ability
		end,
	};	
};

Behaviors.Dash = {
	DashCheck = {
		priority = 1;

		check = function(self: StatesInterfaces.IStatesComponent)
			local Player: IPlayer = self.args.Entity
			local ClientData = Player.ClientData
			local CharacterData = ClientData.CharacterData
			local StatusEffects = ClientData.StatusEffects

			local Character = CharacterData.Character
			local HumanoidRootPart = CharacterData.HumanoidRootPart

			local Pack = ClientData.ClientAbilities.Packs['Movement']
			local Ability: AbilityInterfaces.IAbilityComponent = Pack['Dash']
			local AbilityConfig = Action.Config
			
			return true

		end,

		trueaction = function(self: StatesInterfaces.IStatesComponent, args: {})
			
			local Player: IPlayer = self.args.Entity
			local ClientData = Player.ClientData
			local CharacterData = ClientData.CharacterData
			local StatusEffects = ClientData.StatusEffects

			local Character = CharacterData.Character
			local HumanoidRootPart = CharacterData.HumanoidRootPart
			
			States.Dash.Dash(self, args)
		end,

		falseaction = function(self: StatesInterfaces.IStatesComponent)
		end,
	};

};

Behaviors.Feint = {
	DashCheck = {
		priority = 2;

		check = function(self: StatesInterfaces.IStatesComponent)
			local Player: IPlayer = self.args.Entity
			local ClientData = Player.ClientData
			local CharacterData = ClientData.CharacterData
			local StatusEffects = ClientData.StatusEffects

			local Character = CharacterData.Character
			local HumanoidRootPart = CharacterData.HumanoidRootPart

			if StatusEffects.Dashing then return true else return false end

		end,

		trueaction = function(self: StatesInterfaces.IStatesComponent, args: {})

			local Player: IPlayer = self.args.Entity
			local ClientData = Player.ClientData
			local CharacterData = ClientData.CharacterData
			local StatusEffects = ClientData.StatusEffects

			local Character = CharacterData.Character
			local HumanoidRootPart = CharacterData.HumanoidRootPart

			States.Feint.DashFeint(self, args)
		end,

		falseaction = function(self: StatesInterfaces.IStatesComponent)
		end,
	};
};

return Behaviors
