local ReplicatedStorage = game:GetService('ReplicatedStorage')


local Shared = ReplicatedStorage:WaitForChild('Shared')
local Utilites = Shared:WaitForChild('Utilities')
local Modules = Utilites:WaitForChild('Modules')
local TableHelper = require(Modules:WaitForChild('TableHelper'))


local JumpPowerData = 
    {
        Character = {};
        Humanoid = {};
        Entity = {};
        Data = 
        {
            CurrentJump = 0;
            LastJump = 0;
            DefaultJump = 0;
            
            Cache = {};
        };
        SessionData = 
        {
            JumpData = 
            {
                CanChange = true;
                IsModified = false;
                ModifierCount = 0;
            };
        };
    }


return function(): typeof(JumpPowerData)
    return TableHelper:DeepTableClone(JumpPowerData)
end