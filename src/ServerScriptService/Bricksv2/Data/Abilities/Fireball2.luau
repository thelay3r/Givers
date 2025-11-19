local ServerScriptService = game:GetService('ServerScriptService')
local Bricks = ServerScriptService:WaitForChild('Bricksv2')

local Components = Bricks:WaitForChild('Components')
local Data = Bricks:WaitForChild('Data')
local Registries = Data:WaitForChild('Registries')

local Registry = require(Components:WaitForChild('Registry'))
local AbilityParser = require(Components:WaitForChild('AbilityParser'))

local behaviorRegistry = require(Registries:WaitForChild('BehaviorRegistry'))
local scopeRegistry = require(Registries:WaitForChild('ScopeRegistry'))

local parser = AbilityParser.new()

local behaviorRegistry2 = Registry.new():Clone(behaviorRegistry)

behaviorRegistry2:Register('Root', function(...: any)  
	print('New Root Behavior')
end)

parser.BehaviorRegistry = behaviorRegistry2
parser.ScopeRegistry = scopeRegistry

local passive = require(Data.Passive.Passive)

local ability = parser:Create({
	Name = 'Action.Root',
	Tag = 'Main',
	
	Config = {
		FadeoutTime = 3,
		Damage = 12,
		
		Passives = {
			passive
		}
	},
	
	{
		Name = 'Action.SpawnProjectile',
		Tag = 'Projectile1',
		
		Config = {
			Speed = 1,
			Direction = Vector3.new(0,0,1),
			StartVelocity = 10,
			Damage = 15,
			OnHitTag = 'OnHitAboltus'
		},
		
		{
			Name = 'Action.LinearSpeedUp',
			RequestedTags = {['ProjectileInfo'] = 'Projectile1'},
			Config = {
				Acceleration = 10
			}
		},
		
		{
			Name = 'Event.OnHit',
			Tag = 'OnHitAboltus',
			{
				Name = 'Action.Explode',
				RequestedTags = {['DamageInfo'] = 'Main'}
				
			},
			{
				Name = 'Action.Explode',
				RequestedTags = {['DamageInfo'] = 'Projectile1'}
			},
			{
				Name = 'Action.TriggerPassive',
				RequestedTags = {['Main'] = 'Main', ['Projectile'] = 'Projectile1'},
				Config = {
					PassiveEvent = 'Test123'
				}
			}
		}
		
	},
	
	{
		Name = 'Action.Wait',
		Config = { Wait = 5 }
	},
	
	{
		Name = 'Action.SpawnProjectile',
		Tag = 'Projectile2',

		Config = {
			Speed = 1,
			Direction = Vector3.new(0,0,1),
			StartVelocity = 10,
			Damage = 15,
			OnHitTag = 'OnHitAboltus'
		},

		{
			Name = 'Action.LinearSpeedUp',
			RequestedTags = {['ProjectileInfo'] = 'Projectile2'},
			Config = {
				Acceleration = 10
			}
		},

	}
})

ability:Build()

return ability