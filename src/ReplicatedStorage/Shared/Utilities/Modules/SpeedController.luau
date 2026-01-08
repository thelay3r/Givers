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
    MIN_WALK_SPEED = 1,
    SPEED_PRECISION = 1,
    ENABLE_SERVER_VALIDATION = true,
    DEBUG = false,
}

-- ============================================
-- SPEED CONTROLLER
-- ============================================

local SpeedController = {} :: ISpeedController
local Cache = setmetatable({}, { __mode = 'k' })

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

-- ✅ ИСПРАВЛЕННАЯ ЛОГИКА: Проценты применяются от текущей (обрезанной) скорости
local function RecalculateSpeed(self: ISpeedComponent): number
    local this_Data = self.Data
    
    -- Начинаем с максимально допустимой скорости (а не с дефолтной)
    -- Это гарантирует, что мы никогда не выйдем за лимиты
    local currentSpeed = Clamp(this_Data.DefaultSpeed, Config.MIN_WALK_SPEED, Config.MAX_WALK_SPEED)
    
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
             percent = (modifier.Delta / this_Data.DefaultSpeed) * 100 
        end

        local multiplier = 1 + (percent / 100)
        
        if modifier.UseBaseSpeed then
            -- От базовой скорости (обрезанной)
            local baseSpeedClamped = Clamp(this_Data.DefaultSpeed, Config.MIN_WALK_SPEED, Config.MAX_WALK_SPEED)
            local addition = (baseSpeedClamped * (percent / 100))
            currentSpeed = currentSpeed + addition
        else
            -- От текущей скорости
            currentSpeed = currentSpeed * multiplier
        end
        
        -- ✅ КРИТИЧНО: Обрезаем после каждого модификатора!
        currentSpeed = Clamp(currentSpeed, Config.MIN_WALK_SPEED, Config.MAX_WALK_SPEED)
    end
    
    return RoundSpeed(currentSpeed)
end

-- ============================================
-- ОСНОВНЫЕ МЕТОДЫ
-- ============================================

function Methods._SetSpeed(self: ISpeedComponent, Speed: number)
    local this_Data = self.Data
    local Humanoid = self.Humanoid

    if not Humanoid or Humanoid.Health <= 0 then
        return false
    end

    local roundedInput = RoundSpeed(Speed)
    local validatedSpeed = Clamp(roundedInput, Config.MIN_WALK_SPEED, Config.MAX_WALK_SPEED)
    
    if validatedSpeed ~= roundedInput then
        Warn("Speed out of bounds: %.1f -> %.1f (clamped)", roundedInput, validatedSpeed)
    end

    if this_Data.CurrentSpeed == validatedSpeed and Humanoid.WalkSpeed == validatedSpeed then
        return false
    end

    if RunService:IsClient() and (not self.Entity.SessionData.SpeedData.CanChange) then
        return
    end
    
    self.Entity:SetSpeedData('LastSpeed', this_Data.CurrentSpeed)
    self.Entity:SetSpeedData('CurrentSpeed', validatedSpeed) -- ✅ Сохраняем уже обрезанное значение
    
    Humanoid.WalkSpeed = validatedSpeed

    Log("Speed set: %.1f", validatedSpeed)

    if Config.ENABLE_SERVER_VALIDATION then
        self:_ReportSpeedToServer(validatedSpeed)
    end

    return true
end

function Methods._ReportSpeedToServer(self: ISpeedComponent, Speed: number)
    Log("Reported speed to server: %.1f", Speed)
end

