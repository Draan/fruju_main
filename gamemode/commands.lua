// OOC
function Chat.OOC (ply, command, args)
	if (ply.Muted) then
		ply:Hint('You are muted and as such can not talk.')
		return
	end

	local text = string.Trim(string.Implode(' ', args))
	 
	Chat.Send(Config.ChatType.OOC, '[OOC] '..ply:Nick()..':', text)
	Chat.AddOOCStat(ply);

	Log.Add(ply, '[OOC] '..text)
end
Chat.AddCommand('ooc', Chat.OOC, 0, '', true)
Chat.AddCommand('/', Chat.OOC, 0, '', true)

function Chat.DetectOOC (ply, text)
	if (string.lower(string.sub(text, 1, 3)) == 'ooc') then
		Chat.OOC(ply, 'ooc', Chat.GetArguments('ooc', text, false, true))
		Chat.AddOOCStat(ply, true);
		
		return false
	end
end
hook.Add('InterceptChat', 'Chat.DetectOOC', Chat.DetectOOC)

sql.Query("CREATE TABLE IF NOT EXISTS Fruju_OOCStats (PlayerID TEXT primary_key, Name TEXT, Total INTEGER, Stupid INTEGER)");

function Chat.AddOOCStat(ply, stupid)
	Chat.OOCStat = Chat.OOCStat or {};
	
	local id = ply:UniqueID();
	local stat = Chat.OOCStat[id] or Chat.GetOOCStat(ply, sql.SQLStr(id));
	
	if (stupid) then
		stat.Stupid = stat.Stupid + 1;
	else
		stat.Total = stat.Total + 1;
	end
	
	stat.Percentage = Chat.GetOOCPercentage(stat.Total, stat.Stupid);
	
	Chat.OOCStat[id] = stat;
	sql.Query("UPDATE Fruju_OOCStats SET Total="..stat.Total..", Stupid="..stat.Stupid.." WHERE PlayerID="..sql.SQLStr(id));
end

function Chat.GetOOCStat(ply, id)
	local stats = sql.Query("SELECT Name, Total, Stupid FROM Fruju_OOCStats WHERE PlayerID="..id);
	
	if (stats) then
		stats[1].Total = tonumber(stats[1].Total);
		stats[1].Stupid = tonumber(stats[1].Stupid);
		stats[1].Percentage = "0%";
		
		return stats[1];
	else
		sql.Query("INSERT INTO Fruju_OOCStats VALUES ("..id..", "..sql.SQLStr(ply:Nick())..", 0, 0)");
		
		return { Name = ply:Nick(), Total = 0, Stupid = 0, Percentage = "0%" };
	end
end

function Chat.GetOOCPercentage(total, stupid)
	local percentage = stupid / total;
	
	if (!total) then
		percentage = 0;
	end
	
	percentage = percentage * 10000;
	percentage = math.Round(percentage);
	percentage = percentage / 100;
	
	return percentage.."%";
end

function Chat.GetAllOOCStats()
	Chat.OOCStat = Chat.OOCStat or {};
	
	local result = sql.Query("SELECT PlayerID, Total, Stupid, Name FROM Fruju_OOCStats");
	
	if (result) then
		for _, stat in pairs (result) do
			Chat.OOCStat[stat.PlayerID] = { Name = stat.Name, Total = tonumber(stat.Total), Stupid = tonumber(stat.Stupid), Percentage = Chat.GetOOCPercentage(tonumber(stat.Total), tonumber(stat.Stupid)) };
		end
	end
end
hook.Add("Initialize", "Chat.GetAllOOCStats", Chat.GetAllOOCStats);

Chat.OOCColumns = {};
Chat.OOCColumns[1] = { ID = 'Name', Name = 'Player Name' };
Chat.OOCColumns[2] = { ID = 'Total', Name = 'Total OOC' };
Chat.OOCColumns[3] = { ID = 'Stupid', Name = 'Stupid OOC' };
Chat.OOCColumns[4] = { ID = 'Percentage', Name = 'Percentage' };

