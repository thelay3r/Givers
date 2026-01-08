local ReplicatedStorage = game:GetService('ReplicatedStorage')
local RunService = game:GetService("RunService")
local Modules = ReplicatedStorage:WaitForChild('Modules')
local NetWork = Modules:WaitForChild('NetWork')
local Utilities = Modules:WaitForChild('Utilities')
local Shared = ReplicatedStorage:WaitForChild('Shared')
local Interfaces = Shared:WaitForChild('Interfaces')
local Templates = Shared:WaitForChild('Templates')


local TaskManager = require(Utilities.TaskManager)
local EntityInterfaces = require(Interfaces.EntityInterfaces)
local LocalPlayerInterfaces = require(Interfaces.LocalPlayerInterfaces)
local Replicator = require(NetWork.Replicator)
local JumpPowerInterface = require(Interfaces:WaitForChild('JumpPowerModuleInterface'))
local JumpPowerTemplate = require(Templates:WaitForChild('JumpPowerTemplate'))


type IJumpPowerComponent = JumpPowerInterface.IJumpPowerComponent
type IJumpPowerController = JumpPowerInterface.IJumpPowerController
type JumpModifier = JumpPowerInterface.JumpModifier
type JumpComponentData = JumpPowerInterface.JumpComponentData
type JumpInfoReturn = JumpPowerInterface.JumpInfoReturn
type AmplifyConfig = JumpPowerInterface.AmplifyConfig
type RevertConfig = JumpPowerInterface.RevertConfig


local PendingRevert = {}


-- ============================================
-- КОНФИГУРАЦИЯ
-- ============================================


local Config = {
	MAX_JUMP_POWER = 100,
	MIN_JUMP_POWER = 10,
	JUMP_POWER_PRECISION = 1,
	-- JumpHeight config (alternative к JumpPower)
	MAX_JUMP_HEIGHT = 50,
	MIN_JUMP_HEIGHT = 2,
	JUMP_HEIGHT_PRECISION = 1,
	ENABLE_SERVER_VALIDATION = true,
	DEBUG = false,
	USE_JUMP_HEIGHT = true, -- true = JumpHeight, false = JumpPower
}


-- ============================================
-- JUMP POWER CONTROLLER
-- ============================================


local JumpPowerController = {} :: IJumpPowerController
local Cache = setmetatable({}, { __mode = 'k' })


local Methods = {}


-- ============================================
-- УТИЛИТЫ
-- ============================================


local function RoundJumpValue(value: number): number
	local precision = Config.USE_JUMP_HEIGHT and Config.JUMP_HEIGHT_PRECISION or Config.JUMP_POWER_PRECISION
	local factor = 10 ^ precision
	return math.round(value * factor) / factor
end


local function Clamp(value: number, min: number, max: number): number
	return math.max(min, math.min(value, max))
end


local function GetJumpLimits(): (number, number)
	if Config.USE_JUMP_HEIGHT then
		return Config.MIN_JUMP_HEIGHT, Config.MAX_JUMP_HEIGHT
	else
		return Config.MIN_JUMP_POWER, Config.MAX_JUMP_POWER
	end
end


local function Log(message: string, ...)
	if Config.DEBUG then
		print('[JumpPowerController]', string.format(message, ...))
	end
end


local function Warn(message: string, ...)
	warn('[JumpPowerController]', string.format(message, ...))
end


-- ✅ ИСПРАВЛЕННАЯ ЛОГИКА: Проценты применяются от текущей (обрезанной) мощности
local function RecalculateJumpPower(self: IJumpPowerComponent): number
	local this_Data = self.Data
	local minJump, maxJump = GetJumpLimits()
	
	-- Начинаем с максимально допустимой мощности
	local currentJump = Clamp(this_Data.DefaultJump, minJump, maxJump)
	
	local sortedModifiers = {}
	for name, modifier in pairs(this_Data.Cache) do
		table.insert(sortedModifiers, modifier)
	end
	
	table.sort(sortedModifiers, function(a, b)
		return (a.Priority or 0) < (b.Priority or 0)
	end)
	
	for _, modifier in ipairs(sortedModifiers) do
		local percent = modifier.RawPercent
		if percent == nil then 
			percent = (modifier.Delta / this_Data.DefaultJump) * 100 
		end

		local multiplier = 1 + (percent / 100)
		
		if modifier.UseBaseJump then
			-- От базовой мощности (обрезанной)
			local baseJumpClamped = Clamp(this_Data.DefaultJump, minJump, maxJump)
			local addition = (baseJumpClamped * (percent / 100))
			currentJump = currentJump + addition
		else
			-- От текущей мощности
			currentJump = currentJump * multiplier
		end
		
		-- ✅ КРИТИЧНО: Обрезаем после каждого модификатора!
		currentJump = Clamp(currentJump, minJump, maxJump)
	end
	
	return RoundJumpValue(currentJump)
