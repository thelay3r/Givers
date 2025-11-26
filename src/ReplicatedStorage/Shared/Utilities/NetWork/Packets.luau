local PacketManager = require(script.Parent.PacketManager)

--{ { Name = 'teest', Key = Enum.KeyCode.X, State = Enum.UserInputState.Begin } }

return {
	
	ReplicateKeys = PacketManager('ReplicateKeys', {
		Key = PacketManager.String;
		State = PacketManager.String;
	});
	
	Ability = PacketManager('Ability', 
	{
		Name = PacketManager.String;
		State = PacketManager.String;
	});



	
	SetupPack = PacketManager('SetupPack', PacketManager.Any);
	ReplicateAbilities = PacketManager('ReplicateAbilities', 
		{{ Name = PacketManager.String, Key = PacketManager.Any, State = PacketManager.Any }});
	
}
