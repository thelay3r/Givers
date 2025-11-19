local AbstractPassives = require(script.Parent.Parent)

return function()
	local Passive = AbstractPassives.New()
	
	Passive.OnStart = function()
	end
	
	return Passive
end

