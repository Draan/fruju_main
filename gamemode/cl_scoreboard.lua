function Fruju.Scoreboard ()
	if (!input.IsKeyDown(KEY_TAB)) then return end

	surface.SetFont('FrujuFontSmall')
	local w, lh = surface.GetTextSize('W')
	
	local citizens = false
	local police = false
	local criminals = false
	local levels = {}
	local name_width = 0
	local level_width = 0
	local job_width = 0
	
	// Get the width of the scoreboard
	for _, ply in pairs (player.GetAll()) do
		levels[ply:EntIndex()] = ply:FormatLevel()
		local w = surface.GetTextSize(ply:Nick())
		
		if (w > name_width) then
			name_width = w
		end
		
		w = surface.GetTextSize(levels[ply:EntIndex()])
		
		if (w > level_width) then
			level_width = w
		end
		
		w = surface.GetTextSize(ply:GetJob())
		
		if (w > job_width) then
			job_width = w
		end
		
		if (ply.Criminal) then
			if (!criminals) then criminals = {} end
			table.insert(criminals, ply)
		elseif (ply.Cop) then
			if (!police) then police = {} end
			table.insert(police, ply)
		else 
			if (!citizens) then citizens = {} end
			table.insert(citizens, ply) 
		end
	end
	
	local titleh = 0
	
	if (criminals) then
		local w = surface.GetTextSize('Citizens')
		
		if (w > name_width) then
			name_width = w
		end
		
		titleh = titleh + lh + 5
		table.sort(criminals, function (a, b) return a:GetRating() > b:GetRating() end)
	end
	
	if (citizens) then
		local w = surface.GetTextSize('Criminals')
		
		if (w > name_width) then
			name_width = w
		end
		
		titleh = titleh + lh + 5
		table.sort(citizens, function (a, b) return a:GetRating() > b:GetRating() end)
	end
	
	if (police) then
		local w = surface.GetTextSize('Police Officers')
		
		if (w > name_width) then
			name_width = w
		end
		
		titleh = titleh + lh + 5
		table.sort(police, function (a, b) return a:GetRating() > b:GetRating() end)
	end
	
	w = surface.GetTextSize('Level')
		
	if (w > level_width) then
		level_width = w
	end
	
	// Draw
	local width = name_width + level_width + job_width + surface.GetTextSize('Ping') + 170
	
	local w = ScrW() / 3
	if (width > w) then w = width end
	
	local h = (table.Count(player.GetAll()) * lh) + titleh
	local x = (ScrW() - w) / 2
	local y = (ScrH() - h) / 2
	
	draw.RoundedBox(4, x, y, w, h, Color(0, 0, 0, 100))
	
	x = x + 5
	
	// Citizens
	if (citizens) then
		draw.SimpleText('Citizens', 'FrujuFontSmall', x, y, green, 0, 3)
		draw.SimpleText('Level', 'FrujuFontSmall', x + name_width + 50, y, green, 0, 3)
		draw.SimpleText('Job', 'FrujuFontSmall', x + name_width + level_width + 100, y, green, 0, 3)
		draw.SimpleText('Ping', 'FrujuFontSmall', x + name_width + level_width + job_width + 150, y, green, 0, 3)
		draw.RoundedBox(0, x, y+lh, w-10, 1, green)
		
		y = y + lh + 5
		
		for _, ply in pairs (citizens) do
			draw.SimpleText(ply:Nick(), 'FrujuFontSmall', x, y, white, 0, 3)
			draw.SimpleText(levels[ply:EntIndex()], 'FrujuFontSmall', x + name_width + 50, y, white, 0, 3)
			draw.SimpleText(ply:GetJob(), 'FrujuFontSmall', x + name_width + level_width + 100, y, white, 0, 3)
			draw.SimpleText(ply:Ping(), 'FrujuFontSmall', x + name_width + level_width + job_width + 150, y, white, 0, 3)
			y = y + lh
		end
	end
	
	// Police
	if (police) then
		draw.SimpleText('Police Officers', 'FrujuFontSmall', x, y, blue, 0, 3)
		draw.SimpleText('Level', 'FrujuFontSmall', x + name_width + 50, y, blue, 0, 3)
		draw.SimpleText('Job', 'FrujuFontSmall', x + name_width + level_width + 100, y, blue, 0, 3)
		draw.SimpleText('Ping', 'FrujuFontSmall', x + name_width + level_width + job_width + 150, y, blue, 0, 3)
		draw.RoundedBox(0, x, y+lh, w-10, 1, blue)
		
		y = y + lh + 5
		
		for _, ply in pairs (police) do
			draw.SimpleText(ply:Nick(), 'FrujuFontSmall', x, y, white, 0, 3)
			draw.SimpleText(levels[ply:EntIndex()], 'FrujuFontSmall', x + name_width + 50, y, white, 0, 3)
			draw.SimpleText(ply:GetJob(), 'FrujuFontSmall', x + name_width + level_width + 100, y, white, 0, 3)
			draw.SimpleText(ply:Ping(), 'FrujuFontSmall', x + name_width + level_width + job_width + 150, y, white, 0, 3)
			y = y + lh
		end
	end
	
	// Criminals
	if (criminals) then
		draw.SimpleText('Criminals', 'FrujuFontSmall', x, y, red, 0, 3)
		draw.SimpleText('Level', 'FrujuFontSmall', x + name_width + 50, y, red, 0, 3)
		draw.SimpleText('Job', 'FrujuFontSmall', x + name_width + level_width + 100, y, red, 0, 3)
		draw.SimpleText('Ping', 'FrujuFontSmall', x + name_width + level_width + job_width + 150, y, red, 0, 3)
		draw.RoundedBox(0, x, y+lh, w-10, 1, red)
		
		y = y + lh + 5
		
		for _, ply in pairs (criminals) do
			draw.SimpleText(ply:Nick(), 'FrujuFontSmall', x, y, white, 0, 3)
			draw.SimpleText(levels[ply:EntIndex()], 'FrujuFontSmall', x + name_width + 50, y, white, 0, 3)
			draw.SimpleText(ply:GetJob(), 'FrujuFontSmall', x + name_width + level_width + 100, y, white, 0, 3)
			draw.SimpleText(ply:Ping(), 'FrujuFontSmall', x + name_width + level_width + job_width + 150, y, white, 0, 3)
			y = y + lh
		end
	end
	
	return false
end
hook.Add('HUDPaint', 'Fruju.Scoreboard', Fruju.Scoreboard)

function GM:CreateScoreboard() return false end
function GM:ScoreboardShow() return false end
function GM:ScoreboardHide() return false end