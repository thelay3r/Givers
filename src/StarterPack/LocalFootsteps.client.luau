--!strict
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")

local FootstepFolder = script:WaitForChild("FootstepSounds")
FootstepFolder.Parent = SoundService
local FootstepSounds = FootstepFolder

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid") :: Humanoid

local BASE_WALKSPEED = 7
local WALK_THRESHOLD = 0.5

local isWalking = false
local lastMaterial: string? = nil

humanoid.Running:Connect(function(speed: number)
	isWalking = speed > humanoid.WalkSpeed * WALK_THRESHOLD
end)

local function getCurrentMaterial(): string
	local floorMaterial = humanoid.FloorMaterial
	if not floorMaterial then
		return "Air"
	end
	local name = tostring(floorMaterial)
	local parts = string.split(name, ".")
	return parts[#parts] or "Air"
end

RunService.Heartbeat:Connect(function()
	
	local HumanoidWalkSpeed = humanoid.WalkSpeed
	
	if not isWalking then
		for _, sound in ipairs(FootstepSounds:GetChildren()) do
			if sound:IsA("Sound") then
				sound.Playing = false
			end
		end
		lastMaterial = nil
		return
	end

	local currentMaterial = getCurrentMaterial()

	
	if lastMaterial then
		
		local sound: Sound = FootstepSounds:FindFirstChild(currentMaterial)
		local lastSound: Sound = FootstepSounds:FindFirstChild((lastMaterial or currentMaterial))
		sound.PlaybackSpeed = math.clamp(HumanoidWalkSpeed / BASE_WALKSPEED / 2, 0, 1.4)

		if (sound.SoundId == lastSound.SoundId) and lastSound.Playing then return end

		lastSound.Playing = false

		if sound and sound:IsA("Sound") then
			sound.Playing = true
		end

	end
	

	
	lastMaterial = currentMaterial
end)
