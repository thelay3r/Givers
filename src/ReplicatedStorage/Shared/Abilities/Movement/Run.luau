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
                RequestedTags = {['Owner'] = 'Owner'};
                Config = {
                    Name = 'Run';
                    Side = 'Client';
                    State = 'Start';
                    Pack = 'Movement';
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
            }
        }
    }
}