function Chat.DisplayStat(ply)
	Chat.OOCStat = Chat.OOCStat or {};

	-- Get the max width of each field
	local columns = {};
	local data = {};
	
	local footer = {};
	local fTotal = 1;
	local fStupid = 1;
	local fPercent = 1;
	
	-- Create the columns
	for id, column in pairs (Chat.OOCColumns) do
		columns[id] = {};
		columns[id].Header = column.Name;
		columns[id].Width = column.Name:len() + 3;
		columns[id].ID = column.ID;
	end
	
	-- Get their data
	for unique, stat in pairs (Chat.OOCStat) do
		for id, column in pairs (columns) do
			data[unique] = data[unique] or {};
			data[unique][id] = stat[column.ID]; 
			
			local len = string.len(tostring(stat[column.ID])) + 3;
			
			if (len > column.Width) then
				columns[id].Width = len;
			end
			
			if (column.ID == "Total") then
				footer[id] = (footer[id] or 0) + stat[column.ID];
				fTotal = id;
			elseif (column.ID == "Stupid") then
				fStupid = id;
				footer[id] = (footer[id] or 0) + stat[column.ID];
			elseif (column.ID == "Percentage") then
				fPercent = id;
			elseif (column.ID == "Name") then
				footer[id] = "Total"
			end
		end
	end
	
	-- Get the total percentage
	if (footer[fTotal] && footer[fStupid]) then
		local percentage = footer[fStupid] / footer[fTotal];
		
		if (!footer[fTotal]) then
			percentage = 0;
		end
		
		percentage = percentage * 10000;
		percentage = math.Round(percentage);
		percentage = percentage / 100;
		footer[fPercent] = tostring(percentage).."%";
	else
		footer = { "Total", 0, 0, "0%" };
	end
	
	-- Get the total width
	local totalWidth = 5;
	
	for _, column in pairs (columns) do
		totalWidth = totalWidth + column.Width;
	end
	
	-- Display it all
	local divider = '';
	
	for i = 1, totalWidth do
		divider = divider .. '-';
	end
	
	-- Header
	local line = '|';
	
	for _, column in pairs (columns) do
		local extraWidth = column.Width - (string.len(tostring(column.Header)) + 3);
		
		line = line .. ' ' .. column.Header .. '  ';
					
		for i = 1, extraWidth do
			line = line .. " ";
		end
		
		line = line .. "|";
	end
	
	ply:PrintMessage(HUD_PRINTCONSOLE, divider);
	ply:PrintMessage(HUD_PRINTCONSOLE, line);
	ply:PrintMessage(HUD_PRINTCONSOLE, divider);
	
	-- Data
	for _, stats in pairs (data) do
		local line = '|';
		
		for id, stat in pairs (stats) do
			local extraWidth = columns[id].Width - (string.len(tostring(stat)) + 3);
			
			line = line .. " " .. stat .. "  ";
			
			for i = 1, extraWidth do
				line = line .. " ";
			end
			
			line = line .. "|";
		end
		
		ply:PrintMessage(HUD_PRINTCONSOLE, line);
	end
	
	-- Footer
	local line = '|';
		
	for id, stat in pairs (footer) do
		local extraWidth = columns[id].Width - (string.len(tostring(stat)) + 3);
		
		line = line .. " " .. stat .. "  ";
		
		for i = 1, extraWidth do
			line = line .. " ";
		end
		
		line = line .. "|";
	end
	
	ply:PrintMessage(HUD_PRINTCONSOLE, divider);
	ply:PrintMessage(HUD_PRINTCONSOLE, line);
	ply:PrintMessage(HUD_PRINTCONSOLE, divider);
end
concommand.Add("oocstat", Chat.DisplayStat);

// Whisper
function Chat.Whisper (ply, command, args)
	if (ply.Muted) then
		ply:Hint('You are muted and as such can not talk.')
		return
	end

	local text = string.Trim(string.Implode(' ', args))
	local recipients = RecipientFilter()
	
	for _, tgt in pairs (player.GetAll()) do
		if (ply:GetPos():Distance(tgt:GetPos()) <= Config.WhsiperDistance) then
			recipients:AddPlayer(tgt)
		end
	end
	
	Chat.Send(Config.ChatType.Whisper, '[Whisper] '..ply:Nick()..':', text, recipients)
	Log.Add(ply, '[Whisper] '..text)
end
Chat.AddCommand('w', Chat.Whisper, 0, '', true)

