AddCSLuaFile('shared.lua')
AddCSLuaFile('cl_init.lua')

include('shared.lua')
include('commands.lua')

local Player = FindMetaTable('Player')

function Player:UpdateModel (gender)
	local tbl = Config.PlayerModels
	if (self.Cop) then tbl = Config.PoliceModels end
	
	local models = {}
	
	if (gender) then
		models = tbl[gender]
	else
		models = table.Copy(tbl.Male)
		table.Add(models, tbl.Female)
	end
	
	self:SetModel(models[math.random(1, table.Count(models))])
end

function Player:UpdateSpeed (override)
	if (override) then
		if (self.LastOverride) then
			if (override == self.LastOverride) then return end
		end
		
		self.LastOverride = override
		
		self:SetWalkSpeed(override)
		self:SetRunSpeed(override)
		return
	end
	
	if (self.Criminal) then
		self:SetWalkSpeed(150)
		self:SetCrouchedWalkSpeed(0.5)
		self:SetRunSpeed(150)
	else
		self:SetWalkSpeed(150)
		self:SetCrouchedWalkSpeed(0.5)
		self:SetRunSpeed(325)
	end
	
	self.LastOverride = nil
	self:SetJumpPower(160)
end

function Player:UpdateLoadout ()
	if (self.Criminal) then return end
	if (!self:Alive()) then return end
	
	if (self.Sleeping || self:InVehicle()) then 
		self.DoLoadout = true 
		return 
	end
	
	self.DoLoadout = false

	// Build the loadout table
	local loadout = {}
	
	local level = self:GetLevel()
	if (level) then
		table.Add(loadout, level.Loadout)
		if (self.Cop) then table.Add(loadout, level.PoliceLoadout) end
	else
		loadout[1] = Fruju.HandsClass
	end
	
	// Give the player the weapons
	for _, weapon in pairs (loadout) do
		if (!self:HasWeapon(weapon)) then
			self:Give(weapon)
		end
	end
end

function Player:UpdateJob(recipient)
	if (!recipient) then
		recipient = RecipientFilter()
		recipient:AddAllPlayers()
	end
	
	umsg.Start('Player.Job', recipient)
		umsg.String(self:UniqueID())
		umsg.String(self:GetJob())
	umsg.End()
end

function Player:UpdateMoney(recipient)
	if (!recipient) then recipient = self end
	
	umsg.Start('Player.Money', recipient)
		umsg.String(self:UniqueID())
		umsg.Float(self:GetMoney())
	umsg.End()
end

function Player:UpdateCop (recipient)
	if (!recipient) then
		recipient = RecipientFilter()
		recipient:AddAllPlayers()
	end
	
	umsg.Start('Player.Cop', recipient)
		umsg.String(self:UniqueID())
		umsg.Bool(self.Cop)
	umsg.End()
end

function Player:UpdateCriminal (recipient)
	if (!recipient) then
		recipient = RecipientFilter()
		recipient:AddAllPlayers()
	end
	
	umsg.Start('Player.Criminal', recipient)
		umsg.String(self:UniqueID())
		umsg.Bool(self.Criminal)
	umsg.End()
end

function Player:UpdateRating (recipient)
	if (!recipient) then
		recipient = RecipientFilter()
		recipient:AddAllPlayers()
	end
	
	umsg.Start('Player.Rating', recipient)
		umsg.String(self:UniqueID())
		umsg.Short(self:GetRating())
	umsg.End()
end

function Player.RequestJob (ply, command, args)
	local tgt = player.GetByUniqueID(args[1]);
	if (!tgt || !tgt:IsPlayer()) then return end
	
	tgt:UpdateJob(ply)
end
concommand.Add('Player.RequestJob', Player.RequestJob)

function Player.RequestMoney (ply, command, args)			
	ply:UpdateMoney()
end
concommand.Add('Player.RequestMoney', Player.RequestMoney)

function Player.RequestCriminal (ply, command, args)
	local tgt = player.GetByUniqueID(args[1])
	if (!tgt || !tgt:IsPlayer()) then return end
	
	tgt:UpdateCriminal(ply)
end
concommand.Add('Player.RequestCriminal', Player.RequestCriminal)

