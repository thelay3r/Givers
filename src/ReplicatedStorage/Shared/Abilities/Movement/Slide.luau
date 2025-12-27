local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Bricks = ReplicatedStorage.Bricksv2

local _Components = Bricks:WaitForChild("Components")
local Data = Bricks:WaitForChild("Data")
local _Registries = Data:WaitForChild("Registries")
local Replicator = require(ReplicatedStorage.Shared.Utilities.NetWork.Replicator)
local AssetsHelper = require(ReplicatedStorage.Shared.Utilities.Modules.AssetsHelper)
local TaskManager = require(ReplicatedStorage.Shared.Utilities.Modules.TaskManager)
local Registry = require(_Components.Registry)

local BindableGlobal = Replicator:GetRemote("BindableGlobal")

local registry = Registry.new()

local ability = {
	Name = "Action.Root",
	Tag = "Main",
	Config = {
		Name = "Slide",
		KeyCode = Enum.KeyCode.LeftControl,
		CoolDown = 1,
		IsActive = false,
		Duration = 1e10,
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
					Name = "Abilities.SlideStart",
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
					Name = "Abilities.SlideJump",
					RequestedTags = { ["Slide"] = "SlideStart" },
				},
				{
					Name = "NetWork.PlayVFX",
					Config = {
						VFXType = "Animations.Slide",
						Client = true,
						EventData = {
							State = "Start",
							Pack = "Default",
						},
					},
				},
				{
					Name = "NetWork.PlayVFX",
					Config = {
						VFXType = "Slide.Client",
						Client = true,
						EventData = {
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
			RequestedTags = { ["Ability"] = "Main" },
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
				Name = "Abilities.SlideStop",
			},
			{
				Name = "Action.SetUsed",
			},
			{
				Name = "NetWork.PlayVFX",
				Config = {
					VFXType = "Animations.Slide",
					Client = true,
					EventData = {
						State = "Stop",
						Pack = "Default",
					},
				},
			},
			{
				Name = "NetWork.PlayVFX",
				Config = {
					VFXType = "Slide.Client",
					Client = true,
					EventData = {
						State = "Stop",
						Pack = "Default",
					},
				},
			},
			{
				Name = "Condition.ResumeRun?",
			},
		},
	},
}

return {
	Ability = ability,
	Registry = registry,
}
