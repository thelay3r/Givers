local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService('ServerScriptService')
local ServerStorage = game:GetService("ServerStorage")


local Shared = ReplicatedStorage:WaitForChild('Shared')
local Utilities = Shared:WaitForChild('Utilities')
local _Modules = Utilities:WaitForChild('Modules')

local AbilitesFolder = ServerStorage:WaitForChild('Abilities')
local Bricks = ServerScriptService:WaitForChild('Bricksv2')

local Components = Bricks:WaitForChild('Components')
local Data = Bricks:WaitForChild('Data')
local Registries = Data:WaitForChild('Registries')

local Entity = require(ServerScriptService.Components:WaitForChild('EntityComponent'))

local Registry = require(Components:WaitForChild('Registry'))
local AbilityParser = require(Components:WaitForChild('AbilityParser'))

local behaviorRegistry = require(Registries:WaitForChild('BehaviorRegistry'))
local scopeRegistry = require(Registries:WaitForChild('ScopeRegistry'))
local conditionRegisrty = require(Registries:WaitForChild('ConditionRegistry'))
local TableHelper = require(ReplicatedStorage.Shared.Utilities.Modules.TableHelper)


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

local function FindAbility(name,_table)
    local target
    for _name,v in pairs(_table) do
        if _name == name then 
            target = v 
            return target
        end
        if typeof(v) == 'table' then target = FindAbility(name,v) end
    end

    return target
end


function AbilityHandler.OnStart(name: string,EntityId)
    if not Abilities[EntityId][name] then return end
    local ability = Abilities[EntityId][name]
    local _Entity = Entity.GetEntity(EntityId)
    local _ability = FindAbility(name,Abilities[EntityId])
    print(_ability)
    ability:Execute(
        {
            Name = 'Action.TriggerEvent';
            Config = 
            {
                TagName = 'OnStart';
                Entity = _Entity;
            }
        })
end
function AbilityHandler.OnStop(name: string,EntityId)
    if not Abilities[EntityId][name] then return end
    local ability = Abilities[EntityId][name]
    local _Entity = Entity.GetEntity(EntityId)

    ability:Execute(
        {
            Name = 'Action.TriggerEvent';
            Config = 
            {
                TagName = 'OnStop';
                Entity = _Entity;
            }
        })
end





return AbilityHandler