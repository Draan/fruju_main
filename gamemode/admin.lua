function Chat.Lock (ply, command, args)
	local tgt = ply:Target().Entity
	if (!tgt || !tgt:IsValid() || !tgt:IsProperty()) then return end
	
	tgt:Lock()
	Log.Add(ply, 'Locked a property using the !lock command.')
end
Chat.AddCommand('lock', Chat.Lock, 0, '!lock', false, true)

function Chat.Unlock (ply, command, args)
	local tgt = ply:Target().Entity
	if (!tgt || !tgt:IsValid() || !tgt:IsProperty()) then return end
	
	tgt:Unlock()
	Log.Add(ply, 'Unlocked a property using the !unlock command.')
end
Chat.AddCommand('unlock', Chat.Unlock, 0, '!unlock', false, true)

function Chat.MakeCop (ply, command, args)	
	local tgt = Fruju.FindPlayer(string.Trim(args[1]))
	
	if (!tgt || !tgt:IsPlayer()) then
		ply:Hint('Unable to find the specified player.')
		return
	end
	
	if (tgt.Cop) then
		ply:Hint(tgt:Nick()..' is already a police officer.')
		return
	end
	
	tgt:SetCop(true)
	tgt:SetJob('Police Officer')
	Chat.Send(Config.ChatType.Announcement, '[Announcement]', tgt:Nick()..' is the newest police officer in town.')
	Log.Add(ply, 'Made '..tgt:Nick()..' a police officer.')
end
Chat.AddCommand('makecop', Chat.MakeCop, 1, '!makecop <name>', false, true)

function Chat.RemoveCop (ply, command, args)
	local tgt = Fruju.FindPlayer(string.Trim(args[1]))
	
	if (!tgt || !tgt:IsPlayer()) then
		ply:Hint('Unable to find the specified player.')
		return
	end
	
	if (!tgt.Cop) then
		ply:Hint(tgt:Nick()..' is not a police officer.')
		return
	end
	
	tgt:SetCop(false)
	tgt:SetJob(Config.DefaultJob)
	Chat.Send(Config.ChatType.Announcement, '[Announcement]', tgt:Nick()..' has been forced to hand in their badge.')
	Log.Add(ply, 'Removed '..tgt:Nick()..' from the police.')
end
Chat.AddCommand('removecop', Chat.RemoveCop, 1, '!removecop <name>', false, true)

function Chat.RemoveOwner (ply, command, args)	
	local tgt = ply:Target().Entity
	if (!tgt || !tgt:IsValid() || !tgt:IsProperty()) then return end
	
	local plyr = Fruju.FindPlayer(string.Trim(args[1]))
	
	if (!plyr || !plyr:IsPlayer()) then
		ply:Hint('Unable to find the specified player.')
		return
	end
	
	tgt:RemoveOwner(plyr)
	Log.Add(ply, 'Took '..tgt:Nick()..'\'s key to a property using !unown.')
end
Chat.AddCommand('unown', Chat.RemoveOwner, 1, '!unown <name>', false, true)

function Chat.AddOwner (ply, command, args)	
	local tgt = ply:Target().Entity
	if (!tgt || !tgt:IsValid() || !tgt:IsProperty()) then return end
	
	local plyr = Fruju.FindPlayer(string.Trim(args[1]))
	
	if (!plyr || !plyr:IsPlayer()) then
		ply:Hint('Unable to find the specified player.')
		return
	end
	
	tgt:AddOwner(plyr)
	Log.Add(ply, 'Gave '..tgt:Nick()..' a key to a property using !own.')
end
Chat.AddCommand('own', Chat.AddOwner, 1, '!own <name>', false, true)

function Chat.Stun (ply, command, args)
	local tgt = Fruju.FindPlayer(args[1])
	
	if (!tgt || !tgt:IsPlayer()) then
		ply:Hint('Unable to find the specified player.')
		return
	end
	
	if (!tgt:Alive()) then return end
	
	if (tgt.Sleeping) then return end
	tgt:Sleep(nil, nil, true)
	Log.Add(ply, 'Stunned '..tgt:Nick()..'.')
end
Chat.AddCommand('stun', Chat.Stun, 1, '!stun <name>', false, true)

function Chat.Unstun (ply, command, args)
	local tgt = Fruju.FindPlayer(args[1])
	
	if (!tgt || !tgt:IsPlayer()) then
		ply:Hint('Unable to find the specified player.')
		return
	end
	
	if (!tgt.Sleeping) then return end
	tgt:Wake(true)
	tgt:UpdateLoadout()
	Log.Add(ply, 'Unstunned '..tgt:Nick()..'.')
