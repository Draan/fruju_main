Clock = {}

function Clock.Initialize()
	Clock.Day = 1
	Clock.DayStart = RealTime();
end
hook.Add("Initialize", "Clock.Initialize", Clock.Initialize);

function Clock.CheckDay ()	

if (!Clock.Day) then return end

	-- Check if the day has ended
	if (Clock.GetTime() >= 1440) then
		Clock.DayStart = RealTime();
		
		if (Clock.Day == 7) then
			Clock.Day = 1
		else
			Clock.Day = Clock.Day + 1
		end
	
		if (SERVER) then 
			Fruju.Payday();
		else
			Clock.Request();
		end
	end
	
	
end
hook.Add('Tick', 'Clock.CheckDay', Clock.CheckDay)

function Clock.GetTime()
	if (Clock.DayStart) then
		return RealTime() - Clock.DayStart;
	else
		return 0;
	end
end