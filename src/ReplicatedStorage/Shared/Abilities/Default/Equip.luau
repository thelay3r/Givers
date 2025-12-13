return 
{
    Name = 'Action.Root';
    Tag = 'Main';
    Config = 
    {
        Name = 'Equip';
        KeyCode = Enum.KeyCode.E;
        CoolDown = .5;
        IsActive = false;
        Duration = .65;
    };
    {
        Name = 'Event.OnStart';
        Tag = 'OnStart';
        {
            Name = 'Condition.CheckBlackList';

            {
                Name = 'Action.ChangeWeapon';
                
            }
        };


    };
    
}