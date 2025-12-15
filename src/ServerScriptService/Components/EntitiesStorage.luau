local ReplicatedStorage = game:GetService('ReplicatedStorage')

local Shared = ReplicatedStorage:WaitForChild('Shared')
local Interfaces = Shared:WaitForChild('Interfaces')

local EntityInterfaces = require(Interfaces:WaitForChild('EntityInterfaces'))

local Entities = {}

local EntitiesStorage = {}

function EntitiesStorage:Add(Entity: EntityInterfaces.IEntityComponent)
	if Entities[tostring(Entity.SessionData.UserId)] then warn('Required Entity already exist.') return end
	Entities[tostring(Entity.SessionData.UserId)] = Entity
	warn('Added '..Entity.SessionData.UserId.." to Entities list.")
end

function EntitiesStorage:Remove(Entity: EntityInterfaces.IEntityComponent)
	if not Entities[tostring(Entity.SessionData.UserId)] then warn('Cannot find Required Entity.') return end
	Entities[tostring(Entity.SessionData.UserId)] = nil
	warn('Removed '..Entity.SessionData.UserId.." from Entities list.")
end



function EntitiesStorage:Get(UserId: string)
	if not Entities[tostring(UserId)] then warn('Cannot find Required Entity.') return end
	return Entities[tostring(UserId)]
end

return EntitiesStorage