// Job
function Chat.Job (ply, command, args)
	local job = string.Trim(string.Implode(' ', args));
	
	if (type(job) != 'string' || string.len(job) < Config.MinJobLength || string.len(job) > Config.MaxJobLength) then
		ply:Hint('Please enter a job between '..Config.MinJobLength..' and '..Config.MaxJobLength..' characters.');
	elseif (ply.Cop) then
		ply:Hint("To quit the police please type /quit.");
	else
		ply:SetJob(job);
		Chat.Send(Config.ChatType.Announcement, '[Announcement]', ply:Nick()..' has changed their job to "'..job..'".');
		Log.Add(ply, 'Set their job to '..job..'.');
	end
end
Chat.AddCommand('job', Chat.Job, 1, '/job <job>')

// Drop
local dropTime = {}
function Chat.Drop (ply, command, args)
	-- Check if the player is alive
	if (!ply:Alive()) then return end
	
	// Get the amount to be dropped
	local amount = tonumber(args[1])
	if (type(amount) != 'number') then return end
	
	// Check the amount is valid
	if (amount <= 0) then
		ply:Hint('You must drop more than $0.00.')
		return
	end
	
	local money = ply:GetMoney()
	
	// Check the player can afford to drop it
	if (money - amount < 0) then
		ply:Hint('You can\'t afford to drop this much.')
		return
	end
	
	// Check the cool time is over
	local time = CurTime() - (dropTime[ply:UniqueID()] or -Config.MoneyDelay)
	if (time < Config.MoneyDelay) then
		time = math.ceil(Config.MoneyDelay - time)
		local second = 'seconds'
		if (time == 1) then second = 'second' end
		
		ply:Hint('Please wait '..time..' '..second..' before dropping more money.')
		return
	end
	
	// Let the player drop the money
	ply:SetMoney(money - amount)
	dropTime[ply:UniqueID()] = CurTime()
	
	// Get the pos
	local tr = ply:Target(80)
	
	// Create the entity
	local money = ents.Create('fruju_money')
	money:SetMoney(amount)
	money:SetModel('models/props/cs_assault/money.mdl')
	money:SetPos(tr.HitPos + tr.HitNormal * 16)
	money:Spawn()
	
	Log.Add(ply, 'Dropped '..Fruju.FormatMoney(amount)..'.')
end
Chat.AddCommand('drop', Chat.Drop, 1, '/drop <amount>')

// Give
function Chat.Give (ply, command, args)
	-- Check if the player is alive
	if (!ply:Alive()) then return end

	// Get the amount to be given
	local amount = tonumber(args[1])
	if (type(amount) != 'number') then return end
	
	// Check the amount is valid
	if (amount <= 0) then
		ply:Hint('You must give more than $0.00.')
		return
	end
	
	local money = ply:GetMoney()
	
	// Check the player can afford to drop it
	if (money - amount < 0) then
		ply:Hint('You can\'t afford to give this much.')
		return
	end
	
	// Get the target
	local target = ply:Target(100).Entity
	
	if (!target || !target:IsPlayer()) then
		ply:Hint('You need to look at a player to give them money.')
		return
	end
	
	// Give to
	ply:SetMoney(money - amount)
	target:SetMoney(target:GetMoney() + amount)
	
	ply:Hint('You gave '..target:Nick()..' '..Fruju.FormatMoney(amount)..'.')
	target:Hint('You recieved '..Fruju.FormatMoney(amount)..' from '..ply:Nick()..'.')
	
	Log.Add(ply, 'Gave '..target:Nick()..' '..Fruju.FormatMoney(amount)..'.')
end
Chat.AddCommand('give', Chat.Give, 1,'/give <amount>')

// Votecop
function Chat.Votecop (ply, command, args)
	// Check if the player is a cop
	if (ply.Cop) then
		ply:Hint('You are already a police officer.')
		return
	end
	
	// Check if the ratio has been breached
	local cops = 0
	local players = 0
	local voters = {}
	
	for _, plyr in pairs (player.GetAll()) do
		players = players + 1
		
		if (plyr.Cop) then cops = cops + 1 end
		if (ply != plyr) then table.insert(voters, plyr) end 
	end
	
	if (cops / players > Config.PoliceRatio) then
		ply:Hint('There is already enough police officers.')
		return
	end
	
	// Create a vote
	if (!Vote.Create(ply, 'Should '..ply:Nick()..' be a police officer?', {'Yes', 'No'}, voters, Police.Vote)) then return end
	Chat.Send(Config.ChatType.Announcement, '[Announcement]', ply:Nick()..' wants to become a police officer.')
	
	Log.Add(ply, 'Started a vote to become a police officer.')
