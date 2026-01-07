local TweenService = game:GetService('TweenService')
local ReplicatedStorage = game:GetService('ReplicatedStorage')

local Fusion = require(ReplicatedStorage:WaitForChild('Fusion'))

local Prototypes = script.Parent
local Components = Prototypes.Parent

local UIFrameComponent = require(Components:WaitForChild('UIFrameComponent'))
local scoped = Fusion.scoped

local Styles = require(script.Styles)

local Frame = {}

function Frame.new(frame: Frame, styleName: string?)
	local self, isRegistered = UIFrameComponent.new(frame)
	if (isRegistered) then return self end
	
	local styleData = Styles['Default']
	if (styleName and Styles[styleName]) then styleData = Styles[styleName] end

	local style = TweenInfo.new(1/styleData.Speed, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
	local scope = scoped(Fusion)

	local GoalSize = scope:Value(UDim2.fromScale(1,1))
	local scaleAnimated2 = scope:Spring(GoalSize, 15, .75)
	--local scaleAnimated2 = scope:Tween(GoalSize, style)
	local scaleObserver = scope:Observer(scaleAnimated2)
	
	scaleObserver:onBind(function()
		local value = Fusion.peek(scaleAnimated2)
		frame.Position = value
	end)
	
	self:BindToClose(function()
		GoalSize:set(styleData.ClosePosition)
		task.wait(style.Time)
		if (styleData.IgnoreVisible) then return end
		frame.Visible = false
	end)
	
	self:BindToOpen(function()
		frame.Visible = true
		GoalSize:set(styleData.OpenPosition)
	end)
	
	self:Close()
	
	return self
end

return Frame
