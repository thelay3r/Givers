return 
{
    Name = 'Action.Root';
    Tag = 'Main';
    Config = 
    {
        Name = 'Run';
        KeyCode = Enum.KeyCode.W;
        CoolDown = .1;
        IsActive = false;
    };


    {
        Name = 'Event.OnStart';
        Tag = 'OnStart';
        {
            Name = 'Condition.CheckBlackList';
            RequestedTags = {['Owner'] = 'Owner'};

            {
                Name = 'Action.AcceleratMoveSpeed';
                Tag = 'AcceleratMoveSpeed';
                RequestedTags = {['Owner'] = 'Owner',['Config'] = 'Main'};
                Config = 
                {
                    Acceleration = 2;
                    BaseSpeed = 12;
                    AccelerationTime = .4;
                    Name = 'RunSpeedBoost';
                }
            };

            {
                Name = 'Action.PlayVFX';
                SendParams = {['Player'] = {From = 'Owner', Path = {'Instance'}}};
                Config = {
                    VFXType = 'Camera.ChangeFOV';
                    Client = true;
                    VfxCFG = {
                        Time = .8;
                        FOV = 85;
                        EasingStyle = Enum.EasingStyle.Sine;
                        EasingDirection = Enum.EasingDirection.InOut;
                    };
                    
                }
            }
        }
    };

    {
        Name = 'Event.OnStop';
        Tag = 'OnStop';
        {
            Name = 'Condition.CheckBlackList';
            RequestedTags = {['Owner'] = 'Owner'};

            {
                Name = 'Action.DeAcceleratMoveSpeed';
                RequestedTags = {['Owner'] = 'Owner',['Config'] = 'AcceleratMoveSpeed'};
            };
            {
                Name = 'Action.PlayVFX';
                SendParams = {['Player'] = {From = 'Owner', Path = {'Instance'}}};
                Config = {
                    VFXType = 'Camera.ChangeFOV';
                    Client = true;
                    VfxCFG = {
                        Time = .5;
                        FOV = 70;
                        EasingStyle = Enum.EasingStyle.Sine;
                        EasingDirection = Enum.EasingDirection.InOut;
                    };
                    
                }
            }
        }
    }
}