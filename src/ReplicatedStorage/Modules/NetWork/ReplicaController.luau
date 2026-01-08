local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage:WaitForChild('Packages')
local Modules = ReplicatedStorage:WaitForChild('Modules')
local NetWork = Modules:WaitForChild('NetWork')

local charm = require(Packages:WaitForChild('charm'))
local charmSync = require(Packages:WaitForChild('charm-sync'))
local Replicator = require(NetWork:WaitForChild('Replicator'))



local Replica = {}
local ServerReplica = {}
local ClientReplica = {}



local ServerCache = {}
local ClientCache = {}

local BASE_INTERVAL = 1/10

function ServerReplica._initSync(self,options)

    local newSync = charmSync.server(
        {
            atoms = self.Atoms;
            autoSerialize = (options.Serialize) or true;
            interval = (options.Interval) or BASE_INTERVAL;
            preserveHistory = (options.prevHistory) or false;
        })
    self._syncer = newSync
    self._syncer:connect(function(player: Player, ...)
        print('Server Change: ',...)
        self._Remotes:Fire(player,self.key..'syncState',...)
    end)

    return newSync
end

function ServerReplica.newServer(Key: string,Atoms,options)
    if ServerCache[Key] then return ServerCache[Key] end

    local self = setmetatable(
        {
            key = Key;
            Players = {};
            Atoms = {};
            _syncer = {};
            _listeners = {};
            _Remotes = Replicator:GetRemote('Global');
        }, 
    {
        __index = function(_,key)
            return ServerReplica[key]
        end
    })

    for name,value in pairs(Atoms) do 
        self.Atoms[name] = value
    end

    if options.autoSync then 
        self:_initSync(options)
    end

    ServerCache[Key] = self
    return self
end

function ServerReplica.Get(self,key)
    if not self.Atoms[key] then 
        error('Atom with key "' .. key .. '" not found')
        return 
    end
    return self.Atoms[key]()
end

function ServerReplica.Set(self,key, value)
    if not self.Atoms[key] then 
        error('Atom with key "' .. key .. '" not found')
        return 
    end

    self.Atoms[key](value)
end

function ServerReplica.Update(self,key, callback)
    if not self.Atoms[key] then
        error('Atom with key "' .. key .. '" not found')
        return 
    end
    self.Atoms[key](callback)
end

function ServerReplica.Connect(self,key, callback)
    if not self.Atoms[key] then
        error('Atom with key "' .. key .. '" not found')
        return
    end
    
    return charm.subscribe(self.Atoms[key], callback)
end

function ServerReplica.Hydrate(self,player)
    if not self._syncer then 
        warn('Syncer doesn`t connected')
        return 
    end
    self._syncer:hydrate(player)
end

function ServerReplica.GetAtom(self,key)
    if not self.Atoms[key] then
        error('Atom with key "' .. key .. '" not found')
        return
    end
    return self.Atoms[key]
end

function ServerReplica.GetAtoms(self)
    return self.Atoms
end


function ServerReplica.GetSyncer(self)
    return self._syncer
end

function ClientReplica.new(Key, initialState, options)
    options = options or {}
    if ClientCache[Key] then return ClientCache[Key] end

    local self = setmetatable(
        {
            Key = Key;
            Atoms = {};
            _listeners = {};
            _syncer = {};
            _hydrated = false;
            _Remotes = Replicator:GetRemote('Global');
        }, 
    {
        __index = function(_,_key)
            return ClientReplica[_key]
        end
    })

    
    for atomKey, value in pairs(initialState) do
        self.Atoms[atomKey] = value
    end
    
    if options.autoSync then
        self:_initSync(options)
    end
    
    ClientCache[Key] = self
    return self
end

function ClientReplica._initSync(self,options)
    self._syncer = charmSync.client(
        {
            atoms = self.Atoms;
            ignoreUnhydrated = (options.ignoreUnhydrated) or false;
        })
    self._Remotes:Connect(self.Key..'syncState', function(...)
        print('Clinet Change: ',...)
        self._syncer:sync(...)
        if not self._hydrated then
            self._hydrated = true
        end
    end)
    self._Remotes:Fire(self.Key..'requestState')
end

function ClientReplica.Get(self,key)
    if not self.Atoms[key] then
        error("Atom with key '" .. key .. "' not found")
        return
    end
    self.Atoms[key]()
end

function ClientReplica.Connect(self,key, callback)
    if not self.Atoms[key] then
        error("Atom with key '" .. key .. "' not found")
        return
    end
    return charm.subscribe(self.Atoms[key], callback)
end

function ClientReplica.WaitForHydration(self)
    if self._hydrated then
        return true
    end
    
    while not self._hydrated do
        task.wait(1/10)
    end
    
    return true
end

function ClientReplica.GetAtom(self,key)
    return self.Atoms[key]
end

function ClientReplica.GetAtoms(self)
    return self.Atoms
end

function Replica.CreateServerReplica(key, Atoms, options)
    local replica = ServerReplica.newServer(key, Atoms, options)
    
    print(key..'requestState')
    replica._Remotes:Connect(key..'requestState',function(player)
        replica:Hydrate(player)
    end)
    
    return replica
end

function Replica.CreateClientReplica(key, Atoms, options)
    local replica = ClientReplica.new(key, Atoms, options)
    return replica
end

return Replica