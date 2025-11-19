local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Shared = ReplicatedStorage:WaitForChild('Shared')
local VFXs = Shared:WaitForChild('VFXs')
local Assets = VFXs:FindFirstChild('Assets')

local Equip = {}


Equip['OnStart'] = function(Character: Model,WeaponName: string,status: boolean)
	print(Character,WeaponName,status)
end





return Equip
