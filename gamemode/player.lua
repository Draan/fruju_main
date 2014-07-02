function Fruju.PlayerAuthed(ply, steam, unique)
	if (!ply || !ply:IsPlayer()) then return end
	
	ply:GetStats();
end
hook.Add('PlayerAuthed', 'Fruju.PlayerAuthed', Fruju.PlayerAuthed);

function Fruju.PlayerInitialSpawn (ply)
	ply:UpdateModel();
	ply:SetMoney(Config.DefaultMoney, true);
	timer.Simple(3, function() Fruju.CheckHands(ply) end);
	timer.Simple(3, function() ply:Hint('Need help? Press F1.'); end);
end
hook.Add('PlayerInitialSpawn', 'Fruju.PlayerInitialSpawn', Fruju.PlayerInitialSpawn);

function Fruju.PlayerSpawn (ply)
	if (ply.FakeSpawn) then return end
	
	ply:StripWeapons();
	ply:SetCriminal(false);
	ply:UpdateLoadout();
	ply:SetupHands()
	
end
hook.Add('PlayerSpawn', 'Fruju.PlayerderpSpawn', Fruju.PlayerSpawn);


function GM:PlayerSetHandsModel( ply, ent )

	local simplemodel = player_manager.TranslateToPlayerModelName( ply:GetModel() )
	local info = player_manager.TranslatePlayerHands( simplemodel )
	if ( info ) then
		ent:SetModel( info.model )
		ent:SetSkin( info.skin )
		ent:SetBodyGroups( info.body )
	end

end

function Fruju.SelectModel (ply, command, args)
	ply:Freeze(false)

	local model = tonumber(args[1])
	if (!model || model == 0) then return end
	
	local models = {}
	if (ply.Cop) then 
		models = table.Copy(Config.PoliceModels.Male)
		table.Add(models, Config.PoliceModels.Female)
	else
		models = table.Copy(Config.PlayerModels.Male)
		table.Add(models, Config.PlayerModels.Female)
	end
	
	if (!models[model]) then return end
	if (models[model] == string.Replace(ply:GetModel(), 'humans', 'player')) then return end
	
	ply:SetModel(models[model])
	Log.Add(ply, 'Changed their model to '..models[model]..'.')
end
concommand.Add('Fruju.Model', Fruju.SelectModel)

function Fruju.Payday ()
	for _, ply in pairs (player.GetAll()) do
		if (string.len(ply:GetJob()) != 0 && ply:GetJob() != Config.DefaultJob) then
			local pay = math.random(Config.MinPay, Config.MaxPay)
			ply:SetMoney(ply:GetMoney() + pay)
			ply:Hint('Payday! You have recieved '..Fruju.FormatMoney(pay)..'.')
		end
	end
end

function Fruju.CheckHands (ply)
	if (ply && ply:IsValid() && ply:IsPlayer()) then
		if (!ply:HasWeapon(Fruju.HandsClass) && !ply.Criminal && ply:Alive() && !ply.Sleeping) then
			ply:Give(Fruju.HandsClass);
		end
		
		timer.Simple(1, Fruju.CheckHands, ply)
	end
end

function Fruju.DropMoney (ply)
	ply:StoreStats()
	
	local drop = math.Rand(Config.MoneyDropMin, Config.MoneyDropMax)
	
	drop = ply:GetMoney() * drop
	if (drop <= 0) then return end

	ply:SetMoney(ply:GetMoney() - drop)
	
	// Drop the money
	local money = ents.Create('fruju_money')
	money:SetMoney(drop)
	money:SetModel('models/props/cs_assault/money.mdl')
	money:SetPos(ply:GetPos())
	money:Spawn()
end
hook.Add('PlayerDeath', 'Fruju.DropMoney', Fruju.DropMoney)

function Fruju.DieSleeping(ply)
	if (ply.Sleeping) then
		ply:Wake(true);
	end
end
hook.Add('DoPlayerDeath', 'Fruju.DieSleeping', Fruju.DieSleeping);

function Fruju.GiveAmmo (wep)
	timer.Simple(FrameTime(), function() Fruju.GiveAmmoTrue(wep) end);
