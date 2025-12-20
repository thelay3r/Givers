-- Simple module loader to execute a Luau module file with injected globals and dependencies
-- Provides a fake Roblox-like environment pieces as needed.

local function loadModule(path: string, inject: { [string]: any }?)
	inject = inject or {}

	-- Read file
	local ok, source = pcall(function()
		local f = assert(io.open(path, "r"))
		local s = f:read("*a")
		f:close()
		return s
	end)
	if not ok then error("Failed to read module: " .. tostring(source)) end

	-- Create environment
	local env = {}
	for k, v in pairs(_G) do env[k] = v end
	for k, v in pairs(inject) do env[k] = v end

	-- Compile chunk
	local chunk, err = load(source, "=" .. path, "t", env)
	if not chunk then error(err) end
	return chunk()
end

return {
	loadModule = loadModule,
}
