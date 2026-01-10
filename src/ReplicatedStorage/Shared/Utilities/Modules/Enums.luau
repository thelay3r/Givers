local EventType = {
        Once = {
            Name = 'Once';
            Value = 1;
        };
        Close = {
            Name = 'Close';
            Value = 2;
        };
        All = {
            Name = 'All';
            Value = 3;
        };
    }

local WeaponType = {}

WeaponType.Light = { 
    Name = 'Light', 
    Value = 1 
}
WeaponType.Medium = { 
    Name = 'Medium', 
    Value = 2 
}
WeaponType.Heavy = { 
    Name = 'Heavy', 
    Value = 3 
}

local WeaponSubType = {}
WeaponSubType.Fists = { 
    Name = 'Fists', 
    WeaponType = WeaponType.Light, 
    Value = 1 
}
WeaponSubType.Katana = { 
    Name = 'Katana', 
    WeaponType = WeaponType.Medium, 
    Value = 2 
}

WeaponSubType.Naginata = {
    Name = 'Naginata',
    WeaponType = WeaponType.Heavy,
    Value = 3;
}

return {
    ['EventType'] = EventType,
    ['WeaponType'] = WeaponType,
    ['WeaponSubType'] = WeaponSubType,
}