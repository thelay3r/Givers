local RunService = game:GetService('RunService')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Shared = ReplicatedStorage:WaitForChild('Shared')
local Interfaces = Shared:WaitForChild('Interfaces')
local Utitlites = Shared:WaitForChild('Utilities')
local NetWork = Utitlites:WaitForChild('NetWork')
local StarterGui = game:GetService('StarterGui')

local Modules = Utitlites:WaitForChild('Modules')
local Icon = require(Modules:WaitForChild('Icon'))


local mainUI: typeof(StarterGui.Interface);


local Controller = {}

local function SetupIcons()
	
	Icon.new()
		:align("Right")
		:setLabel("Points")
		:setWidth(80)
		:call(function(pointsIcon)
			local NumberSpinner = require(ReplicatedStorage.NumberSpinner)
			local numberSpinner = NumberSpinner.new()
			pointsIcon:convertLabelToNumberSpinner(numberSpinner, function()
				numberSpinner.Name = "LabelSpinner"
				numberSpinner.Prefix = "$"
				numberSpinner.Commas = true
				numberSpinner.Decimals = 0
				numberSpinner.Duration = 0.25
				while true do
					numberSpinner.Value = math.random(1,100011)
					task.wait(1)
				end
			end)
		end)

end


return function(UI)
	SetupIcons()
end