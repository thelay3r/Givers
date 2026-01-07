local TweenService = game:GetService('TweenService')
local ReplicatedStorage = game:GetService('ReplicatedStorage')

local Shared = ReplicatedStorage:WaitForChild('Shared')
local Utilities = Shared:WaitForChild('Utilities')
local UtilModules = Utilities:WaitForChild('Modules')

local Fusion = require(UtilModules:WaitForChild('Fusion'))

local Prototypes = script.Parent
local Components = Prototypes.Parent

local UIButtonComponent = require(Components:WaitForChild('UIButtonComponent'))
local scoped = Fusion.scoped

local Styles = require(script.Styles)

local Button = {}

function Button.new(guiButton: GuiButton, styleName: string?)
	local self, isRegistered = UIButtonComponent.new(guiButton)
	if (isRegistered) then return self end
	
	local styleData = Styles['Default']
	if (styleName and Styles[styleName]) then styleData = Styles[styleName] end

	local scope = scoped(Fusion)
	local scaleValue = scope:Value(1)
	
	local scaleAnimated = scope:Spring(scaleValue, styleData.Speed, .25)
	local scaleObserver = scope:Observer(scaleAnimated)
	
	local UIScale = guiButton.Background.UIScale
	
	scaleObserver:onBind(function()
		local value = Fusion.peek(scaleAnimated)
		UIScale.Scale = value
	end)

	self:BindToEnter(function()
		scaleValue:set(styleData.OnEnterScale)
	end)

	self:BindToLeave(function()
		scaleValue:set(styleData.OnLeaveScale)
	end)

	self:BindToClick(function()
		scaleAnimated:addVelocity(styleData.Velocity)
	end)
	
	return self
end

return Button