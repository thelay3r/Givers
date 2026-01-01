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
	
	local DefaultPosition = UDim2.fromScale(.5,3)
	local GoalPosition = UDim2.fromScale(.5,.5)
	
	local style = TweenInfo.new(.25, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
    local scope = scoped(Fusion) :: typeof(Fusion)
  
	local tweenValue = scope:Value(0)
	local tweenAnimation = scope:Tween(tweenValue, style)

    local PositionValue = scope:Value(UDim2.new(.5, 3))
    local SpringPosition = scope:Spring(PositionValue,5,.5)

	local loadFrame: Frame;

	local PositionObserver = scope:Observer(SpringPosition)
	PositionObserver:onBind(function()
		local value = Fusion.peek(SpringPosition)
		local currentValue = Fusion.peek(tweenAnimation)

		frame.Position = value
		loadFrame.Size = UDim2.new(1, currentValue)
		-- set tween for load frame
		print(value)
	end)

	self:BindToOpen(function()
		PositionValue:set(UDim2.fromScale(.5, .5))
		loadFrame.Size = UDim2.new(0, 0)
		-- set load frame's scale to 0
		tweenValue:set(1)
	end)

	self:BindToClose(function()
		PositionValue:set(UDim2.fromScale(.5, 3))
	end)

	return self
end

return Frame
