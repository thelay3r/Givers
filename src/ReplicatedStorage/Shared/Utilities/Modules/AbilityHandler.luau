local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local Shared = ReplicatedStorage:WaitForChild('Shared')
local Utilities = Shared:WaitForChild('Utilities')
local _Modules = Utilities:WaitForChild('Modules')

-- use ServerStorage abilities (as in init)
local AbilitesFolder = ServerStorage:WaitForChild('Abilities')
local Bricks = ReplicatedStorage:WaitForChild('Bricksv2')

local Components = Bricks:WaitForChild('Components')
local Data = Bricks:WaitForChild('Data')
local Registries = Data:WaitForChild('Registries')

local Registry = require(Components:WaitForChild('Registry'))
local AbilityParser = require(Components:WaitForChild('AbilityParser'))

local abilityRegistry = require(Registries:WaitForChild('AbilityRegistry'))
local conditionRegistry = require(Registries:WaitForChild('ConditionRegistry'))

local defaultRegistry = require(Registries:WaitForChild('DefaultRegistry'))
local eventRegistry = require(Registries:WaitForChild('EventRegistry'))

local projectileRegistry = require(Registries:WaitForChild('ProjectileRegistry'))
local scopeRegistry = require(Registries:WaitForChild('ScopeRegistry'))
local abilityScopeRegistry = require(Registries:WaitForChild('AbilityScopeRegistry'))

local InjectedRegistries = {
    abilityRegistry, conditionRegistry,
    defaultRegistry, eventRegistry,
    projectileRegistry
}

local defaultBehaviorRegistry = Registry.new():Extends(InjectedRegistries)
local defaultScopeRegistry = Registry.new():Extends({scope_registry = scopeRegistry}) -- placeholder if needed

-- create a shared parser instance for faster reuse (matches init behavior)
local abilityParser = AbilityParser.new()

local AbilityHandler = {}
local Abilities = {}

local function addToCache(name, entityId, ability)
    if (not Abilities[entityId]) then Abilities[entityId] = {} end
    Abilities[entityId][name] = ability
end

local function GetFromCache(name, entityId)
    if not Abilities[entityId] then return nil end
    return Abilities[entityId][name]
end

function AbilityHandler.GetByKeyCode(name, entityId, key)
    local ability = GetFromCache(name, entityId)
    if not ability then return end

    local config = ability.Instance.Config
    if not config then return end

    if config.KeyCode.Name ~= key then return end
    return ability
end

function AbilityHandler.createByName(packName, abilityName) : typeof(AbilityHandler)
    assert(AbilitesFolder:FindFirstChild(packName), (`%s doesnt exist!`):format(packName))
    assert(AbilitesFolder[packName]:FindFirstChild(abilityName), (`%s in %s pack doesnt exist!`):format(abilityName, packName))

    local ability = AbilityHandler.new(
        require(AbilitesFolder[packName][abilityName])
    )

    return ability
end

function AbilityHandler.new(config: {Ability: any, Behavior: any?}) : typeof(AbilityParser)
    -- create parser-backed ability instance using shared parser factory
    local ability = abilityParser:Create(config.Ability)

    ability.BehaviorRegistry = Registry.new():Extends({defaultBehaviorRegistry, config.Behavior}) 
    ability.ScopeRegistry = Registry.new():Extends({defaultScopeRegistry}) 

    local createdAbility = setmetatable({
        Instance = ability
    }, {
        __index = function(_, i)
            return AbilityHandler[i]
        end
    })

    return createdAbility
end

function AbilityHandler:Build()
    self.Instance:Build()
end

function AbilityHandler:OnStart()
    self.Instance:Execute(
        {
            Name = 'Action.TriggerEvent';
            Config = 
            {
                TagName = 'OnStart';
            }
        })
end

function AbilityHandler:OnStop()
    self.Instance:Execute(
        {
            Name = 'Action.TriggerEvent';
            Config = 
            {
                TagName = 'OnStop';
            }
        })
end

function AbilityHandler.GetAbility(name,entityId)
    return GetFromCache(name, entityId)
end

function AbilityHandler:BindToEntity(name: string, entityId: number)
    self:Build()
    addToCache(name, entityId, self)
end

function AbilityHandler:UnBindToEntity(name:string,entityId:number)
    local ability = GetFromCache(name,entityId)
    if not ability then return end
    if ability.Instance and type(ability.Instance.Destroy) == "function" then
        ability.Instance:Destroy()
    end
    ability.Instance = nil
    if Abilities[entityId] then
        Abilities[entityId][name] = nil
    end
end

return AbilityHandler