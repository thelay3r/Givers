local Registry = {}
Registry.__index = Registry

function Registry.new()
	local self = setmetatable({
		callbacks = {},
		_meta = {},
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

	self._meta = registries
	if (not registries) then
		warn(`{self} registries are nill`)
		return
	end

	setmetatable(self.callbacks, {
		__index = function(t, i)
			for _, registry in pairs(self._meta) do
				if (registry.callbacks[i]) then return registry.callbacks[i] end
			end

			return nil
		end
	})

	return self
end

function Registry:Destroy()
	if self._destroyed then return end
	self._destroyed = true

	if type(self.callbacks) == "table" then
		-- remove metatable that may reference other registries
		if getmetatable(self.callbacks) then
			setmetatable(self.callbacks, nil)
		end

		-- clear entries
		for k in pairs(self.callbacks) do
			self.callbacks[k] = nil
		end
	end

	-- drop reference to callbacks table
	self.callbacks = nil
end

return Registry