local StarterGui = game:GetService('StarterGui')
local RunService = game:GetService('RunService')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Shared = ReplicatedStorage:WaitForChild('Shared')
local Components = Shared:WaitForChild('Components')
local LocalPlayerComponent = require(Components:WaitForChild('LocalPlayerComponent'))

local function ChangeHealthBar(Player, mainUI: typeof(StarterGui.New))
	local ClientData = Player.ClientData
	local CharacterData = ClientData.CharacterData
	local Character = CharacterData.Character
	local Humanoid = CharacterData.Humanoid
	
	local MainFrame = mainUI.MainFrame
	local HealthFrame = MainFrame.Health
	local Line = HealthFrame.Line
	
	local Divided = Humanoid.Health / Humanoid.MaxHealth
	
	print(Divided)
	
	if Divided > 0.04 then
		Line["right arrow"].Position = UDim2.new(Divided - 0.062, 0, 0, 0)
	else
		Line["right arrow"].Position = UDim2.new(-0.014, 0, 0, 0)
	end
	
	if Humanoid.Health > 0 then
		
		Line["hp line"].UIGradient.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(Divided - 0.001, 0),
			NumberSequenceKeypoint.new(Divided - 0.001, 1),
			NumberSequenceKeypoint.new(1, 1),
		})
		
	else
		Line["hp line"].UIGradient.Transparency = NumberSequence.new(1)
	end
	
end

local function Setup(mainUI: typeof(StarterGui.New))
	local Player = LocalPlayerComponent:GetPlayer()
	
	repeat
		Player = LocalPlayerComponent:GetPlayer()
		task.wait(0.5)
	until (Player) and (Player.ClientData)
	
	local ClientData = Player.ClientData
	local CharacterData = ClientData.CharacterData
	local Character = CharacterData.Character
	local Humanoid = CharacterData.Humanoid
	
	Humanoid.HealthChanged:Connect(function()
		ChangeHealthBar(Player, mainUI)
	end)
	
end

return function (UI: typeof(StarterGui.New))
	local mainUI = UI
	Setup(mainUI)
end