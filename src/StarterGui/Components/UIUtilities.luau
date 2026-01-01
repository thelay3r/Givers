-- // rename to GuiUtilities

local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local BezierCurves = require(ReplicatedStorage.Utilities.BezierCurves)
local NumberFormatter = require(ReplicatedStorage.Utilities.NumberFormatter)

local camera = workspace.CurrentCamera

local Utilities = {}

function Utilities:AutoScaleStroke(object: GuiObject)
    for _, object: Instance in pairs(object:GetDescendants()) do
        if (not object:IsA('UIStroke')) then continue end

        local defaultThickness = object.Thickness
        local scaleFactor = camera.ViewportSize.X / 1920

        object.Thickness = defaultThickness * scaleFactor
    end
end

function Utilities:AutoScale(parent: GuiObject)
    for _, object: any in pairs(parent:GetDescendants()) do
        local size = nil :: UDim2?

        pcall(function() --! seems off
			size = object['Size']
		end)

        if (not size) then continue end

        local originSize = ReplicatedStorage:GetAttribute('Size') :: UDim2?
        if (not originSize) then originSize = UDim2.fromOffset(1920, 1080) end

        local scaleFactorX = camera.ViewportSize.X / originSize.X.Offset
        local scaleFactorY = camera.ViewportSize.X / originSize.X.Offset

        if (size.X.Offset + size.Y.Offset < 10) then continue end --! find a better way to do it

        object.Size = UDim2.fromOffset(size.X.Offset * scaleFactorX, size.Y.Offset * scaleFactorY) 
    end
end

function Utilities:TypeText(textLabel: TextLabel, targetText: string, speed: number)
	textLabel.Text = targetText
	textLabel.MaxVisibleGraphemes = 0

	local length = utf8.len(targetText) or #targetText

    task.spawn(function()
        for i = 1, length do
            textLabel.MaxVisibleGraphemes = i
            task.wait(speed)
        end
    end)
end

function Utilities:LerpTextNumber(
	textLabel: TextLabel,
	startValue: number,
	endValue: number,
	duration: number,
	prefix: string?
)
	local elapsed = 0
	textLabel.Text = NumberFormatter(startValue)

	if duration <= 0 then
		textLabel.Text = NumberFormatter(endValue)
		return
	end

	local connection
	connection = RunService.Heartbeat:Connect(function(dt)
		elapsed += dt
		local t = math.clamp(elapsed / duration, 0, 1)
		local value = BezierCurves:lerp(startValue, endValue, t)

		textLabel.Text = (prefix or "")..NumberFormatter(value)
		if t >= 1 then
			connection:Disconnect()
		end
	end)
end

return Utilities