end
Chat.AddCommand('votecop', Chat.Votecop, 0, '/votecop')

// Kick cop
function Chat.Kickcop (ply, command, args)
	local tgt = Fruju.FindPlayer(string.Trim(args[1]))
	
	if (!tgt || !tgt:IsPlayer()) then
		ply:Hint('Unable to find the player.')
		return
	end
	
	if (tgt == ply) then
		ply:Hint('Type /quit to quit your job.')
		return
	end
	
	if (!tgt.Cop) then
		ply:Hint(tgt:Nick()..' isn\'t a cop.')
		return
	end
	
	local voters = {};
	
	for _, plyr in pairs (player.GetAll()) do
		if (tgt != plyr) then table.insert(voters, plyr) end 
	end
	
	// Create a vote
	if (!Vote.Create(tgt, 'Should '..tgt:Nick()..' be removed from the police?', {'Yes', 'No'}, voters, Police.Kick)) then return end
	Chat.Send(Config.ChatType.Announcement, '[Announcement]', ply:Nick()..' wants to kick '..tgt:Nick()..' from the police.')
	
	Log.Add(ply, 'Started a vote to kick '..tgt:Nick()..' from the police.')
end
Chat.AddCommand('kickcop', Chat.Kickcop, 0, '/kickcop')

// Quit
function Chat.Quit (ply, command, args)
	if (ply:GetJob() == Config.DefaultJob) then
		ply:Hint('You don\'t currently have a job.')
		return
	end
	
	if (ply.Cop) then ply:SetCop(false) end
	ply:SetJob(Config.DefaultJob)
	Chat.Send(Config.ChatType.Announcement, '[Announcement]', ply:Nick()..' has quit their job.')
	
	Log.Add(ply, 'Quit their job.')
end
Chat.AddCommand('quit', Chat.Quit, 0, '/quit')

// Sleep
function Chat.Sleep (ply, command, args)
	-- Check if the player is alive
	if (!ply:Alive()) then return end
	
	if (ply.SleepForced) then
		ply:Hint('You would have got away with it if it wasn\'t for this meddling script.')
		return
	end

	// Check if the player is sleeping
	if (ply.SleepTime) then
		local time = CurTime() - ply.SleepTime
		if (time < Config.SleepTime) then
			time = math.ceil(Config.SleepTime - time)
			local second = 'seconds'
			if (time == 1) then second = 'second' end
			
			ply:Hint('Please wait '..time..' '..second..' before waking.')
			return
		end
		
		ply:Wake()
		if (ply.DoLoadout) then
			ply:UpdateLoadout()
		else
			ply:RestoreWeapons()
		end
		ply.SleepTime = nil
		
		Log.Add(ply, 'Fell asleep')
	else
		ply:StoreWeapons()
		ply:Sleep()
		ply.SleepTime = CurTime()
		
		Log.Add(ply, 'Woke from their sleep.')
	end
end
Chat.AddCommand('sleep', Chat.Sleep, 0, '/sleep')

// Letter
local letterTime = {}
function Chat.Letter (ply, command, args)
	-- Check the player is alive
	if (!ply:Alive()) then return end

	// Get the letter
	local text = string.Implode(' ' , args)
	if (type(text) != 'string') then return end
	
	// Check the letter has some length
	if (string.len(text) < 3) then
		ply:Hint('Letters should be over 3 characters.')
		return
	end
	
	local money = ply:GetMoney()
	
	// Check the player can afford this
	if (money - 5 < 0) then
		ply:Hint('You can\'t afford to write this letter.')
		return
	end
	
	// Check the cool time is over
	local time = CurTime() - (letterTime[ply:UniqueID()] or -Config.LetterDelay)
	if (time < Config.LetterDelay) then
		time = math.ceil(Config.LetterDelay - time)
		local second = 'seconds'
		if (time == 1) then second = 'second' end
		
		ply:Hint('Please wait '..time..' '..second..' before writing another letter.')
		return
	end
	
	// Let the player drop the money
	ply:SetMoney(money - 5)
	letterTime[ply:UniqueID()] = CurTime()
	
	// Get the pos
	local tr = ply:Target(80)
	
	// Create the entity
	local letter = ents.Create('fruju_letter')
	letter.Letter = text
	letter.Writer = ply:Nick()..' ('..ply:SteamID()..')'
	letter:SetModel('models/props_c17/paper01.mdl')
	letter:SetPos(tr.HitPos + tr.HitNormal * 16)
	letter:Spawn()
	
	Log.Add(ply, 'Wrote a letter saying: '..text)