end


-- ============================================
-- ОСНОВНЫЕ МЕТОДЫ
-- ============================================


function Methods._SetJumpPower(self: IJumpPowerComponent, JumpValue: number)
	local this_Data = self.Data
	local Humanoid = self.Humanoid

	if not Humanoid or Humanoid.Health <= 0 then
		return false
	end

	local minJump, maxJump = GetJumpLimits()
	local roundedInput = RoundJumpValue(JumpValue)
	local validatedJump = Clamp(roundedInput, minJump, maxJump)
	
	if validatedJump ~= roundedInput then
		Warn("Jump power out of bounds: %.1f -> %.1f (clamped)", roundedInput, validatedJump)
	end

	-- Проверяем текущее значение (для обоих типов)
	local currentValue = Config.USE_JUMP_HEIGHT and Humanoid.JumpHeight or Humanoid.JumpPower
	
	if this_Data.CurrentJump == validatedJump and currentValue == validatedJump then
		return false
	end

	if RunService:IsClient() and (not self.Entity.SessionData.JumpData.CanChange) then
		return
	end
	
	self.Entity:SetJumpData('LastJump', this_Data.CurrentJump)
	self.Entity:SetJumpData('CurrentJump', validatedJump)
	
	-- Применяем к нужному свойству
	if Config.USE_JUMP_HEIGHT then
		Humanoid.JumpHeight = validatedJump
	else
		Humanoid.UseJumpPower = true
		Humanoid.JumpPower = validatedJump
	end

	Log("Jump power set: %.1f", validatedJump)

	if Config.ENABLE_SERVER_VALIDATION then
		self:_ReportJumpToServer(validatedJump)
	end

	return true
end


function Methods._ReportJumpToServer(self: IJumpPowerComponent, JumpValue: number)
	Log("Reported jump power to server: %.1f", JumpValue)
end


function Methods.Amplify(self: IJumpPowerComponent, Data: AmplifyConfig)
	local this_Data = self.Data
	local Humanoid = self.Humanoid

	if not Data or not Data.Name or Data.Percent == nil then
		Warn("Invalid Amplify data")
		return false
	end

	local Name = Data.Name
	local Percent = Data.Percent
	local UseBaseJump = Data.UseBaseJump or false
	local Priority = Data.Priority or 0
	local minJump, maxJump = GetJumpLimits()

	if this_Data.Cache[Name] then
		self.Entity:SetJumpData('Cache', nil, Name)
	end

	-- ✅ Используем текущую (обрезанную) мощность для расчета дельты
	local baseJump = Clamp(this_Data.DefaultJump, minJump, maxJump)
	
	if baseJump == 0 then return false end

	local delta = RoundJumpValue((baseJump / 100) * Percent)
	local modifierType: 'Buff' | 'Debuff' = if Percent > 0 then 'Buff' else 'Debuff'

	if modifierType == 'Debuff' and Data.ClearBuffsOnDebuff then
		self:_ClearAllModifiers()
	end

	self.Entity:SetJumpData('Cache', {
		Name = Name,
		Delta = delta,
		RawPercent = Percent,
		UseBaseJump = UseBaseJump,
		PreviousJump = Config.USE_JUMP_HEIGHT and Humanoid.JumpHeight or Humanoid.JumpPower,
		Type = modifierType,
		Priority = Priority,
		AppliedAt = tick(),
	}, Name)

	local newJump = RecalculateJumpPower(self)
	self:_SetJumpPower(newJump)

	Log("Amplified %s: %.1f%%", Name, Percent)
	return true
