local Registries = {} :: {[string]: any}

local RegistryManager = {}

function RegistryManager.new() end

function RegistryManager:LoadRegistries() end

function RegistryManager:InjectRegistries()
    for i, v in pairs(Registries) do
        if not v['Inject'] then continue end
        local Registry = {}
        for i2, v2 in (v['Inject']) do
            if Registries[v2] then table.insert(Registry, Registries[v2]) end
        end
        v:Extends(Registry)
    end
 end

return RegistryManager
