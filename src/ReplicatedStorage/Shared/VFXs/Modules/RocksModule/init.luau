
local LoadedComponents = {}

for i, Component in pairs(script:GetChildren()) do
	LoadedComponents[Component.Name] = require(Component)
end

local RocksModule = {}

function RocksModule.New(Preset, args)
	LoadedComponents[Preset]:Start(args)
end

return RocksModule
