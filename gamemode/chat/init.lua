AddCSLuaFile('cl_init.lua')

Chat = {}
Chat.Commands = {}
Chat.AdminCommands = {}

// Intercept commands
function Chat.Intercept (ply, text, team)
	if (gamemode.Call('InterceptChat', ply, text, team) == false) then return '' end
	
	Chat.Send(Config.ChatType.Normal, ply:Nick()..':', text)
	Log.Add(ply, '[Chat] '..text)
	
	return ''
end
hook.Add('PlayerSay', 'Chat.Intercept', Chat.Intercept)

function GM:InterceptChat (ply, text)
	// Check if it is a command
	if (string.sub(text, 1, 1) == Config.CommandPrefix) then
		Chat.Command (ply, text)
		return false
	elseif (string.sub(text, 1, 1) == Config.AdminPrefix) then
		Chat.Command (ply, text, Chat.AdminCommands)
		return false
	end
end

// Send chat
function Chat.Send (type, prefix, text, recipient)
	if (!recipient) then
		recipient = RecipientFilter()
		recipient:AddAllPlayers()
	end
	
	umsg.Start('Chat', recipient)
		umsg.Char(type)
		umsg.String(prefix)
		umsg.String(text)
	umsg.End()
	
	-- Let the server know, except the stupid stuff
	if (type != Config.ChatType.Announcement or type != Config.ChatType.Hint) then
		print(prefix..' '..text);
	end
end

// Handle commands
function Chat.Command (ply, text, tbl)
	if (!tbl) then tbl = Chat.Commands end

	// Find the command
	for _, data in pairs (tbl) do
		if (string.sub(text, 2, string.len(data.Command) + 1) == data.Command) then
			-- Get the arguments
			local args = Chat.GetArguments(data.Command, text, false, data.IgnoreQuotes)
			
			if (table.Count(args) < data.Args) then
				ply:Hint('The correct syntax for this command is: '..data.Syntax)
				return
			end
			
			if (gamemode.Call('ChatCommand', ply, data.Command, args, tbl) != false) then
				pcall(data.Function, ply, data.Command, args)
			end
			
			return
		end
	end
	
	ply:Hint('Unable to find the specified command.')
end

function GM:ChatCommand (ply, command, args, tbl) 
	local level = ply:GetLevel()
	
	if (!level) then 
		ply:Hint('You do not have permission to use this command.')
		return false
	end

	local commands = level.Commands
	if (tbl == Chat.AdminCommands) then 
		commands = level.AdminCommands
	end

	if (!commands) then
		ply:Hint('You do not have permission to use this command.')
		return false
	end
	
	if (type(commands) != 'boolean' && !commands[command]) then
		ply:Hint('You do not have permission to use this command.')
		return false
	end
	
	return true
end

// Register command
function Chat.AddCommand (command, func, args, syntax, ignoreQuotes, admin)
	if (type(command) != 'string') then return end
	if (type(func) != 'function') then return end
	
	args = args or 0
	syntax = syntax or 0
	
	local data = {}
	data.Function = func
	data.Args = args
	data.Syntax = syntax
	data.IgnoreQuotes = ignoreQuotes
	data.Command = command
	
	if (admin) then
		table.insert(Chat.AdminCommands, data)
		table.sort(Chat.AdminCommands, function (a, b) return string.len(a.Command) > string.len(b.Command) end)
	else
		table.insert(Chat.Commands, data)
		table.sort(Chat.Commands, function (a, b) return string.len(a.Command) > string.len(b.Command) end)
	end	
	
end

// Get arguments
function Chat.GetArguments (command, text, keepFirstArg, ignoreQuotes)
	// Get the arguments
	local quote = -1
	local space = -1
	local args = {}
	command = command or ''
	
	if (!ignoreQuotes) then
		for i=1, string.len(text) do
			// Quote
			if (string.sub(text, i, i) == '"') then
				space = -1
				
				if (quote != -1) then
					// Get rid of white space and quotes
					local temp = string.sub(text, quote, i)
					temp = string.Trim(temp)
					temp = string.Replace(temp, '"', '')
					
					table.insert(args, temp)
					quote = -1
				else
					// Start an argument
					quote = i
				end
			elseif (i == 1) then
				// Start string
				space = 1
			end

			// Space
			if (quote == -1) then
				if (string.sub(text, i, i) == ' ') then
					if (space != -1) then
						// Get rid of white space and quotes
						local temp = string.sub(text, space, i)
						temp = string.Trim(temp)
						temp = string.Replace(temp, '"', '')
						
						table.insert(args, temp)
						space = i
					else
						// Start an argument
						space = i
					end
				end
			end
			
			// End of string
			if (i == string.len(text)) then
				if (quote != -1) then
					local temp = string.sub(text, quote, i)
					temp = string.Trim(temp)
					temp = string.Replace(temp, '"', '')
					
					table.insert(args, temp)
				elseif (space != -1) then
					local temp = string.sub(text, space, i)
					temp = string.Trim(temp)
					temp = string.Replace(temp, '"', '')
					
					table.insert(args, temp)
				end
			end
		end
	else
		args = string.Explode(' ', text)
	end
	
	// Remove first argument
	if (!keepFirstArg) then
		if (string.sub(args[1], 2) == command) then
			table.remove(args, 1)
		else
			args[1] = string.sub(args[1], string.len(command) + 2)
		end
	end
	
	return args
end

function Chat.Admin (ply, text)
	local recipients = RecipientFilter()
	
	for _, ply in pairs (player.GetAll()) do
		local level = ply:GetLevel()
		
		if (level && level.AdminCommands && (type(level.AdminCommands) == 'boolean' || level.AdminCommands['@'])) then
			recipients:AddPlayer(ply)
		end
	end
	
	Chat.Send(Config.ChatType.Admin, '[Admin] '..ply:Nick()..':', text, recipients)
end

function Chat.Announcement (ply, text)
	Chat.Send(Config.ChatType.Announcement, '[Announcement] ', text)
end

function Chat.Centre (text)
	PrintMessage(HUD_PRINTCENTER, text)
end