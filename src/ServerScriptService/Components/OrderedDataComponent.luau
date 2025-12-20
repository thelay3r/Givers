local DataStoreService = game:GetService('DataStoreService')
local ReplicatedStorage = game:GetService('ReplicatedStorage')

local Shared = ReplicatedStorage:WaitForChild('Shared')
local Interfaces = Shared:WaitForChild('Interfaces')
local Info = Shared:WaitForChild('Info')

local OrderedInfo = require(Info:WaitForChild('OrderedInfo'))
local PlayerInterfaces = require(Interfaces:WaitForChild('PlayerInterfaces'))

local IgnoreList = OrderedInfo.IgnoreList
local OrderedConstants = OrderedInfo.OrderedConstants

local function ConstructData(player: PlayerInterfaces.IServerPlayerComponent)
	local profileData = player.Profile.Data
	local constructed = {}
	
	constructed['Coins'] = profileData.Values.Coins
	
	return constructed
	
end

local OrderedDataComponent = {}

function OrderedDataComponent:UpdateData()

end

return OrderedDataComponent
