Police = {}

function Police.Vote (votes, options)
	// Check if the vote was a success
	if (options[1] / votes < Config.PoliceVoteRatio) then
		Chat.Send(Config.ChatType.Announcement, '[Announcement]', 'It has been decided that '..Vote.Player:Nick()..' shouldn\'t be a police officer.')
		return
	end
	
	// Make the player a police officer
	Vote.Player:SetCop(true)
	Vote.Player:SetJob('Police Officer')
	Chat.Send(Config.ChatType.Announcement, '[Announcement]', Vote.Player:Nick()..' is the newest police officer in town.')
	Log.Add(Vote.Player, 'Became a police officer by a vote (Yes: '..options[1]..' - No: '..options[2]..').')
end

function Police.Kick (votes, options)
	// Check if the vote was a success
	if (options[1] / votes < Config.PoliceVoteRatio) then
		Chat.Send(Config.ChatType.Announcement, '[Announcement]', Vote.Player:Nick()..' is still a police officer.')
		return
	end
	
	//  remove the player from the police
	Vote.Player:SetCop(false)
	Vote.Player:SetJob(Config.DefaultJob)
	Chat.Send(Config.ChatType.Announcement, '[Announcement]', Vote.Player:Nick()..' has been forced to hand in their badge.')
	Log.Add(Vote.Player, 'Was kicked from the police by a vote (Yes: '..options[1]..' - No: '..options[2]..').')
end

function Police.Radio (ply, text, team)
	if (ply.Cop && team) then
		// Get the police
		local police = RecipientFilter()
		for _, plyr in pairs (player.GetAll()) do
			if (plyr.Cop) then
				police:AddPlayer(plyr)
			end
		end	
		
		Chat.Send(Config.ChatType.Radio, '[Radio] '..ply:Nick()..':', text, police)
		Log.Add(ply, '[Police Radio] '..text)
		return false
	end
end
hook.Add('InterceptChat', 'Police.Radio', Police.Radio)