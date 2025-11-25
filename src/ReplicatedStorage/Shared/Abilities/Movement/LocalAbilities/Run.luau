return 
{
    Name = 'Action.Root';
    Tag = 'Main';
    Config = 
    {
        Acceleration = 2;
        BaseSpeed = 16;
        AccelerationTime = 0.25;
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
            }
        }
    }
}