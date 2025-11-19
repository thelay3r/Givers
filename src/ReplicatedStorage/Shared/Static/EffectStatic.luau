local Players : Players = game:GetService('Players')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local SoundService = game:GetService('SoundService')

local module = {}

module['Test'] = function()
	print('Test')
end

module['PlayInterfaceSound'] = function(Scope : string, Name : string)
	
	local Sound : Sound = SoundService[Scope][Name]:Clone()
	
	Sound.RollOffMinDistance = 0
	Sound.RollOffMaxDistance = math.huge
	Sound.Parent = SoundService.PlayableSounds
	Sound:Play()
	Sound.Ended:Once(function() Sound:Destroy() end)
	
end

return module
