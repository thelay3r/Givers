local RockCreater = {}

function RockCreater.New(Part: Part, Parent, CustomCillsion: boolean)
	local NewPart: Part = Part:Clone()
	
	NewPart.Size = Vector3.zero
	NewPart.Name = "Rock"
	NewPart.Massless = true
	NewPart.CanQuery = false
	NewPart.CanTouch = false
	NewPart.Anchored = false
	
	if CustomCillsion then
		NewPart.CollisionGroup = 'Rocks'
	end
	
	NewPart:AddTag("IgnoreCamera")
	NewPart:AddTag("Rock")
	NewPart.Parent = Parent or workspace.Map.VFXs
	
	return NewPart
end

return RockCreater
