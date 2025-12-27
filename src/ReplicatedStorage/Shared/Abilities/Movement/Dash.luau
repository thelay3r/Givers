local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Bricks = ReplicatedStorage.Bricksv2

local _Components = Bricks:WaitForChild('Components')
local Data = Bricks:WaitForChild('Data')
local _Registries = Data:WaitForChild('Registries')
local AssetsHelper = require(ReplicatedStorage.Shared.Utilities.Modules.AssetsHelper)
local Registry = require(_Components.Registry)

local registry = Registry.new()



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
                Name = 'Ability.SetAbilityActive';
                Config = 
                {
                    ['Status'] = true;
                };

                {
                    Name = 'Ability.AbilityDuration';
                    RequestedTags = {['Main'] = 'Main'};
                    Config = {};
                };

                {
                Name = 'Action.GetDashDirection';
                Tag = 'DashDirection';
                RequestedTags = {['Owner'] = 'Owner'};
            };
            {
                Name = 'Ability.SetCoolDown';
            };
            {
                Name = 'NetWork.PlayVFX';
                SendParams = {
                    ['DashConfig'] = {From = 'DashDirection'};
                    ['Player'] = {From = 'Owner', Path = {'Instance'}}
                };
                Config = 
                {
                    VFXType = 'Animations.Dash';
                    Client = true;
                    EventData = {
                        State = 'Start';
                        Pack = 'Default';
                    };
                };
            };
            {
                Name = 'NetWork.PlayVFX';
                SendParams = {
                    ['Player'] = {From = 'Owner', Path = {'Instance'}}
                };
                Config = 
                {
                    VFXType = 'Dash.Normal';
                    Client = true;
                    EventData = {
                        State = 'Start';
                        Pack = 'Movement';

                    };
                }
            };
            {
                Name = 'NetWork.PlayVFX';
                SendParams = {
                    ['Player'] = {From = 'Owner', Path = {'Instance'}}
                };
                Config = 
                {
                    VFXType = 'Effects.Trail';
                    Client = true;
                    EventData = {
                        State = 'Start';
                        Pack = 'Movement';
                        
                        AbilityName = 'Dash';
                        LifeTime = .5;
                        Parent = 'Right Arm';
                    };
                }
            };
            {
                Name = 'NetWork.PlayVFX';
                SendParams = {
                    ['Player'] = {From = 'Owner', Path = {'Instance'}}
                };
                Config = 
                {
                    VFXType = 'Effects.Trail';
                    Client = true;
                    EventData = {
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
                SendParams = {
                    ['DashConfig'] = {From = 'DashDirection'};
                    ['Parent'] = {From = 'Owner', Path = {'Instance','Character','HumanoidRootPart'}}
                };
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
                Name = 'NetWork.Feint';
            }
            };
        };
        {
            Name = 'Event.OnStop';
            Tag = 'OnStop';
            {
                Name = 'Condition.IsActive?';
                RequestedTags = {['Ability'] = 'Main'};
                {
                    Name = 'Ability.SetAbilityActive';
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
                Name = 'NetWork.UnBindFeint';
            };
        }
    }
}

return 
{
    Ability = ability;
    Registry = registry;
}