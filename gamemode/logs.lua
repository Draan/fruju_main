Log = {}
Log.Directory = 'Fruju_Logs'

function Log.GetFile ()
	if (!Log.File) then
		Log.CreateFile()
	end
	
	return Log.Directory..'/'..Log.File
end

function Log.CreateFile ()
	if (!file.Exists(Log.Directory, "DATA")) then
		file.CreateDir(Log.Directory)
	end
	
	local now = os.time()
	Log.File = Log.Time(true, now)..'.txt'
	
	if (!file.Exists(Log.Directory..'/'..Log.File, "DATA")) then 
		file.Write(Log.Directory..'/'..Log.File, 'Fruju log file starting '..Log.Time(false, now)..'.\n')
	end
end

function Log.Add (ply, msg)
	local logfile = Log.GetFile()
	local content = file.Read(logfile) or ''
	msg = msg or ''
	
	local prefix = Log.Time()..' - '
	
	if (ply && ply:IsPlayer() && ply:SteamID() != 'STEAM_ID_PENDING') then
		prefix = prefix..ply:SteamID()..' '..ply:Nick()..' '
	end
	
	
	file.Write(logfile, content..prefix..msg..'\n')
end

function Log.Time (file, time)
	local time = os.date('*t', time)

	if (file) then
		return time.day..'_'..time.month..'_'..time.year..' '..time.hour..'-'..time.min
	else
		return time.hour..':'..time.min..':'..time.sec..' '..time.day..'/'..time.month..'/'..time.year
	end
end