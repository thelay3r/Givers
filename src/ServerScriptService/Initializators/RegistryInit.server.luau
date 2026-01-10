local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BricksV2 = ReplicatedStorage:WaitForChild('Bricksv2')
local Data = BricksV2:FindFirstChild('Data')
local Registries = Data:FindFirstChild('Registries'):WaitForChild('BehaviorRegistries')
local RegistryManager = require(ReplicatedStorage.Bricksv2.Components.RegistryManager)


RegistryManager:LoadRegistries(Registries)
RegistryManager:InjectRegistries()