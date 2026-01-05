local ReplicatedStorage = game:GetService("ReplicatedStorage")

local StarterGui = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")

local UIUtilities = require(StarterGui.Components.UIUtilities)
local LocalPlayerInterfaces = require(ReplicatedStorage.Shared.Interfaces.LocalPlayerInterfaces)

type PlayerComponent = LocalPlayerInterfaces.IClientPlayerComponent

local mainUI: typeof(StarterGui.MainUI);
local playerComponent: PlayerComponent;

local function changeHealthBar()
    local hud = mainUI.UI.HUD
    local healthHUD = hud.HealthBar
    local container = healthHUD.container
    local healthbar = container.bar

    if (not healthbar) then return end

    local character = playerComponent.ClientData.CharacterData.Character
    if (not character) then return end

    local humanoid = character.Humanoid :: Humanoid
    if (not humanoid) then return end

    local health = humanoid.Health
    local maxHealth = humanoid.MaxHealth
    local healthPercent = health / maxHealth

    UIUtilities:TweenBarTransparencyGradient(healthbar, healthPercent, .5)
    --healthbar.Position = UDim2.fromScale(healthPercent-1, .5)
end

local function changePosturehBar()
    local hud = mainUI.UI.HUD
    local postureHUD = hud.PostureBar

    local leftContainer = postureHUD.leftContainer
    local rightContainer = postureHUD.rightContainer

    local leftBar = leftContainer.bar
    local rightBar = rightContainer.bar

    if (not leftBar) then return end
    if (not rightBar) then return end

    local character = playerComponent.ClientData.CharacterData.Character
    if (not character) then return end

    local humanoid = character.Humanoid :: Humanoid
    if (not humanoid) then return end

    local posture = playerComponent.Replica.Data.SessionData.Attributes.Posture :: number
    local maxPosture = playerComponent.Replica.Data.SessionData.Attributes.MaxPosture :: number
    local posturePercent = posture / maxPosture

    TweenService:Create(leftBar, TweenInfo.new(.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.fromScale(1-posturePercent, 0)}):Play()
    TweenService:Create(rightBar, TweenInfo.new(.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.fromScale(posturePercent-1, 0)}):Play()
end

return function(UI: typeof(StarterGui.MainUI), component: PlayerComponent)
	mainUI = UI
    playerComponent = component

    changeHealthBar()
    changePosturehBar()

    warn('-- HUD Initialized --')

    component.Buses.Character:Subscribe("OnHealthChanged", function()
        changeHealthBar()
    end)

    component.Replica:OnChange('SessionData.Attributes.Posture', function()
        changePosturehBar()
    end)
end
