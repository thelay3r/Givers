local TweenService = game:GetService('TweenService')
local ReplicatedStorage = game:GetService('ReplicatedStorage')

local Fusion = require(ReplicatedStorage:WaitForChild('Fusion'))

local Prototypes = script.Parent
local Components = Prototypes.Parent

local UIFrameComponent = require(Components:WaitForChild('UIFrameComponent'))
local scoped = Fusion.scoped

local Frame = {}

function Frame.new(frame: Frame)
	local self, isRegistered = UIFrameComponent.new(frame)
	if (isRegistered) then return self end
	
	local style = TweenInfo.new(.25, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
	local scope = scoped(Fusion)
	
	local scaleValue = scope:Value(1)
	local strokeValue = scope:Value(1)

	local GoalSize = scope:Value(UDim2.fromScale(.4,.4))

	local strokeAnimated = scope:Tween(strokeValue, style)
	--local scaleAnimated2 = scope:Spring(scaleValue, 15, 1)
	local scaleAnimated2 = scope:Tween(GoalSize, style)

	local strokeObserver = scope:Observer(strokeAnimated)
	local scaleObserver = scope:Observer(scaleAnimated2)
	
	scaleObserver:onBind(function()
		local value = Fusion.peek(scaleAnimated2)
		frame.Size = value
	end)
	
	self:BindToClose(function()
		GoalSize:set(UDim2.fromScale(0,.568))
		task.wait(style.Time)
		frame.Visible = false
	end)
	
	self:BindToOpen(function()
		frame.Visible = true
		GoalSize:set(UDim2.fromScale(.48,.568))
	end)
	
	self:Close()
	
	return self
end

return Frame
