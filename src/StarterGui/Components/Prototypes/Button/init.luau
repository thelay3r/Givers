local TweenService = game:GetService('TweenService')
local ReplicatedStorage = game:GetService('ReplicatedStorage')

local Fusion = require(ReplicatedStorage:WaitForChild('Fusion'))

local Prototypes = script.Parent
local Components = Prototypes.Parent
local Static = ReplicatedStorage.Static or ReplicatedStorage:WaitForChild("Static")

local UIButtonComponent = require(Components:WaitForChild('UIButtonComponent'))
local EffectStatic = require(Static.EffectStatic)
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
	
	local scaleAnimated = scope:Spring(scaleValue, styleData.Speed, styleData.Damping)
	local scaleObserver = scope:Observer(scaleAnimated)
	
	local UIScale = guiButton:FindFirstChild('UIScale') --guiButton.Background.UIScale

	if (not UIScale) then 
		local background = guiButton:FindFirstChild('Background')
		if (background) then UIScale = background.UIScale end --* peak (absolute cinema)
		if (not background) then warn(`{guiButton} doenst have a Background with UIScale`) end
	end

	if (not UIScale) then warn(`{guiButton} doenst have a UIScale`); return end

	scaleObserver:onBind(function()
		local value = Fusion.peek(scaleAnimated)
		UIScale.Scale = value
	end)

	self:BindToEnter(function()
		scaleValue:set(styleData.OnEnterScale)
		EffectStatic[styleData.Scope](styleData.HoverSound)
	end)

	self:BindToLeave(function()
		scaleValue:set(styleData.OnLeaveScale)
	end)

	self:BindToDown(function()
		scaleValue:set(styleData.OnDownScale)
	end)

	self:BindToUp(function()
		scaleValue:set(styleData.OnEnterScale)
		--scaleAnimated:addVelocity(styleData.Velocity)
	end)

	--[[
	self:BindToClick(function()
		scaleAnimated:addVelocity(styleData.Velocity)
		EffectStatic[styleData.Scope](styleData.ClickSound)
	end)
	]]
	
	return self
end

return Button