local Counter = {}

local Temp = {}
local Methods = {}

function Counter:Decrement()
    if self.Value >= self._MaxValue then
        self.Value = self._StartValue
       else
        self.Value -= 1
    end
end

function Counter:Reset()
    self.Value = self._StartValue
end

function Counter:Increment()
    if self.Value >= self._MaxValue then
        self.Value = self._StartValue
       return
    end

    self.Value += 1
end

function Counter:Destroy(name:string)
    table.clear(self)
    Temp[name] = nil
end

function Counter.Create(name: string,startValue:number, maxCount: number) : typeof(Counter)
    if Temp[name] then return Temp[name] end
    
    local self = setmetatable(
    {
        _StartValue = startValue;
        _MaxValue = maxCount;
        Value = startValue;
    },
    {
        __index = function(t,key)
            return Counter[key]
        end;
        __call = function()
            return Temp[name].Value
        end
    })
    Temp[name] = self
    return Temp[name]
end 

return Counter