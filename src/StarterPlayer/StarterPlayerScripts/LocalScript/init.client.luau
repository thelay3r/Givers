-- // Services
--local replicatedStorage = game:GetService("ReplicatedStorage")
--local playersService = game:GetService("Players")

local Player = game.Players.LocalPlayer

-- // Variables
local footstepsModule = require(script.FootstepsModule)

-- // Functions
local function checkSpeed(humanoid)

	local walkSpeed = humanoid.WalkSpeed
	local moveDirection = humanoid.MoveDirection.Magnitude
	local floorMaterial = humanoid.FloorMaterial

	if walkSpeed > 0 and moveDirection > 0 and floorMaterial ~= Enum.Material.Air then
		return true
	end

	return false
end

local function getMaterial(material)
	local soundTable = footstepsModule:GetTableFromMaterial(material)

	if soundTable then
		local randomSound = footstepsModule:GetRandomSound(soundTable)

		if randomSound then
			return randomSound
		end
	end

	return nil
end

local function shootRay(rayOrigin, rayDirection, raycastParams)

	local raycastResult = workspace:Raycast(rayOrigin, rayDirection, raycastParams)

	if raycastResult then
		return raycastResult.Material
	end

	return nil
end

local function createFootstep(sound, character, rootPart)

	local hum = character:WaitForChild("Humanoid")

	local rayOrigin = rootPart.Position
	local rayDirection = Vector3.new(0, -5, 0)

	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.IgnoreWater = false
	raycastParams.FilterDescendantsInstances = {character}

	local raycastResult = shootRay(rayOrigin, rayDirection, raycastParams)

	if raycastResult ~= nil then
		local newSound = getMaterial(raycastResult)
		sound.SoundId = newSound

		local newFootstep = sound:Clone()
		newFootstep.Name = "Footstep"
		newFootstep.Volume = 0.5
		newFootstep.PlaybackSpeed = math.random(9, 11) / 10

		newFootstep.Parent = rootPart

		newFootstep:Play()
		newFootstep.Ended:Connect(function()

			newFootstep:Destroy()
		end)
	end

end

Player.CharacterAdded:Connect(function(character)

		local humanoid = character:FindFirstChild("Humanoid")
		local rootPart = character:FindFirstChild("HumanoidRootPart")
		local RunSound : Sound = rootPart:WaitForChild("Running")
		RunSound.SoundId = ""
		
		local cooldown = 0

		-- Sound creation
		local footstepsSound = Instance.new("Sound")
		footstepsSound.Name = "FootstepTemplate"
		footstepsSound.Volume = 0.1

		footstepsSound.RollOffMode = Enum.RollOffMode.InverseTapered
		footstepsSound.RollOffMaxDistance = 40
		footstepsSound.RollOffMinDistance = 5

		task.spawn(function()
			while true do
				if humanoid.WalkSpeed >= 20 then
					footstepsSound.PlaybackSpeed = 1.15
					cooldown = 0.4
				elseif humanoid.WalkSpeed == 12 then
					footstepsSound.PlaybackSpeed = 0.9
					cooldown = 0.55
				elseif humanoid.WalkSpeed <= 5 then
					footstepsSound.PlaybackSpeed = 0.85
					cooldown = 1
				end

				task.wait(1/60)
			end
		end)

		footstepsSound.Parent = rootPart

		-- Main loop
	while humanoid.Health > 0 do
		task.wait(.35)

		if checkSpeed(humanoid) then
			createFootstep(footstepsSound, character, rootPart)
		end
	end
end)	
