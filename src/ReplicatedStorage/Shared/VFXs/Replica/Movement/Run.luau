local ReplicatedStorage = game:GetService('ReplicatedStorage')
local RunService = game:GetService('RunService')
local change = require(ReplicatedStorage.Shared.Utilities.Modules.Fusion.Graph.change)

local Shared = ReplicatedStorage:WaitForChild('Shared')
local Utilities = Shared:WaitForChild('Utilities')
local UtilModules = Utilities:WaitForChild('Modules')
local VFXs = Shared:WaitForChild('VFXs')

local Animations = VFXs:WaitForChild('Assets'):WaitForChild('Movement'):WaitForChild('Dash'):WaitForChild('Animations')



local Run = {}
Run['Server'] = {}
Run['Client'] = {}

Run['Client']['Start'] = function(Character)

    print(Character)

end

return Run
