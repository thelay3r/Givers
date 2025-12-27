local ReplicatedStorage = game:GetService('ReplicatedStorage')
local RunService = game:GetService('RunService')

local Shared = ReplicatedStorage:WaitForChild('Shared')
local Interfaces = Shared:WaitForChild('Interfaces')
local Utilities = Shared:WaitForChild('Utilities')
local UtilModules = Utilities:WaitForChild('Modules')
local NetWork = Utilities:WaitForChild('NetWork')

local Replica = require(NetWork:WaitForChild('VfxReplica'))

local AbilityInterfaces = require(Interfaces:WaitForChild('AbilityInerfaces'))
local StatesInterfaces = require(Interfaces:WaitForChild('StatesInterfaces'))

local TaskManager = require(UtilModules:WaitForChild('TaskManager'))

local States = {}

States.Abilities = {
	Hold = function(self: StatesInterfaces.IStatesComponent)
		local Ability: AbilityInterfaces.IAbilityComponent = self.args.Ability
		local Additional: AbilityInterfaces.IAdditional

		local Template: AbilityInterfaces.Additional = {
			Bypass = false;
			CheckCD = true;
			IgnoreUsed = false;
		}

		Ability:SetAbility('IsHolded', true)

		if not Additional then
			Additional = table.clone(Template)
		end

		if not Additional.IgnoreUsed then
			if Action.IsActive then return end
		end

		if not Additional.Bypass then
			if Ability:CheckBlacklist(Action.Blacklist, Additional) then return end
		end

		if self.args.Method == 'OnSpecialStart' then
			Action.Functions.StartStatus = Action.Functions.SpecialStart()
		else
			Action.Functions.StartStatus = Action.Functions.Start()
		end
		
		Ability:SetAbility('IsActive', true)

		Ability:SetAbility('StartTime', os.clock())

		TaskManager:CreateThread(Ability, Action.Name..'OnStart', RunService.Heartbeat:Connect(function()
			if (os.clock() - Action.StartTime) >= Action.Duration and Action.IsActive then
				Ability:OnStop()
				TaskManager.CancelThread(Ability, Action.Name..'OnStart')
				return
			end
		end))

	end;

	Toggle = function(self: StatesInterfaces.IStatesComponent)
		local Ability: AbilityInterfaces.IAbilityComponent = self.args.Ability
		local Additional: AbilityInterfaces.IAdditional

		local Template: AbilityInterfaces.Additional = {
			Bypass = false;
			CheckCD = true;
			IgnoreUsed = false;
		}

		if not Additional then
			Additional = table.clone(Template)
		end

		if Action.IsActive then
			Additional.CheckCD = false
		end

		if not Additional.Bypass then
			if Ability:CheckBlacklist(Action.Blacklist, Additional) then return end
		end

		if not Action.IsActive then
			
			if self.args.Method == 'OnSpecialStart' then
				Action.Functions.StartStatus = Action.Functions.SpecialStart()
			else
				Action.Functions.StartStatus = Action.Functions.Start()
			end
			
			Ability:SetAbility('StartTime', os.clock())
		end

		if (Action.StartTime + Action.MinDuration) <= os.clock() then
			Ability:OnStop()
			TaskManager.CancelThread(Ability, Action.Name..'OnStart')
			return
		end

		TaskManager:CreateThread(Ability, Action.Name..'OnStart', RunService.Heartbeat:Connect(function()
			if (os.clock() - Action.StartTime) >= Action.Duration and Action.IsActive then
				Ability:OnStop()
				TaskManager.CancelThread(Ability, Action.Name..'OnStart')
				return
			end
		end))

		Ability:SetAbility('IsActive', true)

	end;
};

return States