function Player.RequestCop (ply, command, args)
	local tgt = player.GetByUniqueID(args[1])
	if (!tgt || !tgt:IsPlayer()) then return end
	
	tgt:UpdateCop(ply)
end
concommand.Add('Player.RequestCop', Player.RequestCop)

function Player.RequestRating (ply, command, args)
	local tgt = player.GetByUniqueID(args[1])
	if (!tgt || !tgt:IsPlayer()) then return end
	
	tgt:UpdateRating(ply)
end
concommand.Add('Player.RequestRating', Player.RequestRating)

function Player:Hint(message)
	Chat.Send(Config.ChatType.Hint, '[Hint]', message, self)
end

function Player:OwnUnown ()
	// Get the target
	local target = self:Target().Entity
	if (!target || !target:IsValid()) then return end
	if (!target:IsProperty()) then return end
	
	// Check if the player owns the property
	if (target:IsOwner(self)) then
		target:RemoveOwner(self)
		target:EmitSound('HL1/fvox/fuzz.wav')
		Log.Add(ply, 'Unowned a property.')
	else
		// Check if there is an owner
		if (target:IsOwned()) then return end
		target:AddOwner(self)
		target:EmitSound('HL1/fvox/fuzz.wav')
		Log.Add(ply, 'Owned a property.')
	end
end
hook.Add('ShowSpare1', 'Player.OwnUnown', Player.OwnUnown)

function Player:Sleep (class, model, force)
	if (self:InVehicle()) then self:ExitVehicle() end
	if (self.Sleeping) then return end
	
	// Create a ragdoll here
	local ragdoll = ents.Create(class or 'prop_ragdoll')
	ragdoll:SetPos(self:GetPos())
	ragdoll:SetModel(model or self:GetModel())
	ragdoll:SetAngles(self:GetAngles())
	ragdoll:Spawn()
	self.Ragdoll = ragdoll:EntIndex()
	self.SleepForced = force
	self.Sleeping = true
	
	// Make the player spectate it
	self:Spectate(OBS_MODE_CHASE)
	self:DrawWorldModel(false)
	self:SpectateEntity(ragdoll)
	self:StripWeapons()
end

function Player:StoreWeapons ()
	self.Weapons = {}
	
	if (self:GetActiveWeapon() && self:GetActiveWeapon():IsValid()) then
		self.ActiveWeapon = self:GetActiveWeapon():GetClass()
	else
		self.ActiveWeapon = ''
	end

	for _, wep in pairs (self:GetWeapons()) do
		self.Weapons[wep:GetClass()] = {}
		
		self.Weapons[wep:GetClass()].Clip1 = wep:Clip1()
		self.Weapons[wep:GetClass()].Clip2 = wep:Clip2()
	end
end

function Player:Wake (force)
	local ragdoll = Entity(self.Ragdoll)
	
	if (self.SleepForced && !force) then return end
	
	self.FakeSpawn = true
	self:UnSpectate()
	self:Spawn()
	self.FakeSpawn = false
	self.SleepForced = false
	self.Sleeping = false
	self.SleepTime = nil
	
	if (self.DoLoadout) then
		self:UpdateLoadout();
	end
	
	if (ragdoll && ragdoll:IsValid()) then
		self:SetPos(ragdoll:GetPos())
		self:SetAngles(ragdoll:GetAngles())
		ragdoll:Remove()
	
		self:DrawWorldModel(true)
		self:SetViewEntity(self)
	end
end

function Player:RestoreWeapons () 
	self:StripWeapons()
	
	for class, ammo in pairs (self.Weapons or {}) do
		self:Give(class)
		
		local wep = self:GetWeapon(class)
		
		wep:SetClip1(ammo.Clip1)
		wep:SetClip2(ammo.Clip2)
	end
	
	self:SelectWeapon(self.ActiveWeapon)
end

function Player:GetStats ()
	Player.CreateTable()
	
	// Get the players stats
	local result = sql.Query("SELECT rating FROM Fruju_Player WHERE SteamID='"..self:UniqueID().."'")
	
	if (!result) then
		self:SetRating(0);
	else
		self:SetRating(tonumber(result[1].rating));
	end
