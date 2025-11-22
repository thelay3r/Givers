local RunService = game:GetService('RunService')
local ReplicatedStorage = game:GetService('ReplicatedStorage')

local Shared = ReplicatedStorage:WaitForChild('Shared')
local Components = Shared:WaitForChild('Components')
local Utilities = Shared:WaitForChild('Utilities')
local Interfaces = Shared:WaitForChild('Interfaces')
local Templates = Shared:WaitForChild('Templates')
local UtilModules = Utilities:WaitForChild('Modules')

local StatesLibrary = Shared:WaitForChild('StatesLibrary')

local AbilityInterfaces = require(Interfaces:WaitForChild('AbilityInerfaces'))
local LocalPlayerInterfaces = require(Interfaces:WaitForChild('LocalPlayerInterfaces'))

local PlayerStorage = require(Components:WaitForChild('LocalPlayerComponent'):WaitForChild('PlayerStorage'))
local StateManager = require(UtilModules:WaitForChild('StateManager'))
local TaskManager = require(UtilModules:WaitForChild('TaskManager'))
local TableHelper = require(UtilModules:WaitForChild('TableHelper'))
local AbilityTemplate = require(Templates:WaitForChild('Ability'))

type IClientPlayerComponent = LocalPlayerInterfaces.IClientPlayerComponent

local Packs = {}
local AbilitiesMethods = {}
local Abilities = {}

local ClientAbilities = {}
AbilitiesMethods__index = ClientAbilities

function ClientAbilities.AddPack(self: IClientPlayerComponent, AbilitiesFolder: Folder)
	
	Packs[self.Instance] = Packs[self.Instance] or {}
	
	local Pack = {}
	
	for _,v: ModuleScript in pairs(AbilitiesFolder:GetDescendants()) do
		if v.Parent.Name == 'States' or v.Parent.Name == 'Behaviors' then continue end
		if v:IsA('ModuleScript') and v.Parent:IsA('Folder') then
			Pack[v.Name] = require(v)(self)
			Pack[v.Name]['Config'] = require(v.Config)
			Pack[v.Name].Name = v.Name
		end
	end

	self.ClientData.ClientAbilities.Packs[AbilitiesFolder.Name] = Pack
	Packs[self.Instance][AbilitiesFolder.Name] = Pack

	
	warn('Given '..AbilitiesFolder.Name..' Pack to '..self.Instance.Name)
	
	return Pack
end

function ClientAbilities.GetPack(self: IClientPlayerComponent, PackName: string)
	if not Packs[self.Instance][PackName] then warn('Cant find required pack.') return end
	return Packs[self.Instance][PackName]
end

function ClientAbilities.GetPacks(self: IClientPlayerComponent)
	if not Packs[self.Instance] then warn("This Enity doesn't have packs") return end
	return Packs[self.Instance]
end

function ClientAbilities.RemovePack(self: IClientPlayerComponent, PackName: string)
	if not Packs[self.Instance][PackName] then warn('Cant find required pack.') return end
	Packs[self.Instance][PackName] = nil
end

function ClientAbilities.RemoveAllPacks(self: IClientPlayerComponent)
	self.ClientData.ClientAbilities.Packs.Packs = {}
	Packs[self.Instance] = {}
end

function ClientAbilities.AddAbility(self: IClientPlayerComponent, AbilitiesFolder: Folder, AbilityName: string)

	Abilities[self.Instance] = Abilities[self.Instance] or {}

	local Ability = {}

	if not AbilitiesFolder:FindFirstChild(AbilityName) then return warn(AbilityName.." doesn't exist on "..AbilitiesFolder.Name) end

    local RequiredAbility = AbilitiesFolder[AbilityName]

	Ability[AbilityName] = require(RequiredAbility)(self.SessionData.UserId)
	Ability[AbilityName]['Config'] = require(RequiredAbility['Config'])
	Ability[AbilityName].Name = AbilityName


	self.ClientData.ClientAbilities.Abilities[AbilitiesFolder.Name] = Ability
	Abilities[self.Instance][AbilitiesFolder.Name] = Ability

	warn('Given '..AbilityName..' Ability to '..self.Instance.Name)

	return Ability
end

function ClientAbilities.GetAbility(self: IClientPlayerComponent, Scope: string, AbilityName: string)
	if not Abilities[self.Instance][Scope][AbilityName] then warn('Cant find required Ability.') return end
	return Abilities[self.Instance][Scope][AbilityName]
