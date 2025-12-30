local ReplicatedStorage = game:GetService('ReplicatedStorage')
local RunService = game:GetService("RunService")
local Shared = ReplicatedStorage:WaitForChild('Shared')
local Interfaces = Shared:WaitForChild('Interfaces')
local Templates = Shared:WaitForChild('Templates')


local TaskManager = require(script.Parent.TaskManager)
local EntityInterfaces = require(ReplicatedStorage.Shared.Interfaces.EntityInterfaces)
local LocalPlayerInterfaces = require(ReplicatedStorage.Shared.Interfaces.LocalPlayerInterfaces)
local Replicator = require(ReplicatedStorage.Shared.Utilities.NetWork.Replicator)
local SpeedInterface = require(Interfaces:WaitForChild('SpeedModuleInterface'))
local SpeedTemplate = require(Templates:WaitForChild('SpeedTemplate'))


type ISpeedComponent = SpeedInterface.ISpeedComponent
type ISpeedController = SpeedInterface.ISpeedController
type SpeedModifier = SpeedInterface.SpeedModifier
type SpeedComponentData = SpeedInterface.SpeedComponentData
type SpeedInfoReturn = SpeedInterface.SpeedInfoReturn
type AmplifyConfig = SpeedInterface.AmplifyConfig
type RevertConfig = SpeedInterface.RevertConfig

local PendingRevert = {}

-- ============================================
-- КОНФИГУРАЦИЯ
-- ============================================


local Config = {
	MAX_WALK_SPEED = 40,
	MIN_WALK_SPEED = 0,
	SPEED_PRECISION = 1, -- Один десятичный знак
	ENABLE_SERVER_VALIDATION = true,
	DEBUG = false,
}


-- ============================================
-- SPEED CONTROLLER
-- ============================================


local SpeedController = {} :: ISpeedController
local Cache = setmetatable({}, { __mode = 'k' }) -- Слабые ссылки (автоочистка)


local Methods = {}


-- ============================================
-- УТИЛИТЫ
-- ============================================


local function RoundSpeed(speed: number): number
	local factor = 10 ^ Config.SPEED_PRECISION
	return math.round(speed * factor) / factor
end


local function Clamp(value: number, min: number, max: number): number
	return math.max(min, math.min(value, max))
end


local function Log(message: string, ...)
	if Config.DEBUG then
		print('[SpeedController]', string.format(message, ...))
	end
end


local function Warn(message: string, ...)
	warn('[SpeedController]', string.format(message, ...))
end


-- ============================================
-- ОСНОВНЫЕ МЕТОДЫ
-- ============================================


--- Устанавливает скорость с валидацией
function Methods._SetSpeed(self: ISpeedComponent, Speed: number)
	local this_Data = self.Data
	local Humanoid = self.Humanoid


	-- Проверка состояния персонажа
	if not Humanoid or Humanoid.Health <= 0 then
		Log("Cannot set speed: character is dead or humanoid missing")
		return false
	end


	-- Локальная валидация
	local validatedSpeed = Clamp(Speed, Config.MIN_WALK_SPEED, Config.MAX_WALK_SPEED)
	validatedSpeed = RoundSpeed(validatedSpeed)


	-- Если скорость была обрезана, логируем
	if validatedSpeed ~= Speed then
		Warn("Speed out of bounds: %.1f -> %.1f (clamped)", Speed, validatedSpeed)
	end


	-- Если скорость не изменилась, выходим
	if this_Data.CurrentSpeed == validatedSpeed then
		return false
	end

	if RunService:IsClient() and (not self.Entity.SessionData.SpeedData.CanChange) then
		return
	end
	
	self.Entity:SetSpeedData('LastSpeed',this_Data.CurrentSpeed)
	self.Entity:SetSpeedData('CurrentSpeed',validatedSpeed)
	
	Humanoid.WalkSpeed = validatedSpeed


	Log("Speed set: %.1f (from %.1f)", validatedSpeed, this_Data.LastSpeed)


	-- Отправка на сервер для валидации (по необходимости)
	if Config.ENABLE_SERVER_VALIDATION then
		self:_ReportSpeedToServer(validatedSpeed)
	end


	return true
end


--- Отправляет скорость на сервер для проверки
function Methods._ReportSpeedToServer(self: ISpeedComponent, Speed: number)
	-- Реализация зависит от вашей RPC системы
	-- Пример:
	-- local RemoteEvent = ReplicatedStorage:FindFirstChild('ValidateSpeed')
	-- if RemoteEvent then
	--     RemoteEvent:FireServer(Speed, self.Humanoid.Parent.Name)
	-- end

	Log("Reported speed to server: %.1f", Speed)
end


--- Применяет процентный модификатор к скорости
function Methods.Amplify(self: ISpeedComponent, Data: AmplifyConfig)
	local this_Data = self.Data
	local Humanoid = self.Humanoid


	-- Валидация входных данных
	if not Data or not Data.Name or Data.Percent == nil then
		Warn("Invalid Amplify data: %s", tostring(Data))
		return false
	end


	local Name = Data.Name
	local Percent = Data.Percent
	local UseBaseSpeed = Data.UseBaseSpeed or false
	local Priority = Data.Priority or 0


	if this_Data.Cache[Name] then
		self:Revert({ Name = Name,Replicated = Data.Replicated })
	end


	local baseSpeed = UseBaseSpeed and this_Data.DefaultSpeed or this_Data.CurrentSpeed


	if baseSpeed == 0 and not UseBaseSpeed then
		Warn("Cannot amplify: base speed is zero for %s", Name)
		return false
	end


	-- Вычисляем дельту (изменение скорости)
	local delta = RoundSpeed((baseSpeed / 100) * Percent)


	-- Определяем тип (Buff или Debuff)
	local modifierType: 'Buff' | 'Debuff' = if delta > 0 then 'Buff' else 'Debuff'


	-- Если это Debuff, реверти все текущие баффы (опционально)
	if modifierType == 'Debuff' and Data.ClearBuffsOnDebuff then
		self:_ClearAllModifiers()
	end


	self.Entity:SetSpeedData('Cache',{
		Name = Name,
		Delta = delta,
		PreviousSpeed = Humanoid.WalkSpeed,
		Type = modifierType,
		Priority = Priority,
		AppliedAt = tick(),
	},Name)

	local newSpeed = Humanoid.WalkSpeed + delta
	self:_SetSpeed(newSpeed)


	Log("Amplified %s: %s (delta: +%.1f)", Name, modifierType, delta)
	return true
