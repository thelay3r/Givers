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
            RequestedTags = {['Player'] = 'Player'};

            {
                Name = 'Action.AcceleratMoveSpeed';
                RequestedTags = {['Player'] = 'Player',['Config'] = 'Main'};
                Conifg = 
                {
                    Acceleration = 2;
                    BaseSpeed = 16;
                    AccelerationTime = 0.25;
                }
            }
        }
    }
}