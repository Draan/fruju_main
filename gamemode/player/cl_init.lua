 include('shared.lua')

local Player = FindMetaTable('Player')

function Player.UpdateJob (umsg)
	local ply = player.GetByUniqueID(umsg:ReadString())
	local job = umsg:ReadString()
	
	if (!ply || !ply:IsPlayer()) then return end
	
	ply:SetJob(job)
end
usermessage.Hook('Player.Job', Player.UpdateJob)

function Player.UpdateMoney (umsg)
	local ply = player.GetByUniqueID(umsg:ReadString())
	local money = umsg:ReadFloat()
	
	if (!ply || !ply:IsPlayer()) then return end
	
	ply:SetMoney(money)
	
	return true
end
usermessage.Hook('Player.Money', Player.UpdateMoney)

function Player.UpdateCop (umsg)		
	local ply = player.GetByUniqueID(umsg:ReadString())
	local cop = umsg:ReadBool()
	
	if (!ply || !ply:IsPlayer()) then return end
	
	ply:SetCop(cop)
	
	return true
end
usermessage.Hook('Player.Cop', Player.UpdateCop)

function Player.UpdateCriminal (umsg)
	local ply = player.GetByUniqueID(umsg:ReadString())
	local criminal = umsg:ReadBool()
	
	if (!ply || !ply:IsPlayer()) then return end
	
	ply:SetCriminal(criminal)
	
	return true
end
usermessage.Hook('Player.Criminal', Player.UpdateCriminal)

function Player.UpdateRating (umsg)
	local ply = player.GetByUniqueID(umsg:ReadString())
	local rating = umsg:ReadShort()

	if (!ply || !ply:IsPlayer()) then return end
	
	ply:SetRating(rating)
	
	return true
end
usermessage.Hook('Player.Rating', Player.UpdateRating)

function Player:FormatLevel ()	
	local rating = self:GetRating();
	local current = self:GetLevel();
	
	if (!current) then 
		return "Unknown"
	end
	
	local next = Levels[self.Level + 1]
	
	if (!next) then
		return current.Name
	end	
	
	local progress = math.Round(((rating - current.Rating) / (next.Rating - current.Rating)) * 100)
	if (progress > 100) then progress = 100
	elseif (progress < 0) then progress = 0 end
	
	return current.Name..' ('..progress..'%)'
end

function Player.Request (ent)	
	if (!ent || !ent:IsPlayer()) then return end
	local plyID = ent:UniqueID();
	
	RunConsoleCommand('Player.RequestJob', plyID);
	RunConsoleCommand('Player.RequestCriminal', plyID);
	RunConsoleCommand('Player.RequestCop', plyID);
	RunConsoleCommand('Player.RequestRating', plyID);
end
hook.Add('OnEntityCreated', 'Player.Request', Player.Request);

function Player.RequestAll()
	local me = LocalPlayer();
	
	for _, ply in pairs (player.GetAll()) do
		local id = ply:UniqueID();
		
		if (ply == me) then
			RunConsoleCommand('Player.RequestMoney', id);
		end
		
		RunConsoleCommand('Player.RequestJob', id);
		RunConsoleCommand('Player.RequestCriminal', id);
		RunConsoleCommand('Player.RequestCop', id);
		RunConsoleCommand('Player.RequestRating', id);
	end
end
hook.Add('InitPostEntity', 'Player.RequestAll', Player.RequestAll)
