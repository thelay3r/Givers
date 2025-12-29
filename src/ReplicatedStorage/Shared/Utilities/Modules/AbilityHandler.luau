local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild('Shared')
local Utilities = Shared:WaitForChild('Utilities')
local _Modules = Utilities:WaitForChild('Modules')
local AbilitesFolder = Shared:WaitForChild('Abilities')

-- use ServerStorage abilities (as in init)
local Bricks = ReplicatedStorage:WaitForChild('Bricksv2')

local Components = Bricks:WaitForChild('Components')
local Data = Bricks:WaitForChild('Data')
local Registries = Data:WaitForChild('Registries')

local Registry = require(Components:WaitForChild('Registry'))
local AbilityParser = require(Components:WaitForChild('AbilityParser'))
local ParserObject = require(Components:WaitForChild('ParserObject'))
local scopeRegistry = require(Registries:WaitForChild('ScopeRegistry'))
local RegistryManager = require(ReplicatedStorage.Bricksv2.Components.RegistryManager)
local _RegistryManager = require(ReplicatedStorage.Bricksv2.Components.RegistryManager)
local BehaviorRegistries = Data:WaitForChild('Registries'):WaitForChild('BehaviorRegistries')



local InjectedRegistries = {}

for i,v in pairs(BehaviorRegistries:GetChildren()) do
    if not v:IsA('ModuleScript') then continue end
	InjectedRegistries[i] = require(v)
end

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

local Test = {}

function Test:Execute(structure)
	abilityParser:Execute(structure, self.Instance)
end

function AbilityHandler.GetByKeyCode(name, entityId, key)
    local ability = GetFromCache(name, entityId)
    if not ability then return end

    local config = ability.Instance.Config
    if not config then return end

    if config.KeyCode.Name ~= key then return end
    return ability
end



function AbilityHandler.new(config: {Ability: any, Registry: any?}) : typeof(AbilityParser)
	-- create parser-backed ability instance using shared parser factory
	local ability = ParserObject.new()
	
	RegistryManager:InjectRegistry(config.Registry)
	ability.BehaviorRegistry = Registry.new():Extends({config.Registry, defaultBehaviorRegistry}) 
	ability.ScopeRegistry = Registry.new():Extends({defaultScopeRegistry}) 
	

    
	abilityParser:Create(config.Ability, ability)

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

    task.spawn(function()
        self.Instance:Execute({
            Name = 'Action.TriggerEvent';
            Config = 
                {
                    TagName = 'OnStart';
                }
        })
    end)

end

function AbilityHandler:OnStop()


    task.spawn(function()
        self.Instance:Execute({
            Name = 'Action.TriggerEvent';
            Config = 
                {
                    TagName = 'OnStop';
                }
        })
    end)
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