end

function ClientAbilities.RemoveAbility(self: IClientPlayerComponent, Scope: string, AbilityName: string)
	if not Abilities[self.Instance][Scope][AbilityName] then warn('Cant find required Ability.') return end
	Abilities[self.Instance][Scope][AbilityName] = nil
end

function ClientAbilities.RemoveAllAbilities(self: IClientPlayerComponent)
	self.ClientData.ClientAbilities.Abilities = {}
	Abilities[self.Instance] = {}
end

function ClientAbilities:CreateAbility(Player : IClientPlayerComponent)

	local self : AbilityInterfaces.IAbilitypreset = setmetatable(table.clone(AbilityTemplate()),
		{
			__index = function(t,key)
				return AbilitiesMethods[key]
			end,
		})

	self.OwnerId = Player.Instance.UserId

	return self
end

function AbilitiesMethods.LoadCFG(self : AbilityPreset.IAbility, CFG : {})
	for i,v in pairs(self) do
		if CFG[i] then
			self[i] = CFG[i]

		end
	end
	return self
end

function AbilitiesMethods.CloseConnection(self: AbilityInterfaces.IAbilityComponent)
	
	TaskManager:CancelThread(self, self.Name..'OnStart')

end

function AbilitiesMethods.SetCooldown(self: AbilityInterfaces.IAbilityComponent, increseadTime : number)
	self.Cooldown = increseadTime
	self['Config']['Cooldown'] = increseadTime
end

function AbilitiesMethods.CheckCooldown(self: AbilityInterfaces.IAbilityComponent, Additional: AbilityInterfaces.IAdditional)

	if Additional.CheckCD then
		if (os.clock() - self.LastUsed) >= self.Cooldown then return true end
	end

	return false
end

function AbilitiesMethods.CheckBlacklist(self: AbilityInterfaces.IAbilityComponent, List: {}, Additional: AbilityInterfaces.IAdditional)

	if not Additional then
		Additional = {}
	end

	if Additional.CheckCD == nil then
		Additional.CheckCD = true
	end
	
	local Owner: IClientPlayerComponent = PlayerStorage:GetPlayer()
	for _,v in pairs(List) do
		if Owner.ClientData.StatusEffects[v] then
			return true
		end
	end

	if Additional.CheckCD then
		if self:CheckCooldown(Additional) then return false else return true end
	else
		return false
	end

end

function AbilitiesMethods.SetAbility(self: AbilityInterfaces.IAbilityComponent, Name: string, Value: any)
	local Owner: IClientPlayerComponent = PlayerStorage:GetPlayer()

	self[Name] = Value

end

function AbilitiesMethods.OnStart(self: AbilityInterfaces.IAbilityComponent, Additional: AbilityInterfaces.Additional)
	
	local AbilitiesStates = StatesLibrary['AbilitiesComponent']

	if not self.State then
		self.State = StateManager:New(
			{
				FOLDER = AbilitiesStates;
				SECTION_NAME = 'Abilities';
				Ability = self;
				Additional = Additional;
				Method = 'OnStart';
			}
		)
	end

	self.State.args.Method = 'OnStart'
	self.State:CheckBehavior()

end

function AbilitiesMethods.OnSpecialStart(self: AbilityInterfaces.IAbilityComponent, Additional: AbilityInterfaces.Additional)

	local AbilitiesStates = StatesLibrary['AbilitiesComponent']

	if not self.State then
		self.State = StateManager:New(
			{
				FOLDER = AbilitiesStates;
				SECTION_NAME = 'Abilities';
				Ability = self;
				Additional = Additional;
				Method = 'OnSpecialStart';
			}
		)
	end

    self.State.args.Method = 'OnSpecialStart'
	self.State:CheckBehavior()

end

function AbilitiesMethods.OnStop(self: AbilityInterfaces.IAbilityComponent)
	if (not self.IsActive) then return end

	if (self.StartTime + self.MinDuration) > os.clock() then task.wait((self.StartTime + self.MinDuration) - os.clock()) end

	self:CloseConnection()

	self.Functions.End()

	self:SetAbility('LastUsed', os.clock())
	self:SetAbility('IsHolded', false)
	self:SetAbility('IsActive', false)
	
    return
end

return ClientAbilities