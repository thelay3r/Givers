local Registries = {} :: {[string]: any}

local RegistryManager = {}

function RegistryManager:LoadRegistries(registries: Folder & { [number]: any })
    if typeof(registries) == "ModuleScript" then
        local Registry = require(registries :: any)
        Registries[registries.Name] = Registry
        return
    end

    if typeof(registries) ~= "Instance" or not registries:IsA("Folder") then return end
    for _, v in pairs(registries:GetDescendants()) do
        if not v:IsA("ModuleScript") then continue end
        local Registry = require(v)
        if Registry['Registry'] then
            Registry = Registry['Registry']['callbacks']
        end
        Registries[v.Name] = Registry
    end
end

function RegistryManager:InjectRegistry(registry)
    if not registry['Inject'] then return end
    local Registry = {}

    for i2, v2 in (registry['Inject']) do
        if Registries[v2] then table.insert(Registry, Registries[v2]) end
    end
    registry:Extends(Registry)
end

function RegistryManager:InjectRegistries()
    for i, v in pairs(Registries) do
        if v['Registry'] then
            v = v['Registry']
        end
        if not v['Inject'] then continue end
        local Registry = {}
        for i2, v2 in (v['Inject']) do
            if Registries[v2] then table.insert(Registry, Registries[v2]) end
        end
        v:Extends(Registry)
    end
end

return RegistryManager
