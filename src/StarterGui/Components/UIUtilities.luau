-- // rename to GuiUtilities

local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService('ReplicatedStorage')

local BiezeModule = require(ReplicatedStorage.Modules.Physics.BiezeModule)
local TaskManager = require(ReplicatedStorage.Modules.Utilities.TaskManager)

local camera = workspace.CurrentCamera

local Utilities = {}

function Utilities:BarTransparencyGradient(frame: Frame, time: number)
	local uiGradient = frame:FindFirstChildOfClass('UIGradient')
	if (not uiGradient) then
		uiGradient = Instance.new('UIGradient')
		uiGradient.Parent = frame
	end

	uiGradient.Transparency = NumberSequence.new{
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(math.max(0, time-1/100), 0),
		NumberSequenceKeypoint.new(time, 1),
		NumberSequenceKeypoint.new(1, 1),
	}

	uiGradient:SetAttribute('BarValue', time)
end

function Utilities:TweenBarTransparencyGradient(frame: Frame, time: number, tweenTime: number)
	local uiGradient = frame:FindFirstChildOfClass('UIGradient')
	if (not uiGradient) then
		uiGradient = Instance.new('UIGradient')
		uiGradient.Parent = frame
		uiGradient:SetAttribute('BarValue', 0)
	end

	local currentTime = uiGradient:GetAttribute('BarValue') or 1 :: number

	TaskManager:CreateTask(frame, 'BarTransparency', 0, function()
		for i = 0, tweenTime, 1/60 do
			self:BarTransparencyGradient(frame, BiezeModule.lerp(currentTime, time, i / tweenTime))
			RunService.Heartbeat:Wait()
		end
	end)
end

return Utilities