end


function Methods.Revert(self: IJumpPowerComponent, Data: RevertConfig)
	local this_Data = self.Data
	if not Data or not Data.Name then return false end
	local Name = Data.Name

	if not this_Data.Cache[Name] then return false end

	self.Entity:SetJumpData('Cache', nil, Name)

	local newJump = RecalculateJumpPower(self)
	self:_SetJumpPower(newJump)

	if (RunService:IsClient()) and (Data.Replicated) then
		Replicator:GetRemote('Global'):Fire('JumpRevert', Name)
	end

	Log("Reverted modifier: %s", Name)
	return true
end


function Methods._ClearAllModifiers(self: IJumpPowerComponent)
	local this_Data = self.Data
	local keysToRevert = {}
	for name in pairs(this_Data.Cache) do
		table.insert(keysToRevert, name)
	end

	for _, name in ipairs(keysToRevert) do
		self.Entity:SetJumpData('Cache', nil, name)
	end

	local newJump = RecalculateJumpPower(self)
	self:_SetJumpPower(newJump)
end


function Methods.GetModifier(self: IJumpPowerComponent, Name: string): JumpModifier?
	return self.Data.Cache[Name]
end


function Methods.GetAllModifiers(self: IJumpPowerComponent): {[string]: JumpModifier}
	return self.Data.Cache
end


function Methods.GetJumpInfo(self: IJumpPowerComponent): JumpInfoReturn
	local count = 0
	for _ in pairs(self.Data.Cache) do count += 1 end
	local minJump, maxJump = GetJumpLimits()
	return {
		Current = self.Data.CurrentJump,
		Default = self.Data.DefaultJump,
		Last = self.Data.LastJump,
		Max = maxJump,
		Min = minJump,
		ModifierCount = count,
		IsUsingJumpHeight = Config.USE_JUMP_HEIGHT,
	}
end


function Methods.ResetToDefault(self: IJumpPowerComponent)
	self:_ClearAllModifiers()
	self:_SetJumpPower(self.Data.DefaultJump)
end


function Methods.SetConfig(self: IJumpPowerComponent, NewConfig: {[string]: any})
	for key, value in pairs(NewConfig) do
		if Config[key] ~= nil then Config[key] = value end
	end
end


function JumpPowerController.new(Entity: EntityInterfaces.IEntityComponent): IJumpPowerComponent?
	local Player = Entity.Instance
	local Character = Player.Character
	if not Character then return nil end
	if Cache[Character] then return Cache[Character] end
	local Humanoid = Character:FindFirstChildOfClass('Humanoid')
	if not Humanoid then return nil end

	local self = setmetatable(JumpPowerTemplate(), {
		__index = function(t, key) return Methods[key] or JumpPowerController[key] end,
	}) :: any & IJumpPowerComponent

	self.Entity = Entity
	self.Character = Character
	self.Humanoid = Humanoid
	self.Data = Entity.SessionData.JumpData
	Cache[Character] = self

	local function Cleanup()
		Cache[Character] = nil
		self:_ClearAllModifiers()
	end

	Humanoid.Died:Connect(Cleanup)
	Character.AncestryChanged:Connect(function(child, parent)
		if parent == nil then Cleanup() end
	end)
	return self
end


function JumpPowerController.SetMaxJump(maxJump: number)
	if Config.USE_JUMP_HEIGHT then
		Config.MAX_JUMP_HEIGHT = maxJump
	else
		Config.MAX_JUMP_POWER = maxJump
	end
end


function JumpPowerController.SetMinJump(minJump: number)
	if Config.USE_JUMP_HEIGHT then
		Config.MIN_JUMP_HEIGHT = minJump
	else
		Config.MIN_JUMP_POWER = minJump
	end
end


function JumpPowerController.SetUseJumpHeight(useHeight: boolean)
	Config.USE_JUMP_HEIGHT = useHeight
end


function JumpPowerController.SetDebug(enabled: boolean)
	Config.DEBUG = enabled
end


return JumpPowerController :: IJumpPowerController
