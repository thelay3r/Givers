local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Bricks = ReplicatedStorage.Bricksv2

local _Components = Bricks:WaitForChild("Components")
local Data = Bricks:WaitForChild("Data")
local _Registries = Data:WaitForChild("Registries")
local _Replicator = require(ReplicatedStorage.Shared.Utilities.NetWork.Replicator)
local _AssetsHelper = require(ReplicatedStorage.Shared.Utilities.Modules.AssetsHelper)
local _TaskManager = require(ReplicatedStorage.Shared.Utilities.Modules.TaskManager)
local Registry = require(_Components.Registry)


local registry = Registry.new()

registry.Inject = {
	'Slide'
}

local ability = {
	Name = "Action.Root",
	Tag = "Main",
	Config = {
		Name = "Slide",
		KeyCode = Enum.KeyCode.LeftControl,
		CoolDown = 1,
		IsActive = false,
		Duration = 1e10,
		MinDuration = 0,
	},
	{
		Name = "Event.OnStart",
		Tag = "OnStart",
		{
			Name = "Condition.CheckBlackList",
			Config = {
				Ignore = {
					["IsSliding"] = true,
				},
				WhiteList = {
					'Carry'
				}
			},
			{
				Name = "Condition.RayCheck",
				Tag = "SlideCheck",
				Config = {
					Vector = "UpVector",
					Range = -5,
				},
				{
					Name = "Action.SetAbilityActive",
					Config = {
						["Status"] = true,
					},
				},
				{
					Name = "Action.SetStatusEffect",
					Config = {
						["Effect"] = "IsSliding",
						["Status"] = true,
					},
				},
				{
					Name = "Action.SlideStart",
					Tag = "SlideStart",
					RequestedTags = { ["RayResult"] = "SlideCheck" },

					Config = {
						Delta = 1 / 10,
						MaxForce = 35,
						MaxVelocity = 60,

						BaseSpeed = 5,
						MinSpeed = 0,
						MaxSpeed = 256,
						SpeedModifier = 1,

						VerticalDecceleration = 35,
						VerticalAcceleration = 15, --25
						HorizontalDecceleration = 15,
						DefaultSpeed = 5,
					},
				},
				{
					Name = "Action.SlideJump",
					RequestedTags = { ["Slide"] = "SlideStart" },
				},
				{
					Name = "Network.PlayBindableEvent",
					InjectParams = { ["Player"] = "Owner.Instance" },
					Config = {
						EventName = "PlayVFX",
						EventData = {
							VFXType = "Animations.Slide",
							State = "Start",
							Pack = "Default",
						},
					},
				},
				{
					Name = "Network.PlayBindableEvent",
					InjectParams = { ["Player"] = "Owner.Instance" },
					Config = {
						EventName = "PlayVFX",
						EventData = {
							VFXType = "Slide.Client",
							State = "Start",
							Pack = "Default",
						},
					},
				},
			},
		},
	},
		{
			Name = "Event.OnStop",
			Tag = "OnStop",
			{
				Name = "Condition.IsActive?",
				{
					Name = "Condition.DurationElapsed",
					{
						Name = "Action.SetAbilityActive",
						Config = {
							["Status"] = false,
						},
					},
				{
					Name = "Action.SetStatusEffect",
					Config = {
						["Effect"] = "IsSliding",
						["Status"] = false,
					},
				},
				{
					Name = "Action.SlideStop",
				},
				{
					Name = "Action.SetUsed",
				},
				{
					Name = 'Action.UnBindSlideJump',
				},
				{
                    Name = 'Condition.ResumeRun?'
                },
				{
					Name = "Network.PlayBindableEvent",
					InjectParams = { ["Player"] = "Owner.Instance" },
					Config = {
						EventName = "PlayVFX",
						EventData = {
							VFXType = "Animations.Slide",
							State = "Stop",
							Pack = "Default",
						},
					},
				},
				{
					Name = "Network.PlayBindableEvent",
					InjectParams = { ["Player"] = "Owner.Instance" },
					Config = {
						EventName = "PlayVFX",
						EventData = {
							VFXType = "Slide.Client",
							State = "Stop",
							Pack = "Default",
						},
					},
				},
			},
		},
	},
}

return {
	Ability = ability,
	Registry = registry,
}
