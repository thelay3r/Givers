local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Bricks = ReplicatedStorage.Bricksv2

local _Components = Bricks:WaitForChild('Components')
local Data = Bricks:WaitForChild('Data')
local _Registries = Data:WaitForChild('Registries')
local _AssetsHelper = require(ReplicatedStorage.Shared.Utilities.Modules.AssetsHelper)
local Registry = require(_Components.Registry)

local registry = Registry.new()

registry.Inject = {
    'Dash',
}


local ability = {
    Name = 'Action.Root';
    Tag = 'Main';
    Config = 
    {
        Name = 'Dash';
        KeyCode = Enum.KeyCode.Q;
        CoolDown = 1.75;
        IsActive = false;
        Duration = .35;
    };

    {
        Name = 'Event.OnStart';
        Tag = 'OnStart';
        {
            Name = 'Condition.CheckBlackList';
            {
                Name = 'Action.SetAbilityActive';
                Config = 
                {
                    ['Status'] = true;
                };
            };
            {
                Name = 'Action.GetDashDirection';
                Tag = 'DashDirection';
                RequestedTags = {['Owner'] = 'Owner'};
            };
            {
                Name = 'Action.SetUsed';
            };
            {
                Name = 'Network.PlayBindableEvent';
                InjectParams = { ["Player"] = "Owner.Instance", ['DashDirection'] = "DashDirection" },
                Config =   
                {
                    EventName = 'PlayVFX';
                    EventData = {
                        VFXType = 'Animations.Dash';
                        State = 'Start';
                        Pack = 'Default';
                    };
                };
            };
            {
                Name = 'Network.PlayBindableEvent';
                InjectParams = { ["Player"] = "Owner.Instance" },
                Config = 
                {
                    EventName = 'PlayVFX';
                    EventData = {
                        VFXType = 'Dash.Normal';
                        State = 'Start';
                        Pack = 'Movement';

                    };
                }
            };
            {
                Name = 'Network.PlayBindableEvent';
                InjectParams = { ["Player"] = "Owner.Instance" },
                Config = 
                {
                    EventName = 'PlayVFX';
                    EventData = {
                        VFXType = 'Effects.Trail';
                        State = 'Start';
                        Pack = 'Movement';
                        
                        AbilityName = 'Dash';
                        LifeTime = .5;
                        Parent = 'Right Arm';
                    };
                }
            };
            {
                Name = 'Network.PlayBindableEvent';
                InjectParams = { ["Player"] = "Owner.Instance" },
                Config = 
                {
                    EventName = 'PlayVFX';
                    EventData = {
                         VFXType = 'Effects.Trail';
                        State = 'Start';
                        Pack = 'Movement';
                        
                        AbilityName = 'Dash';
                        LifeTime = .5;
                        Parent = 'Left Arm';
                    };
                }
            };
            {
                Name = 'Action.DashBodyVelocity';
                Tag = 'BodyVelocityDash';
                Config = 
                {
                    BodyVelocity = 
                    {
                            P = 15000;
                            MaxForce = Vector3.new(15000,0,15000);
                            Priority = 1;
                            Speed = 50;
                            DestroyTime = .35
                    };
                };
                {
                    Name = 'Action.UnitSmoothVelocity';
                    RequestedTags = {['BodyVelocity'] = 'BodyVelocityDash'};

                    Config = 
                    {
                        SPoint = 1.2;
                        EPoint = 0;
                        FrameRate = 1/60;
                        TotalTime = .35;
                    };
                }
            };
            {
                Name = 'Network.Feint';
            };
        };
        {
            Name = 'Event.OnStop';
            Tag = 'OnStop';
            {
                Name = 'Condition.IsActive?';
                RequestedTags = {['Ability'] = 'Main'};
                {
                    Name = 'Action.SetAbilityActive';
                    Config = 
                    {
                        ['Status'] = false;
                    }
                };
            },
        },
        {
            Name = 'Event.OnDurationEnd';
            Tag = 'OnDurationEnd';
            {
                Name = 'Network.UnBindFeint';
            };
        }
    }
}

return 
{
    Ability = ability;
    Registry = registry;
}