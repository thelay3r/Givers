local ReplicatedStorage = game:GetService('ReplicatedStorage')
local RunService = game:GetService('RunService')

local Shared = ReplicatedStorage:WaitForChild('Shared')
local Utilities = Shared:WaitForChild('Utilities')
local UtilModules = Utilities:WaitForChild('Modules')
local VFXs = Shared:WaitForChild('VFXs')

local SoundsEmmiter = require(VFXs:WaitForChild('Modules'):WaitForChild('SoundsEmmiter'))
local Emit = require(VFXs:WaitForChild('Modules'):WaitForChild('Emit'))
local TaskManager = require(UtilModules:WaitForChild('TaskManager'))

local Vault = {}

	Vault['VaultEffect'] = function(Character: Model)
		
		local Humanoid: Humanoid = Character:FindFirstChildOfClass('Humanoid')
		local HumanoidRootPart: BasePart = Character:FindFirstChild('HumanoidRootPart')
		
		SoundsEmmiter:PlaySound(VFXs.Assets.Movement.Vault.Sounds.Vault, HumanoidRootPart)

	end

return Vault
