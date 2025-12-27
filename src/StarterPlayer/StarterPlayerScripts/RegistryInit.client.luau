local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BricksV2 = ReplicatedStorage:WaitForChild('Bricksv2')
local Data = BricksV2:FindFirstChild('Data')
local Registries = Data:FindFirstChild('Registries'):WaitForChild('BehaviorRegistries')
local RegistryManager = require(ReplicatedStorage.Bricksv2.Components.RegistryManager)
local Abilities = ReplicatedStorage:WaitForChild('Shared'):WaitForChild('Abilities')


RegistryManager:LoadRegistries(Registries)
RegistryManager:LoadRegistries(Abilities)
RegistryManager:InjectRegistries()