end
Chat.AddCommand('unstun', Chat.Unstun, 1, '!unstun <name>', false, true)

function Chat.Slay (ply, command, args)
	local tgt = Fruju.FindPlayer(args[1])
	
	if (!tgt || !tgt:IsPlayer()) then
		ply:Hint('Unable to find the specified player.')
		return
	end
	
	tgt:Kill()
	Log.Add(ply, 'Slayed '..tgt:Nick()..'.')
end
Chat.AddCommand('slay', Chat.Slay, 1, '!slay <name>', false, true)

function Chat.SSlay (ply, command, args)
	local tgt = Fruju.FindPlayer(args[1])
	
	if (!tgt || !tgt:IsPlayer()) then
		ply:Hint('Unable to find the specified player.')
		return
	end
	
	tgt:KillSilent()
	Log.Add(ply, 'Silently slayed '..tgt:Nick()..'.')
end
Chat.AddCommand('sslay', Chat.SSlay, 1, '!sslay <name>', false, true)

function Chat.HP (ply, command, args)
	local tgt = Fruju.FindPlayer(args[1])
	
	if (!tgt || !tgt:IsPlayer()) then
		ply:Hint('Unable to find the specified player.')
		return
	end
	
	local hp = tonumber(args[2]);
	
	if (hp <= 0) then
		tgt:Kill()
	else
		tgt:SetHealth(hp)
	end
	
	Log.Add(ply, 'Set '..tgt:Nick()..'\'s hp to '..hp..'.')
end
Chat.AddCommand('hp', Chat.HP, 2, '!hp <name> <hp>', false, true)

function Chat.Mute (ply, command, args)
	local tgt = Fruju.FindPlayer(args[1])
	
	if (!tgt || !tgt:IsPlayer()) then
		ply:Hint('Unable to find the specified player.')
		return
	end
	
	tgt.Mute = true
	Log.Add(ply, 'Muted '..tgt:Nick()..'.')
end
Chat.AddCommand('mute', Chat.Mute, 1, '!mute <name>', false, true)

function Chat.Muted (ply)
	if (ply.Mute) then
		ply:Hint('You are muted and as such can not talk.')
		return false
	end
end
hook.Add('InterceptChat', 'Chat.Muted', Chat.Muted)

function Chat.Unmute (ply, command, args)
	local tgt = Fruju.FindPlayer(args[1])
	
	if (!tgt || !tgt:IsPlayer()) then
		ply:Hint('Unable to find the specified player.')
		return
	end
	
	tgt.Mute = false
	Log.Add(ply, 'Unmuted '..tgt:Nick()..'.')
end
Chat.AddCommand('unmute', Chat.Unmute, 1, '!unmute <name>', false, true)

function Chat.Map (ply, command, args)
	local name = string.Trim(string.lower(args[1]));
	local map = nil
	
	for _, mapfile in pairs (file.Find('../maps/*.bsp')) do
		if (string.find(string.lower(mapfile), name)) then
			map = mapfile
			break
		end
	end
	
	if (!map) then
		ply:Hint('Unable to find the specified map.')
		return
	end
	
	Log.Add(ply, 'Changed the map to '..map..'.')
	game.ConsoleCommand('changelevel "'..string.sub(map, 1, -5)..'"\n')
end
Chat.AddCommand('map', Chat.Map, 1, '!map <name>', false, true)

function Chat.Slap (ply, command, args)
	local tgt = Fruju.FindPlayer(args[1])
	
	if (!tgt || !tgt:IsPlayer()) then
		ply:Hint('Unable to find the specified player.')
		return
	end
	
	local damage = args[2] or math.random(10, 60)
	local velocity = Vector(math.random(0, 1000), math.random(0, 1000), math.random(300, 1000))
	
	tgt:SetHealth(tgt:Health() - damage)
	
	if (tgt:Health() < 0) then
		ply:Kill()
		return
	end
	
	tgt:SetVelocity(velocity)
	Log.Add(ply, 'Slapped '..tgt:Nick()..'.')
end
Chat.AddCommand('slap', Chat.Slap, 1, '!slap <name> <damage>', false, true)

function Chat.Vote (ply, command, args)
	local question = args[1]
	table.remove(args, 1)
	
	if (string.len(question) == 0) then return end
	
	for i = 10, table.Count(args) do
		table.remove(args, i)
	end	
	
	if (!Vote.Create(ply, question, args, player.GetAll(), Fruju.AdminVote)) then return end
	Log.Add(ply, 'Created a vote with the question "'..question..'".')
