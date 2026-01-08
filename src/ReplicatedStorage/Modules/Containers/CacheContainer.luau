local CacheContainer = {}
CacheContainer.__index = CacheContainer

type ICache = typeof(CacheContainer)
type ResetProps = {string}

local Container = {}

function CacheContainer.new()
    local self = setmetatable({}, CacheContainer)
    return self
end

function CacheContainer.GetScope(self: ICache, Scope: any)
    if not Container[Scope] then
        Container[Scope] = {}
    end
    return Container[Scope]
end

--[[
    CreateInstance(Scope, Prototype, ResetProps)
    
    Получить объект из кеша или создать клон.
    Если объект из кеша, сбросить указанные свойства до значений прототипа.
    
    Args:
        Scope: string - идентификатор scope (например 'ParryCast', 'Explosion')
        Prototype: Instance - прототип для клонирования
        ResetProps: {string}? - свойства для сброса (например {'Transparency', 'Size'})
    
    Returns:
        Instance - готовый к использованию объект
]]
function CacheContainer.CreateInstance(self: ICache, Scope: any, Prototype: Instance, ResetProps: ResetProps): Instance
    local instance = self:GetInstance(Scope)
    
    if not instance then
        -- Если кеш пуст - создать новый клон
        instance = Prototype:Clone()
    elseif ResetProps then
        -- Если есть свойства для сброса - восстановить их
        self:_ResetInstanceProperties(instance, Prototype, ResetProps)
    end
    
    return instance
end

--[[
    Сбросить свойства экземпляра и всех его потомков до значений прототипа
]]
function CacheContainer._ResetInstanceProperties(self: ICache, Instance: Instance, Prototype: Instance, ResetProps: ResetProps)
    for _, prop in ipairs(ResetProps) do
        pcall(function()
            Instance[prop] = Prototype[prop]
        end)
    end
    
    for _, child in ipairs(Instance:GetDescendants()) do
        local prototypeChild = Prototype:FindFirstChild(child.Name)
        
        if prototypeChild then
            for _, prop in ipairs(ResetProps) do
                pcall(function()
                    child[prop] = prototypeChild[prop]
                end)
            end
        end
    end
end

--[[
    AddInstanceToCache(Scope, Object)
    
    Вернуть объект в кеш для переиспользования.
    Отсоединяет объект от родителя.
    
    Args:
        Scope: string - идентификатор scope
        Object: Instance - объект для добавления в кеш
]]
function CacheContainer.AddInstanceToCache(self: ICache, Scope: any, Object: Instance)
    local scope = self:GetScope(Scope)
    Object.Parent = nil
    table.insert(scope, Object)
end

--[[
    GetInstance(Scope)
    
    Получить объект из кеша (вытащить и удалить из таблицы).
    
    Args:
        Scope: string - идентификатор scope
    
    Returns:
        Instance? - объект или nil если кеш пуст
]]
function CacheContainer.GetInstance(self: ICache, Scope: any): Instance?
    local scope = self:GetScope(Scope)
    
    if #scope < 1 then
        return nil
    end
    
    return table.remove(scope)
end

--[[
    ClearScope(Scope)
    
    Очистить все объекты в конкретном scope и уничтожить их.
    
    Args:
        Scope: string - идентификатор scope для очистки
]]
function CacheContainer.ClearScope(self: ICache, Scope: any)
    local scope = Container[Scope]
    
    if scope then
        for _, obj in ipairs(scope) do
            obj:Destroy()
        end
        Container[Scope] = nil
    end
end

--[[
    ClearAll()
    
    Очистить все объекты во всех scopes и уничтожить их.
]]
function CacheContainer.ClearAll(self: ICache)
    for scope in pairs(Container) do
        self:ClearScope(scope)
    end
end

--[[
    GetScopeSize(Scope)
    
    Получить количество объектов в кеше для конкретного scope.
    
    Args:
        Scope: string - идентификатор scope
    
    Returns:
        number - количество объектов в кеше
]]
function CacheContainer.GetScopeSize(self: ICache, Scope: any): number
    return #self:GetScope(Scope)
end

--[[
    PreAllocate(Scope, Prototype, Count, ResetProps)
    
    Предварительно создать несколько клонов и добавить их в кеш.
    Полезно для эффектов, которые создаются часто.
    
    Args:
        Scope: string - идентификатор scope
        Prototype: Instance - прототип для клонирования
        Count: number - количество клонов для создания
        ResetProps: {string}? - свойства для сброса
]]
function CacheContainer.PreAllocate(self: ICache, Scope: any, Prototype: Instance, Count: number, ResetProps: ResetProps)
    for _ = 1, Count do
        local clone = Prototype:Clone()
        
        if ResetProps then
            self:_ResetInstanceProperties(clone, Prototype, ResetProps)
        end
        
        self:AddInstanceToCache(Scope, clone)
    end
end

--[[
    GetAllScopes()
    
    Получить список всех активных scopes.
    Полезно для отладки.
    
    Returns:
        {string} - список идентификаторов scopes
]]
function CacheContainer.GetAllScopes(self: ICache): {string}
    local scopes = {}
    for scope in pairs(Container) do
        table.insert(scopes, scope)
    end
    return scopes
end

--[[
    PrintDebugInfo()
    
    Вывести информацию об всех scopes и количестве объектов в кеше.
    Для отладки и мониторинга.
]]
function CacheContainer.PrintDebugInfo(self: ICache)
    print("=== CacheContainer Debug Info ===")
    
    local scopes = self:GetAllScopes()
    
    if #scopes == 0 then
        print("No active scopes")
        return
    end
    
    for _, scope in ipairs(scopes) do
        local size = self:GetScopeSize(scope)
        print(`Scope: '{scope}' | Cached Objects: {size}`)
    end
    
    print("=================================")
end

return CacheContainer
