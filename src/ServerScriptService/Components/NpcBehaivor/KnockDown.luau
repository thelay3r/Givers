local ReplicatedStorage = game:GetService("ReplicatedStorage")
local M1 = require(ReplicatedStorage.Shared.Abilities.Fists.M1)
local EntityInterfaces = require(ReplicatedStorage.Shared.Interfaces.EntityInterfaces)
local M1 = {}


function M1.init(npc: any & EntityInterfaces.IEntityComponent)
    print(npc)
    task.delay(2,function()
		print(npc,'TAG SOME NPC')
		npc:TakeDamage(1e10)
	end)

end


return setmetatable(M1, {
    __call = function(_,...)
        M1.init(...)
    end
})