end
Chat.AddCommand('vote', Chat.Vote, 3, '!vote <question> <option 1> <option 2> etc', false, true)

function Fruju.AdminVote (votes, options) 
	local highest = nil
	local highestvotes = 0
	
	for i, votes in pairs (options) do
		if (votes > highestvotes) then
			highestvotes = votes;
			highest = Vote.Options[i]
		end
	end

	if (!highest) then return end
	Chat.Send(Config.ChatType.Announcement, '[Announcement]', highest..' is the most popular option in the vote.')
end

function Chat.EndVote (ply, command, args)
	if (Vote.Active) then
		Vote.Cancel()
		Chat.Send(Config.ChatType.Announcement, '[Announcement]', 'An admin has cancelled the vote.')
		Log.Add(ply, 'Cancelled the vote.')
	end
end
Chat.AddCommand('endvote', Chat.EndVote, 0, '!endvote', false, true)

function Chat.Kick (ply, command, args)
	local tgt = Fruju.FindPlayer(args[1])
	
	if (!tgt || !tgt:IsPlayer()) then
		ply:Hint('Unable to find the specified player.')
		return
	end
	
	table.remove(args, 1)
	
	local reason = string.Implode(' ', args)
	
	if (reason && string.len(reason) != 0) then
		Chat.Send(Config.ChatType.Announcement, '[Announcement]', tgt:Nick()..' has been kicked from the server (Reason: '..reason..').')
		Log.Add(ply, 'Kicked '..tgt:Nick()..' (Reason: '..reason..').')
	else
		Chat.Send(Config.ChatType.Announcement, '[Announcement]', tgt:Nick()..' has been kicked from the server.')
		Log.Add(ply, 'Kicked '..tgt:Nick()..'.')
	end
	
	game.ConsoleCommand('kickid "'..tgt:SteamID()..'" "'..reason..'"\n')
end
Chat.AddCommand('kick', Chat.Kick, 1, '!kick <name> <reason>', true, true)

function Chat.Ban (ply, command, args)
	local tgt = Fruju.FindPlayer(args[1])
	
	if (!tgt || !tgt:IsPlayer()) then
		ply:Hint('Unable to find the specified player.')
		return
	end
	
	local time = tonumber(args[2]) or 0
	
	local str = tgt:Nick()..' has been banned from the server'
	
	if (time && time > 0) then
		str = str..' for '..time..' minutes.' 
		Log.Add(ply, 'Banned '..tgt:Nick()..' for '..time..' minutes.')
	else
		str = str..' permanently.'
		Log.Add(ply, 'Banned '..tgt:Nick()..' permanently.')
	end
	
	Chat.Send(Config.ChatType.Announcement, '[Announcement]', str)
	
	game.ConsoleCommand('banid "'..time..'" "'..tgt:SteamID()..'" kick\n')
	game.ConsoleCommand('writeid')
end
Chat.AddCommand('ban', Chat.Ban, 1, '!ban <name> <time>', false, true)

function Chat.Unban (ply, command, args)
	local steam = arg[1]
	if (!string.find(steam, 'STEAM')) then return end
	
	game.ConsoleCommand('removeid '..steam..'\n')
	game.ConsoleCommand('writeid\n')
	
	Chat.Send(Config.ChatType.Announcement, '[Announcement]', 'SteamID: '..steam..' has been unbanned.')
	Log.Add(ply, 'Unbanned '..steam..'.')
end
Chat.AddCommand('unban', Chat.Unban, 1, '!unban <Steam ID>', false, true)

function Chat.God (ply, command, args)
	local tgt = Fruju.FindPlayer(args[1])
	
	if (!tgt || !tgt:IsPlayer()) then
		ply:Hint('Unable to find the specified player.')
		return
	end
	
	tgt:GodEnable()
	Log.Add(ply, 'Gave '..tgt:Nick()..' god mode.')
end
Chat.AddCommand('god', Chat.God, 1, '!god <name>', false, true)

function Chat.Ungod (ply, command, args)
	local tgt = Fruju.FindPlayer(args[1])
	
	if (!tgt || !tgt:IsPlayer()) then
		ply:Hint('Unable to find the specified player.')
		return
	end
	
	tgt:GodDisable()
	Log.Add(ply, 'Took '..tgt:Nick()..'\'s god mode.')
end
Chat.AddCommand('ungod', Chat.Ungod, 1, '!ungod <name>', false, true)

