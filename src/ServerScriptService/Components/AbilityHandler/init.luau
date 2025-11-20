local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService('ServerScriptService')
local ServerStorage = game:GetService("ServerStorage")


local Shared = ReplicatedStorage:WaitForChild('Shared')
local Utilities = Shared:WaitForChild('Utilities')
local Modules = Utilities:WaitForChild('Modules')

local AbilitesFolder = ServerStorage:WaitForChild('Abilities')


local Bricks = ServerScriptService:WaitForChild('Bricksv2')

local Components = Bricks:WaitForChild('Components')
local Data = Bricks:WaitForChild('Data')
local Registries = Data:WaitForChild('Registries')

local Registry = require(Components:WaitForChild('Registry'))
local AbilityParser = require(Components:WaitForChild('AbilityParser'))

local behaviorRegistry = require(Registries:WaitForChild('BehaviorRegistry'))
local scopeRegistry = require(Registries:WaitForChild('ScopeRegistry'))
local conditionRegisrty = require(Registries:WaitForChild('ConditionRegistry'))


local AbilityHandler = {}
local Abilities = {}

function AbilityHandler._AddToCache(EntityId,AbilityName,ability)
    if not Abilities[EntityId] then Abilities[EntityId] = {} end
    Abilities[EntityId][AbilityName] = ability
end

function AbilityHandler.AddAbility(EntityId,packName,abilityName)
    local ability = AbilityHandler.new(abilityName,EntityId,require(AbilitesFolder[packName][abilityName]))

    return ability
end

function AbilityHandler.new(name: string,EntityId,Config: {}) : typeof(AbilityParser)
    local ability = AbilityParser.new()
    local InheritanceRoot = Registry.new():Clone(behaviorRegistry)

    
    ability.BehaviorRegistry = InheritanceRoot
    ability.ScopeRegistry = scopeRegistry
    ability.ConditionRegistry = conditionRegisrty 

    ability:Create(Config)
    ability:Build()

    AbilityHandler._AddToCache(EntityId, name, ability)
    return ability
end



function AbilityHandler.OnStart(name: string,EntityId)
    if not Abilities[EntityId][name] then return end
    local ability = Abilities[EntityId][name]
    ability:Execute(
        {
            Name = 'Action.TriggerEvent';
            Config = 
            {
                TagName = 'OnStart'
            }
        })
end
function AbilityHandler.OnStop(name: string,EntityId)
    if not Abilities[EntityId][name] then return end
    local ability = Abilities[EntityId][name]
    ability:Execute(
        {
            Name = 'Action.TriggerEvent';
            Config = 
            {
                TagName = 'OnStop'
            }
        })
end





return AbilityHandler