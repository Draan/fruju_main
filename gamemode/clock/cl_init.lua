include('shared.lua')

Clock.Days = {'Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'}

function Clock.Draw ()
	surface.SetFont('FrujuFontSmall')
	if (Clock.Day == nil) then Clock.Day = 1 end
	local str = string.ToMinutesSeconds(math.ceil(Clock.GetTime()))..' - '..Clock.Days[Clock.Day]
	local w = surface.GetTextSize(str)
	
	draw.SimpleText(str, 'FrujuFontSmall', ScrW() - w - 5, 0, white, 0, 3)
end
hook.Add('HUDPaint', 'Clock.Draw', Clock.Draw)

function Clock.Recieve (umsg)
	local svTime = umsg:ReadFloat();
	local day = umsg:ReadChar();
	
	
	if (!svTime || !day) then return end
	local curTime  = RealTime();
	
	Clock.DayStart = curTime - svTime;
	Clock.Day = day;
end
usermessage.Hook('Clock.Send', Clock.Recieve)

function Clock.Request ()
	local ply = LocalPlayer();
	if (!ply || !ply:IsPlayer()) then return end
	
	RunConsoleCommand('Clock.Request');
end
