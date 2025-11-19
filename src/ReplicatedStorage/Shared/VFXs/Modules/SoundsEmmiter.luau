local SoundsEmmiter = {}

function SoundsEmmiter:PlaySound(SoundTemplate: Sound, SoundParent: BasePart)
	local Sound: Sound = SoundTemplate:Clone()
	Sound.Parent = SoundParent
	
	Sound:Play()
	
	Sound.Ended:Once(function()
		Sound:Destroy()
	end)
	
	return Sound
	
end

return SoundsEmmiter
