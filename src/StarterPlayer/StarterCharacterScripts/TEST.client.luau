local Player: Player = game.Players.LocalPlayer
local Character: Model = Player.Character or Player.CharacterAdded:Wait()
local Humanoid: Humanoid = Character:WaitForChild('Humanoid')

Humanoid.Changed:Connect(function(property)
	if property == 'WalkSpeed' then
	end
end)