--[[function Chat.PlaySound (ply, command, args)
	local sound = tostring(args[1]);
	
	WorldSound(sound, ply:GetPos());
	
	Log.Add(ply, 'Played .')
end
Chat.AddCommand('playsound', Chat.PlaySound, 1, '!playsound <sound>', false, true)]]

function Chat.PlayMe (ply, command, args)
	local sound = tostring(args[1]);
	
	ply:EmitSound(sound);
	
	Log.Add(ply, 'Played sound('..sound..') from their position.')
end
Chat.AddCommand('playme', Chat.PlayMe, 1, '!playme <sound>', false, true)

function Fruju.AdminCommands (ply, command, args)
	// Just spam their console 
	ply:PrintMessage(HUD_PRINTCONSOLE, '!kick <name> <reason>: Kick a player, reason is optional\n')
	ply:PrintMessage(HUD_PRINTCONSOLE, '!ban <name> <time>: Ban a player, time is optional\n')
	ply:PrintMessage(HUD_PRINTCONSOLE, '!unban <Steam ID>: Unban a player\n')
	ply:PrintMessage(HUD_PRINTCONSOLE, '!slap <name> <damage>: Slap a player, damage is optional\n')
	ply:PrintMessage(HUD_PRINTCONSOLE, '!stun <name>: Stun a player\n')
	ply:PrintMessage(HUD_PRINTCONSOLE, '!unstun <name>: Unstun a player\n')
	ply:PrintMessage(HUD_PRINTCONSOLE, '!slay <name>: Slay a player\n')
	ply:PrintMessage(HUD_PRINTCONSOLE, '!sslay <name>: Silently slay a player\n')
	ply:PrintMessage(HUD_PRINTCONSOLE, '!map <name>: Change the map, doesn\'t need to be full map name\n')
	ply:PrintMessage(HUD_PRINTCONSOLE, '!mute <name>: Mute a player\n')
	ply:PrintMessage(HUD_PRINTCONSOLE, '!unmute <name>: Unmute a player\n')
	ply:PrintMessage(HUD_PRINTCONSOLE, '!hp <name> <amount>: Set a players health to the specified amount\n')
	ply:PrintMessage(HUD_PRINTCONSOLE, '!own <name>: Add an owner to the property being looked at\n')
	ply:PrintMessage(HUD_PRINTCONSOLE, '!unown <name>: Remove an owner from the property being looked at\n')
	ply:PrintMessage(HUD_PRINTCONSOLE, '!makecop <name>: Make a player a police officer\n')
	ply:PrintMessage(HUD_PRINTCONSOLE, '!removecop <name>: Remove a player from the police\n')
	ply:PrintMessage(HUD_PRINTCONSOLE, '!lock: Lock the property being looked at\n')
	ply:PrintMessage(HUD_PRINTCONSOLE, '!unlock: Unlock the property being looked at\n')
	ply:PrintMessage(HUD_PRINTCONSOLE, '!vote <question> <Option 1> <Option 2> ...: Create a vote\n')
	ply:PrintMessage(HUD_PRINTCONSOLE, '!endvote: End the current vote\n')
	ply:PrintMessage(HUD_PRINTCONSOLE, '!god <name>: Grant a player god mode\n')
	ply:PrintMessage(HUD_PRINTCONSOLE, '!ungod <name>: Take a players god mode\n')
end
concommand.Add('admincommands', Fruju.AdminCommands)
concommand.Add('acmds', Fruju.AdminCommands)

// Admin chat
function Chat.DetectAdmin (ply, text, team)
	local level = ply:GetLevel()
	if (!level || !level.AdminCommands) then return end

	if (string.sub(text, 1, 3) == '@@@' && (type(level.AdminCommands) == 'boolean' || level.AdminCommands['@@@'])) then
		Chat.Centre(string.Trim(string.sub(text, 4)))
		Log.Add(nil, '[Centre] '..string.Trim(string.sub(text, 4)))
		return false
	elseif (string.sub(text, 1, 2) == '@@' && (type(level.AdminCommands) == 'boolean' || level.AdminCommands['@@'])) then
		Chat.Announcement(ply, string.Trim(string.sub(text, 3)))
		Log.Add(nil, '[Announcement] '..string.Trim(string.sub(text, 3)))
		return false
	elseif (string.sub(text, 1, 1) == '@' && (type(level.AdminCommands) == 'boolean' || level.AdminCommands['@'])) then
		Chat.Admin(ply, string.Trim(string.sub(text, 2)))
		Log.Add(ply, '[Admin] '..string.Trim(string.sub(text, 2)))
		return false
	end
end
hook.Add('InterceptChat', 'Chat.DetectAdmin', Chat.DetectAdmin)

