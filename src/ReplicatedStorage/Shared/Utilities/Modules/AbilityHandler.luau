local ReplicatedStorage = game:GetService("ReplicatedStorage")


local Shared = ReplicatedStorage:WaitForChild('Shared')
local Utilities = Shared:WaitForChild('Utilities')
local _Modules = Utilities:WaitForChild('Modules')

local AbilitesFolder = Shared:WaitForChild('Abilities')
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
local behaviorRegistry = require(Registries:WaitForChild('BehaviorRegistry'))

local scopeRegistry = require(Registries:WaitForChild('ScopeRegistry'))
local networkRegistry = require(Registries:WaitForChild('NetWorkRegistry'))
local abilitiesRegistry = require(Registries:WaitForChild('AbilitiesRegistry'))

local InjectedRegistries = {
    abilityRegistry, conditionRegistry,
    defaultRegistry, eventRegistry, 
    projectileRegistry,behaviorRegistry,networkRegistry,abilitiesRegistry,
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
function AbilityHandler.GetByKeyCode(name, entityId)
    local ability = Abilities[entityId][name]
    if not ability then return end
    local config = Abilities[entityId][name].Config
    if not config then return end
    return Abilities[entityId][name].Config.KeyCode.Name
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
    local _behaviorRegistry = Registry.new():Extends(InjectedRegistries)

    ability.BehaviorRegistry = _behaviorRegistry
    ability.ScopeRegistry = scopeRegistry
    print(ability.ScopeRegistry)
    ability:Create(config)

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
    print('Alo')
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
    print('Alo 2')
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