end

function Player:StoreStats ()
	Player.CreateTable()

	local exists = sql.Query("SELECT updated FROM Fruju_Player WHERE SteamID='"..self:UniqueID().."'")
	
	if (exists) then
		sql.Query("UPDATE Fruju_Player SET rating='"..self:GetRating().."', updated='"..os.time().."' WHERE SteamID='"..self:UniqueID().."'")
	else
		sql.Query("INSERT INTO Fruju_Player (SteamID, updated, rating) VALUES ('"..self:UniqueID().."', '"..os.time().."', '"..self:GetRating().."')")
	end
	
end

function Player.CreateTable ()
	sql.Query("CREATE TABLE IF NOT EXISTS Fruju_Player (SteamID INTEGER NOT NULL PRIMARY KEY, updated INTEGER, rating INTEGER);")
end
hook.Add('Initialize', 'Player.CreateTable', Player.CreateTable)

local places = {
	'kitchen',
	'ballroom',
	'conservatory',
	'dining room',
	'billiard room',
	'library',
	'lounge', 
	'hall',
	'study'
}

function GM:PlayerDeath(ply, ent, killer)
	ply.NextSpawnTime = CurTime() + 2;
    ply.DeathTime = CurTime();
	
	if (!killer || !killer:IsPlayer()) then
		print(ply:Nick().." died\n");
		Log.Add(ply, 'Died.')
	elseif (killer == ply) then
		print(ply:Nick().." committed suicied\n");
		Log.Add(ply, 'Committed suicide.')
	else		
		local wep = killer:GetActiveWeapon();
		local place = places[math.random(1, table.Count(places))];
		
		print(ply:Nick().." was killed by "..killer:Nick().." using a "..wep:GetClass().." in the "..place..".");
		Log.Add(ply, 'Was killed by '..killer:Nick()..' using a '..wep:GetClass()..' in the '..place..'.')
	end
end

-- Drop weapon
function Fruju.DropWeapon(ply)
	local wep = ply:GetActiveWeapon();
	if (!wep || !wep:IsValid() || !wep:IsWeapon()) then return end
	
	if (Config && Config.NoDrop) then
		if (Config.NoDrop[wep:GetClass()]) then return end
	end
	
	local tr = ply:Target(30)
	
	-- Create the entity
	local ent = ents.Create('fruju_weapon');
	
	ent:SetModel(wep.WorldModel or wep:GetModel());
	ent.Weapon = wep:GetClass();
	ent.Clip1 = wep:Clip1();
	ent.Clip2 = wep:Clip2();
	ent.Primary = wep:GetPrimaryAmmoType();
	ent.Secondary = wep:GetSecondaryAmmoType();
	
	ent:SetPos(tr.HitPos + tr.HitNormal * 16);
	ent:SetAngles(wep:GetAngles());
	ent:Spawn();
	
	-- Get rid of the weapon
	ply:StripWeapon(wep:GetClass())
end
hook.Add("ShowSpare2", "Fruju.DropWeapon", Fruju.DropWeapon);

function Fruju.DropWeaponDeath(ply)
	Fruju.DropWeapon(ply);
end
hook.Add("DoPlayerDeath", "Fruju.DropWeaponDeath", Fruju.DropWeaponDeath);

-- Pickup Weapon
function Player:PickupWeapon(wep, primary, secondary, primaryCount, secondaryCount)
	local ammo1 = self:GetAmmoCount(primary);
	local ammo2 = self:GetAmmoCount(secondary);
	
	self:Give(wep);
	
	self:RemoveAmmo(self:GetAmmoCount(primary) - ammo1, primary);
	self:RemoveAmmo(self:GetAmmoCount(secondary) - ammo2, secondary);
	self:GiveAmmo(primaryCount, primary);
	self:GiveAmmo(secondaryCount, secondary);
end

-- Exit Vehicle
function Player:LoadoutExitVehicle()
	if (self.DoLoadout) then
		self:UpdateLoadout();
	end
end
hook.Add("PlayerLeaveVehicle", "Player.LoadoutExitVehicle", Player.LoadoutExitVehicle);