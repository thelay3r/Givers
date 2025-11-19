task.wait(2)

local Character: Model = script.Parent
for _,v in pairs(Character.PrimaryPart:GetChildren()) do
	if not v:IsA('Sound') then continue end
	v:Destroy()
end