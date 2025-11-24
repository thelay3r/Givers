local ReplicatedStorage = game:GetService('ReplicatedStorage')
local RunService = game:GetService('RunService')

local Shared = ReplicatedStorage:WaitForChild('Shared')
local Components = Shared:WaitForChild('Components')
local Interfaces = Shared:WaitForChild('Interfaces')
local Utilities = Shared:WaitForChild('Utilities')
local NetWork = Utilities:WaitForChild('NetWork')

local Packets = require(NetWork:WaitForChild('Packets'))
local Replicator = require(NetWork:WaitForChild('Replicator'))

local AbilityPacket = Packets.Ability

local AbilityInterfaces = require(Interfaces:WaitForChild('AbilityInerfaces'))
local LocalPlayerInterfaces = require(Interfaces:WaitForChild('LocalPlayerInterfaces'))

local PlayerStorage = require(Components:WaitForChild('LocalPlayerComponent'):WaitForChild('PlayerStorage'))

type IPlayer = LocalPlayerInterfaces.IClientPlayerComponent
type IAbility = AbilityInterfaces.IAbilityComponent

local Player: IPlayer = PlayerStorage:GetPlayer()

local Contexts = {}

local function GetState(State : Enum.UserInputState)
	if State == Enum.UserInputState.Begin then
		return 'OnStart' 
	else
		return 'OnStop'
	end
end

local function CheckBlacklist(Ability: IAbility)
	if Ability:CheckBlacklist(Ability.Config.Blacklist) then return true end
	return false
end

Contexts['Weapon'] = function(args, State, SelectedInput: InputObject)
	
	if args['Additional'][SelectedInput]['Type'] == 'Server' then
		AbilityPacket:Fire(
			{
				Input = SelectedInput;
				Name = args['Additional'][SelectedInput]['Name'];
				State = GetState(State)
			})
	end
end

Contexts['Movement'] = function(args, State, SelectedInput: InputObject)
	
	Player = PlayerStorage:GetPlayer()
	
	if (not Player) or (not Player.ClientData) then return end
end

Contexts['Ability'] = function(_,State, SelectedInput: InputObject)
	print(State,SelectedInput)
	AbilityPacket:Fire(
		{
			Name = SelectedInput;
			State = GetState(State);
		})
end

Contexts['BackpackButton'] = function(args, State)
	Replicator:GetRemote('BindableGlobal'):BindableFire('BackPackGUI', args.Additional.Int, State)
end

return Contexts
