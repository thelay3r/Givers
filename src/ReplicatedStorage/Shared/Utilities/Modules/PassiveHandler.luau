local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild('Shared')
local Utilities = Shared:WaitForChild('Utilities')
local _Modules = Utilities:WaitForChild('Modules')
local PassivesFolder = Shared:WaitForChild('Passives')

-- use ServerStorage Passives (as in init)
local Bricks = ReplicatedStorage:WaitForChild('Bricksv2')

local Components = Bricks:WaitForChild('Components')
local Data = Bricks:WaitForChild('Data')
local Registries = Data:WaitForChild('Registries')

local Registry = require(Components:WaitForChild('Registry'))
local _PassiveParser = require(Components:WaitForChild('AbilityParser'))
local PassiveParserObject = require(Components:WaitForChild('ParserObject'))
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
local PassiveParser = _PassiveParser.new()

local PassiveHandler = {}
local Passives = {}

local function addToCache(name, entityId, Passive)
    if (not Passives[entityId]) then Passives[entityId] = {} end
    Passives[entityId][name] = Passive
end

local function GetFromCache(name, entityId)
    if not Passives[entityId] then return nil end
    return Passives[entityId][name]
end

local Test = {}

function Test:Execute(structure)
	PassiveParser:Execute(structure, self.Instance)
end

function PassiveHandler.GetByKeyCode(name, entityId, key)
    local Passive = GetFromCache(name, entityId)
    if not Passive then return end

    local config = Passive.Instance.Config
    if not config then return end

    if config.KeyCode.Name ~= key then return end
    return Passive
end

function PassiveHandler.createByName(packName, PassiveName) : typeof(PassiveHandler)
    assert(PassivesFolder:FindFirstChild(packName), (`%s doesnt exist!`):format(packName))
    assert(PassivesFolder[packName]:FindFirstChild(PassiveName), (`%s in %s pack doesnt exist!`):format(PassiveName, packName))

    local Passive = PassiveHandler.new(
        require(PassivesFolder[packName][PassiveName])
    )

	print(Passive)
    return Passive
end

function PassiveHandler.new(config: {Passive: any, Registry: any?}) : typeof(PassiveParser)
	-- create parser-backed Passive instance using shared parser factory
	local Passive = PassiveParserObject.new()
	
	RegistryManager:InjectRegistry(config.Registry)
	Passive.BehaviorRegistry = Registry.new():Extends({config.Registry, defaultBehaviorRegistry}) 
	Passive.ScopeRegistry = Registry.new():Extends({defaultScopeRegistry}) 
	
	PassiveParser:Create(config.Passive, Passive)
    local createdPassive = setmetatable({
        Instance = Passive
    }, {
        __index = function(_, i)
            return PassiveHandler[i]
        end
    })
	
    return createdPassive
end

function PassiveHandler:Build()
    self.Instance:Build()
end

function PassiveHandler:Trigger(eventName: string,args: {any?} )
    self.Instance:Execute({
        Name = 'Action.TriggerEvent';
        Config = 
            {
                TagName = eventName;
                EventData = args;
            }
    })
end


function PassiveHandler.GetPassive(name,entityId)
    return GetFromCache(name, entityId)
end

function PassiveHandler:BindToEntity(name: string, entityId: number)
    self:Build()
    addToCache(name, entityId, self)
end

function PassiveHandler:UnBindToEntity(name:string,entityId:number)
    local Passive = GetFromCache(name,entityId)
    if not Passive then return end
    if Passive.Instance and type(Passive.Instance.Destroy) == "function" then
        Passive.Instance:Destroy()
    end
    Passive.Instance = nil
    if Passives[entityId] then
        Passives[entityId][name] = nil
    end
end

return PassiveHandler