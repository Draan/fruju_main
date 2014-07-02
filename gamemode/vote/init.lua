AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')

include('shared.lua')

function Vote.Create (ply, question, options, voters, complete)
	// Check all fields are valid
	if (!ply || !ply:IsPlayer()) then return end
	if (type(question) != 'string') then return end
	if (type(options) != 'table' || table.Count(options) < 2) then return end
	if (type(complete) != 'function') then return end
	
	// Check if there is an active vote
	if (Vote.Active) then
		if (CurTime() - Vote.StartTime <= Vote.RunTime) then 
			ply:Hint('There is already an active vote.')
			return 
		end
	end

	// Create the new vote
	Vote.Active = true
	Vote.StartTime = CurTime()
	Vote.Options = options
	Vote.Player = ply
	Vote.Function = complete

	// Complete the vote if there is only one voter
	if (table.Count(voters) == 0) then
		Vote.Complete()
		return
	end
	
	for _, voter in pairs (voters) do
		Vote.Voters[voter:UniqueID()] = false
	end
	
	// Send the vote to the clients
	Vote.SendToClients (question, voters)
	return true
end

function Vote.Cancel ()
	Vote.Hide()
	
	Vote.Active = false
	Vote.Options = {}
	Vote.Voters = {}
	Vote.Player= nil
	Vote.Complete = nil
end

function Vote.SendToClients (question, recipients)
	local rf = RecipientFilter()
	
	for _, ply in pairs (recipients) do
		if (ply:Team() != TEAM_CONNECTING) then
			rf:AddPlayer(ply)
		end
	end
	
	umsg.Start('umsg', rf)
	umsg.String('Vote.Display')
		umsg.String(question)
		umsg.Char(table.Count(Vote.Options))
		
		for _, option in pairs (Vote.Options) do
			umsg.String(option)
		end
	umsg.End()
end

function Vote.Hide (recipient)
	if (!recipient) then
		recipient = RecipientFilter()
		recipient:AddAllPlayers()
	end
	
	umsg.Start('umsg', recipient)
		umsg.String('Vote.Hide')
	umsg.End()
end

function Vote.CheckComplete ()
	if (!Vote.Active) then return end
	
	if (CurTime() - Vote.StartTime >= Vote.RunTime) then
		Vote.Complete()
	else
		local votes = 0
		
		for _, vote in pairs (Vote.Voters) do
			if (type(vote) == 'number') then
				votes = votes + 1
			end
		end
		
		if (votes >= table.Count(Vote.Voters)) then
			Vote.Complete()
		end
	end
end
hook.Add('Think', 'Vote.CheckComplete', Vote.CheckComplete)

function Vote.Complete ()	
	Vote.Active = false
	Vote.Hide()
	
	if (!Vote.Player || !Vote.Player:IsPlayer()) then return end
	
	// Count the votes for each option
	local options = {}
	local votes = 0
	
	for i = 1, table.Count(Vote.Options) do
		options[i] = 0
	end
	
	for voter, option in pairs (Vote.Voters) do
		if (option) then
			options[option] = options[option] + 1
			votes = votes + 1
		end
	end
	
	// Run the completion function
	pcall(Vote.Function, votes, options)
	
	// Clear the vote
	Vote.Options = {}
	Vote.Voters = {}
	Vote.Function = nil
	Vote.Player = nil
end

function Vote.Vote (ply, command, args)
	local option = tonumber(args[1])
	
	// Check if there is an active vote
	if (!Vote.Active) then
		ply:Hint('There is currently no active vote.')
		return
	end
	
	// Check whether the player can vote
	if (Vote.Voters[ply:UniqueID()] == nil) then
		ply:Hint('You are not allowed to vote in this vote.')
		return
	end
	
	// Check if the player has already voted
	if (type(Vote.Voters[ply:UniqueID()]) != 'boolean') then
		ply:Hint('You may only vote once.')
		return
	end
	
	// Check if the option is valid
	if (!option || !Vote.Options[option]) then
		ply:Hint('This option is not available.')
		return
	end
	
	// Add their vote
	Chat.Send(Config.ChatType.Announcement, '[Announcement]', ply:Nick()..' voted '..Vote.Options[option]..'.')
	Vote.Voters[ply:UniqueID()] = option
	Vote.Hide(ply)
end
concommand.Add('rp_vote', Vote.Vote)