end

--- Отменяет модификатор и возвращает предыдущую скорость
function Methods.Revert(self: ISpeedComponent, Data: RevertConfig)
	local this_Data = self.Data
	local _Humanoid = self.Humanoid


	if not Data or not Data.Name then
		Warn("Invalid Revert data")
		return false
	end


	local Name = Data.Name
	local modifier = this_Data.Cache[Name]


	if not modifier then
		Log("No modifier found to revert: %s", Name)
		return false
	end


	self:_SetSpeed(modifier.PreviousSpeed)
	self.Entity:SetSpeedData('Cache',nil,Name)

	if (RunService:IsClient()) and (Data.Replicated) then
		Replicator:GetRemote('Global'):Fire('SpeedRevert',Name)
	end

	Log("Reverted modifier: %s", Name)
	return true
end


--- Отменяет все модификаторы
function Methods._ClearAllModifiers(self: ISpeedComponent)
	local this_Data = self.Data


	-- Копируем ключи перед итерацией (безопасно)
	local keysToRevert = {}
	for name in pairs(this_Data.Cache) do
		table.insert(keysToRevert, name)
	end


	for _, name in ipairs(keysToRevert) do
		self:Revert({ Name = name ,Replicated = true})
	end


	Log("Cleared all modifiers")
end


--- Получает текущий модификатор
function Methods.GetModifier(self: ISpeedComponent, Name: string): SpeedModifier?
	return self.Data.Cache[Name]
end


--- Получает все активные модификаторы
function Methods.GetAllModifiers(self: ISpeedComponent): {[string]: SpeedModifier}
	return self.Data.Cache
end


--- Получает информацию о скорости
function Methods.GetSpeedInfo(self: ISpeedComponent): SpeedInfoReturn
	local count = 0
	for _ in pairs(self.Data.Cache) do
		count += 1
	end


	return {
		Current = self.Data.CurrentSpeed,
		Default = self.Data.DefaultSpeed,
		Last = self.Data.LastSpeed,
		Max = Config.MAX_WALK_SPEED,
		Min = Config.MIN_WALK_SPEED,
		ModifierCount = count,
	}
end


--- Сбрасывает скорость к значению по умолчанию
function Methods.ResetToDefault(self: ISpeedComponent)
	self:_ClearAllModifiers()
	self:_SetSpeed(self.Data.DefaultSpeed)
	Log("Speed reset to default: %.1f", self.Data.DefaultSpeed)
end


--- Обновляет конфиг (для рантайма)
function Methods.SetConfig(self: ISpeedComponent, NewConfig: {[string]: any})
	for key, value in pairs(NewConfig) do
		if Config[key] ~= nil then
			Config[key] = value
			Log("Config updated: %s = %s", key, tostring(value))
		end
	end
end


-- ============================================
-- КОНСТРУКТОР
-- ============================================


function SpeedController.new(Entity: EntityInterfaces.IEntityComponent): ISpeedComponent?
	local Player = Entity.Instance
	local Character = Player.Character


	-- Проверка Character
	if not Character then
		Warn("Character not found for entity %s", Player.Name)
		return nil
	end


	-- Кеширование (если уже создан, вернуть кешированный)
	if Cache[Character] then
		Log("Returning cached SpeedComponent for %s", Character.Name)
		return Cache[Character]
	end


	-- Поиск Humanoid
	local Humanoid = Character:FindFirstChildOfClass('Humanoid')
	if not Humanoid then
		Warn("Humanoid not found in character %s", Character.Name)
		return nil
	end


	-- Создание экземпляра
	local self = setmetatable(SpeedTemplate(), {
		__index = function(t, key)
			return Methods[key] or SpeedController[key]
		end,
	}) :: any & ISpeedComponent


	-- Инициализация данных
	self.Entity = Entity
	self.Character = Character
	self.Humanoid = Humanoid
	self.Data = Entity.SessionData.SpeedData


	-- Кеширование
	Cache[Character] = self


	-- Очистка при удалении персонажа
	local function Cleanup()
		Log("Cleaning up SpeedComponent for %s", Character.Name)
		Cache[Character] = nil
		self:_ClearAllModifiers()
	end


	-- Слушатель на смерть персонажа
	Humanoid.Died:Connect(Cleanup)


	-- Слушатель на удаление персонажа
	Character.AncestryChanged:Connect(function(child, parent)
		if parent == nil then
			Cleanup()
		end
	end)


	Log("SpeedComponent created for %s (default speed: %.1f)", Character.Name, self.Data.DefaultSpeed)
	return self
end


-- ============================================
-- КОНФИГУРАЦИЯ (публичное изменение)
-- ============================================


function SpeedController.SetMaxSpeed(maxSpeed: number)
	Config.MAX_WALK_SPEED = maxSpeed
	Log("Global max speed updated: %.1f", maxSpeed)
end


function SpeedController.SetDebug(enabled: boolean)
	Config.DEBUG = enabled
end


return SpeedController :: ISpeedController
