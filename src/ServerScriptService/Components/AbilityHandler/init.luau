local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")


local Shared = ReplicatedStorage:WaitForChild('Shared')
local Utilities = Shared:WaitForChild('Utilities')
local _Modules = Utilities:WaitForChild('Modules')

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

local InjectedRegistries = {
    abilityRegistry, conditionRegistry,
    defaultRegistry, eventRegistry, 
    projectileRegistry
}

local AbilityHandler = {}
local Abilities = {}

local function addToCache(name, entityId, ability)
    if (not Abilities[entityId]) then Abilities[entityId] = {} end
    Abilities[entityId][name] = ability
end

local function GetFromCache(name, entityId)
    return Abilities[entityId][name]
end

function AbilityHandler.createByName(packName, abilityName) : typeof(AbilityHandler)
    assert(AbilitesFolder:FindFirstChild(packName), `{packName} doesnt exist!`)
    assert(AbilitesFolder[packName]:FindFirstChild(abilityName), `{abilityName} in {packName} pack doesnt exist!`)

    local ability = AbilityHandler.new(
        require(AbilitesFolder[packName][abilityName])
    )

    return ability
end

function AbilityHandler.new(config: {}) : typeof(AbilityParser)
    local ability = AbilityParser.new()
    local behaviorRegistry = Registry.new():Extends(InjectedRegistries)

    ability.BehaviorRegistry = behaviorRegistry
    ability.ScopeRegistry = scopeRegistry

    ability:Create(config)

    local createdAbility = setmetatable({
        Instance = ability
    }, {
        __index = function(t, i)
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
    ability.Instance:Destroy()
    ability.Instance = nil
    ability = nil
end

return AbilityHandler