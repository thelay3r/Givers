local ReplicatedStorage = game:GetService('ReplicatedStorage')

local Shared = ReplicatedStorage:WaitForChild('Shared')
local Templates = Shared:WaitForChild('Templates')

local SessionTemplate = require(Templates.SessionData)

local SessionComponent = {}

function SessionComponent.LoadSession(self)
	return SessionTemplate()
end

return SessionComponent
