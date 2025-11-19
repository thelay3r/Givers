local module = {}

local cfg = require(script.cfg)


module.OnStart = function()
	bus:Fire('Umbrella_Punch',cfg)
end


return module