end
Chat.AddCommand('letter', Chat.Letter, 1, '/letter <text>', true)

// Model
function Chat.Model (ply, command, args)
	-- Check the player is alive
	if (!ply:Alive()) then return end

	ply:Freeze(true)
	
	umsg.Start('umsg', ply)
	umsg.String('Fruju.Model')
	umsg.End()
end
--Chat.AddCommand('model', Chat.Model, 0, '/model')

// Me
function Chat.Me (ply, command, args)
	Chat.Send(Config.ChatType.Action, '*'..ply:Nick(), string.Trim(string.Implode(' ', args)))
	Log.Add(ply, '*'..string.Trim(string.Implode(' ', args)))
end
Chat.AddCommand('me', Chat.Me, 1, '/me <action>', true)
hook.Remove('PlayerSay', 'ULXMeCheck')

// Private
function Chat.Private (ply, command, args)
	local tgt = Fruju.FindPlayer(string.Trim(args[1]))
	
	if (!tgt || !tgt:IsPlayer()) then
		ply:Hint('Unable to find the specified player.')
		return
	end
	
	if (tgt == ply) then
		ply:Hint('Don\'t talk to yourself...')
		return
	end
	
	table.remove(args, 1)
	local message = string.Trim(string.Implode(' ', args))
	
	Chat.Send(Config.ChatType.Private, '[Private] '..ply:Nick()..' to you: ', message, tgt)
	Chat.Send(Config.ChatType.Private, '[Private] You to '..tgt:Nick()..': ', message, ply)
	
	Log.Add(ply, '[Private] to '..tgt:Nick()..': '..message)
end
Chat.AddCommand('p', Chat.Private, 2, '/p <name> <message>', true)

// Givekey
function Chat.GiveKey (ply, command, args)
	local tgt = ply:Target().Entity
	
	if (!tgt || !tgt:IsValid() || !tgt:IsProperty()) then 
		ply:Hint('You need to look at a property to do this.')
		return 
	end
	
	if (!tgt:IsOwner(ply)) then
		ply:Hint('You need to own this property before you can hand out keys for it.')
		return
	end
	
	local plyr = Fruju.FindPlayer(string.Trim(args[1]))
	
	if (!plyr || !plyr:IsPlayer()) then
		ply:Hint('Unable to find the specified player.')
		return
	end 
	
	if (tgt:IsOwner(plyr)) then
		ply:Hint(plyr:Nick()..' already has a key to this property.')
		return
	end
	
	tgt:AddOwner(plyr)
	ply:Hint(plyr:Nick()..' now has a key to this property.')
	Log.Add(ply, 'Gave '..tgt:Nick()..' a key to their property.')
end
Chat.AddCommand('givekey', Chat.GiveKey, 1, '/givekey <name>')

// Takekey
function Chat.TakeKey (ply, command, args)
	local tgt = ply:Target().Entity
	
	if (!tgt || !tgt:IsValid() || !tgt:IsProperty()) then 
		ply:Hint('You need to look at a property to do this.')
		return 
	end
	
	if (!tgt:IsOwner(ply)) then
		ply:Hint('You need to own this property before you can take keys for it.')
		return
	end
	
	local plyr = Fruju.FindPlayer(string.Trim(args[1]))
	
	if (!plyr || !plyr:IsPlayer()) then
		ply:Hint('Unable to find the specified player.')
		return
	end 
	
	if (!tgt:IsOwner(plyr)) then
		ply:Hint(plyr:Nick()..' doesn\'t have a key to this property.')
		return
	end
	
	tgt:RemoveOwner(plyr)
	ply:Hint(plyr:Nick()..' no longer has a key to this property.')
	Log.Add(ply, 'Took '..tgt:Nick()..'\'s key to their property.')
end
Chat.AddCommand('takekey', Chat.TakeKey, 1, '/takekey <name>')