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

local LocalPlayerInterfaces = require(Interfaces:WaitForChild('LocalPlayerInterfaces'))

local PlayerStorage = require(Components:WaitForChild('LocalPlayerComponent'):WaitForChild('PlayerStorage'))

type IPlayer = LocalPlayerInterfaces.IClientPlayerComponent

local Player: IPlayer = PlayerStorage:GetPlayer()
local BindableGlobal = Replicator:GetRemote('BindableGlobal')

local Contexts = {}

local function GetState(State : Enum.UserInputState)
	if State == Enum.UserInputState.Begin then
		return 'OnStart' 
	else
		return 'OnStop'
	end
end




Contexts['LocalAbility'] = function(_,State, SelectedInput: InputObject)
	print(State)
	BindableGlobal:BindableFire('LocalAbility', {
		Name = SelectedInput;
		State = GetState(State);
	})
end


Contexts['Ability'] = function(_,State, SelectedInput: InputObject)
	BindableGlobal:BindableFire('ServerAbility',
	{
		Name = SelectedInput;
		State = GetState(State);
	})
end

Contexts['Feint'] = function(_,State, SelectedInput: InputObject)
	BindableGlobal:BindableFire('Feint')
end

Contexts['SlideJump'] = function(_,State, SelectedInput: InputObject)
	BindableGlobal:BindableFire('SlideJump')
end

Contexts['BackpackButton'] = function(args, State)
	Replicator:GetRemote('BindableGlobal'):BindableFire('BackPackGUI', args.Additional.Int, State)
end

return Contexts
