
local Registry = {}
Registry.__index = Registry

function Registry.new()
	local self = setmetatable({
		callbacks = {},
	}, Registry)

	return self
end

function Registry:Register(name: string, callback: (...any) -> any)
	self.callbacks[name] = callback
end

function Registry:Get(name: string)
	if (not self.callbacks[name]) then
		print(('%s isn\'t registered!'):format(name))
		return nil
	end

	return self.callbacks[name]
end

function Registry:Extends(registries: {any})
	setmetatable(self.callbacks, {
		__index = function(t, i)
			for _, registry in pairs(registries) do
				if (registry.callbacks[i]) then return registry.callbacks[i] end
			end

			return nil
		end
	})

	return self
end

return Registry