function Methods.Amplify(self: ISpeedComponent, Data: AmplifyConfig)
    local this_Data = self.Data
    local Humanoid = self.Humanoid

    if not Data or not Data.Name or Data.Percent == nil then
        Warn("Invalid Amplify data")
        return false
    end

    local Name = Data.Name
    local Percent = Data.Percent
    local UseBaseSpeed = Data.UseBaseSpeed or false
    local Priority = Data.Priority or 0

    if this_Data.Cache[Name] then
        self.Entity:SetSpeedData('Cache', nil, Name)
    end

    -- ✅ Используем текущую (обрезанную) скорость для расчета дельты
    local baseSpeed = Clamp(this_Data.DefaultSpeed, Config.MIN_WALK_SPEED, Config.MAX_WALK_SPEED)
    
    if baseSpeed == 0 then return false end

    local delta = RoundSpeed((baseSpeed / 100) * Percent)
    local modifierType: 'Buff' | 'Debuff' = if Percent > 0 then 'Buff' else 'Debuff'

    if modifierType == 'Debuff' and Data.ClearBuffsOnDebuff then
        self:_ClearAllModifiers()
    end

    self.Entity:SetSpeedData('Cache', {
        Name = Name,
        Delta = delta,
        RawPercent = Percent,
        UseBaseSpeed = UseBaseSpeed,
        PreviousSpeed = Humanoid.WalkSpeed,
        Type = modifierType,
        Priority = Priority,
        AppliedAt = tick(),
    }, Name)

    local newSpeed = RecalculateSpeed(self)
    self:_SetSpeed(newSpeed)

    Log("Amplified %s: %.1f%%", Name, Percent)
    return true
end

function Methods.Revert(self: ISpeedComponent, Data: RevertConfig)
    local this_Data = self.Data
    if not Data or not Data.Name then return false end
    local Name = Data.Name

    if not this_Data.Cache[Name] then return false end

    self.Entity:SetSpeedData('Cache', nil, Name)

    local newSpeed = RecalculateSpeed(self)
    self:_SetSpeed(newSpeed)

    if (RunService:IsClient()) and (Data.Replicated) then
        Replicator:GetRemote('Global'):Fire('SpeedRevert', Name)
    end

    Log("Reverted modifier: %s", Name)
    return true
end

function Methods._ClearAllModifiers(self: ISpeedComponent)
    local this_Data = self.Data
    local keysToRevert = {}
    for name in pairs(this_Data.Cache) do
        table.insert(keysToRevert, name)
    end

    for _, name in ipairs(keysToRevert) do
         self.Entity:SetSpeedData('Cache', nil, name)
    end

    local newSpeed = RecalculateSpeed(self)
    self:_SetSpeed(newSpeed)
end

function Methods.GetModifier(self: ISpeedComponent, Name: string): SpeedModifier?
    return self.Data.Cache[Name]
end

function Methods.GetAllModifiers(self: ISpeedComponent): {[string]: SpeedModifier}
    return self.Data.Cache
end

function Methods.GetSpeedInfo(self: ISpeedComponent): SpeedInfoReturn
    local count = 0
    for _ in pairs(self.Data.Cache) do count += 1 end
    return {
        Current = self.Data.CurrentSpeed,
        Default = self.Data.DefaultSpeed,
        Last = self.Data.LastSpeed,
        Max = Config.MAX_WALK_SPEED,
        Min = Config.MIN_WALK_SPEED,
        ModifierCount = count,
    }
end

function Methods.ResetToDefault(self: ISpeedComponent)
    self:_ClearAllModifiers()
    self:_SetSpeed(self.Data.DefaultSpeed)
end

function Methods.SetConfig(self: ISpeedComponent, NewConfig: {[string]: any})
    for key, value in pairs(NewConfig) do
        if Config[key] ~= nil then Config[key] = value end
    end
end

function SpeedController.new(Entity: EntityInterfaces.IEntityComponent): ISpeedComponent?
    local Player = Entity.Instance
    local Character = Player.Character
    if not Character then return nil end
    if Cache[Character] then return Cache[Character] end
    local Humanoid = Character:FindFirstChildOfClass('Humanoid')
    if not Humanoid then return nil end

    local self = setmetatable(SpeedTemplate(), {
        __index = function(t, key) return Methods[key] or SpeedController[key] end,
    }) :: any & ISpeedComponent

    self.Entity = Entity
    self.Character = Character
    self.Humanoid = Humanoid
    self.Data = Entity.SessionData.SpeedData
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

function SpeedController.SetMaxSpeed(maxSpeed: number)
    Config.MAX_WALK_SPEED = maxSpeed
end

function SpeedController.SetDebug(enabled: boolean)
    Config.DEBUG = enabled
end

return SpeedController :: ISpeedController