end
hook.Add('WeaponEquip', 'Fruju.GiveAmmo', Fruju.GiveAmmo)

function Fruju.GiveAmmoTrue (wep)
	if (!wep || !wep:IsValid()) then return end
	
	local ply = wep:GetOwner()
	if (!ply || !ply:IsValid() || ply.FakeSpawn) then return end
	
	if (!ply.WeaponPickedUp) then
		local ammo = wep:GetPrimaryAmmoType()
		if (!ammo) then return end
		
		ply:GiveAmmo(100, ammo)
	end
	
	ply.WeaponPickedUp = false;
end

function GM:PlayerSelectSpawn (ply)
	// Build a spawn list for this player
	if (!IsTableOfEntitiesValid(self.SpawnPoints)) then
	
		self.LastSpawnPoint = 0
		self.SpawnPoints = ents.FindByClass( "info_player_start" )
		self.SpawnPoints = table.Add( self.SpawnPoints, ents.FindByClass( "info_player_deathmatch" ) )
		self.SpawnPoints = table.Add( self.SpawnPoints, ents.FindByClass( "info_player_combine" ) )
		self.SpawnPoints = table.Add( self.SpawnPoints, ents.FindByClass( "info_player_rebel" ) )
		
		// CS Maps
		self.SpawnPoints = table.Add( self.SpawnPoints, ents.FindByClass( "info_player_counterterrorist" ) )
		self.SpawnPoints = table.Add( self.SpawnPoints, ents.FindByClass( "info_player_terrorist" ) )
		
		// DOD Maps
		self.SpawnPoints = table.Add( self.SpawnPoints, ents.FindByClass( "info_player_axis" ) )
		self.SpawnPoints = table.Add( self.SpawnPoints, ents.FindByClass( "info_player_allies" ) )

		// (Old) GMod Maps
		self.SpawnPoints = table.Add( self.SpawnPoints, ents.FindByClass( "gmod_player_start" ) )
		
		// TF Maps
		self.SpawnPoints = table.Add( self.SpawnPoints, ents.FindByClass( "info_player_teamspawn" ) )		
	end
	
	if (table.Count(self.SpawnPoints) == 0) then
		Msg("[PlayerSelectSpawn] Error! No spawn points!\n")
		return nil 
	end
	
	local ChosenSpawnPoint = nil
	
	// Try to work out the best, random spawnpoint (in 6 goes)
	for i=0, 6 do
		ChosenSpawnPoint = table.Random(self.SpawnPoints)
		
		if ( ChosenSpawnPoint &&
			ChosenSpawnPoint:IsValid() &&
			ChosenSpawnPoint:IsInWorld() &&
			ChosenSpawnPoint != ply:GetVar( "LastSpawnpoint" ) &&
			ChosenSpawnPoint != self.LastSpawnPoint ) then

			if (GAMEMODE:IsSpawnpointSuitable(ply, ChosenSpawnPoint, i==6)) then
				self.LastSpawnPoint = ChosenSpawnPoint
				ply:SetVar("LastSpawnpoint", ChosenSpawnPoint)
				return ChosenSpawnPoint
			end
		end	
	end
	
	return ChosenSpawnPoint
end

function Fruju.ClearRagdoll (ply)
	if (!ply.Ragdoll) then return end
	
	local ragdoll = Entity(ply.Ragdoll)
	if (!ragdoll || !ragdoll:IsValid()) then return end
	
	ragdoll:Remove()
end
hook.Add('PlayerDisconnected', 'Fruju.ClearRagdoll', Fruju.ClearRagdoll)

function Fruju.Connect (ply)
	Chat.Send(Config.ChatType.Announcement, '[Announcement] ', ply:Nick().." joined the server")
	Log.Add(ply, ' Joined the server.')
end
hook.Add('PlayerAuthed', 'Fruju.Connect', Fruju.Connect)

function Fruju.Disconnect (ply)
	Chat.Send(Config.ChatType.Announcement, '[Announcement] ', ply:Nick().." left the server")
	Log.Add(ply, 'Left the server.')
end
hook.Add('PlayerDisconnected', 'Fruju.Disconnect', Fruju.Disconnect)