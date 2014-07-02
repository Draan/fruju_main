function Fruju.Advertise()
	-- Pick a random message
	local message = Config.advertisements[math.random(table.Count(Config.advertisements))];
	
	Chat.Announcement(nil, message);
	
	timer.Simple(Config.advertisementDelay, Fruju.Advertise);
end
hook.Add("Initialize", "Fruju.Advertise", Fruju.Advertise);