AddCSLuaFile('shared.lua')
AddCSLuaFile('cl_init.lua')

include('shared.lua')

function Clock.InitialSpawn(ply)
	timer.Simple(2, function() Clock.Send(ply) end)
end
hook.Add("PlayerInitialSpawn", "Clock.InitialSpawn", Clock.InitialSpawn);

function Clock.Send (ply)
	umsg.Start('Clock.Send', ply)
		umsg.Float(Clock.GetTime() or 0)
		umsg.Char(Clock.Day or 1)
	umsg.End()
end
concommand.Add('Clock.Request', Clock.Send)
