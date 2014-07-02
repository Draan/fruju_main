Fruju.Version = '2.00'
Fruju.Date = '21/01/2011'

Fruju.RulesText = {
	'No death matching (Killing without a reason or for fun).',
	'No requests for administrator rights.',
	'No flooding the chat.',
	'No discriminative/offensive comments.',
	'No flooding items (Money, Letters, Entities etc).',
	'Suiciding while arrested is not allowed.',
	'No abusing cop abilities (guns, door ram etc).',
	'English only in chat/voice.',
	'Do not bug admins for useless things.',
	'Follow the new life rule.'
}

Fruju.CommandsText = {}
Fruju.CommandsText['/job <job>'] = 'Set your job to the specified job.'
Fruju.CommandsText['/model'] = 'Change your model.'
Fruju.CommandsText['/give <amount>'] = 'Give the player you are looking at money.'
Fruju.CommandsText['/drop <amount>'] = 'Drop the specified amount.'
Fruju.CommandsText['/me <action>'] = 'Perform an action.'
Fruju.CommandsText['/ooc, ooc, //'] = 'Chat in out of character chat.'
Fruju.CommandsText['/w <message>'] = 'Whisper.'
Fruju.CommandsText['/votecop'] = 'Vote to become a police officer.'
Fruju.CommandsText['/kickcop <name>'] = 'Vote to kick a police officer.'
Fruju.CommandsText['/sleep'] = 'Sleep or wake up.'
Fruju.CommandsText['/letter <message>'] = 'Write a letter.'
Fruju.CommandsText['/p <name> <message>'] = 'Send a private message.'
Fruju.CommandsText['/quit'] = 'Quit your job.'

Fruju.Logos = {
	{tex = surface.GetTextureID('fruju/script'), w = 91},
	{tex = surface.GetTextureID('fruju/chiz'), w = 100},
	{tex = surface.GetTextureID('fruju/sub'), w = 128}
}

function Fruju.ToggleHelp (key)	
	if (key != KEY_F1) then return end
	
	Fruju.DisplayHelp = !Fruju.DisplayHelp
	Fruju.HelpDelay = CurTime()
end
hook.Add('KeyPressed', 'Fruju.ToggleHelp', Fruju.ToggleHelp)

function Fruju.Help ()
	if (!Fruju.DisplayHelp) then return end
	
	local w = ScrW() - 100
	local h = ScrH() - 150
	local x = (ScrW() - w) / 2
	local y = 100
	
	// Rules
	local rw = (w / 2) - 2
	local rh = h - 100
	local ry = y
	
	draw.RoundedBox(4, x, y, rw, rh, Color(0, 0, 0, 100))
	
	surface.SetFont('FrujuFont')
	local _, lh = surface.GetTextSize('Rules')
	
	draw.SimpleText('Rules', 'FrujuFont', x+5, ry, purple, 0, 3)
	draw.RoundedBox(0, x+5, ry+lh, rw-10, 1, purple, 0, 3)
	
	surface.SetFont('FrujuFontSmall')
	
	ry = ry + lh + 5
	
	for i, rule in pairs (Fruju.RulesText) do
		local w = surface.GetTextSize(i..': ')
		draw.SimpleText(i..': ', 'FrujuFontSmall', x+5, ry, blue, 0, 3)
		
		for _, line in pairs (string.Explode('//', string.Wrap(rule, 'FrujuFontSmall', rw-w-10))) do 
			if (string.sub(line, 1, 1) == '/') then line = string.sub(line, 2) end
			draw.SimpleText(line, 'FrujuFontSmall', x+w+5, ry, white, 0, 3)
			local _, lh = surface.GetTextSize(line)
			ry = ry + lh
		end	
	end
	
	// Help
	local hx = x + rw + 5
	local hy = y
	
	draw.RoundedBox(4, hx, y, rw, rh, Color(0, 0, 0, 100))
	
	surface.SetFont('FrujuFont')
	local _, lh = surface.GetTextSize('Commands')
	
	draw.SimpleText('Commands', 'FrujuFont', hx+5, hy, green, 0, 3)
	draw.RoundedBox(0, hx+5, hy+lh, rw-10, 1, green, 0, 3)
	
	surface.SetFont('FrujuFontSmall')
	
	hy = hy + lh + 5
	
	for command, help in pairs (Fruju.CommandsText) do
		local w = surface.GetTextSize(command..' ')
		draw.SimpleText(command, 'FrujuFontSmall', hx+5,  hy, blue, 0, 3)
		
		for _, line in pairs (string.Explode('//', string.Wrap(help, 'FrujuFontSmall', rw-w-10))) do 
			if (string.sub(line, 1, 1) == '/') then line = string.sub(line, 2) end
			draw.SimpleText(line, 'FrujuFontSmall', hx+w+5, hy, white, 0, 3)
			local _, lh = surface.GetTextSize(line)
			hy =  hy + lh
		end	
	end
	
	// About
	local ay = y + rh + 5
	local ah = 100
	
	draw.RoundedBox(4, x, ay, rw, ah, Color(0, 0, 0, 100))
	
	surface.SetFont('FrujuFont')
	local _, lh = surface.GetTextSize('Fruju Script')
	
	draw.SimpleText('Fruju Script', 'FrujuFont', x+5, ay, red, 0, 3)
	draw.RoundedBox(0, x+5, ay+lh, rw-10, 1, red, 0, 3)
	
	surface.SetFont('FrujuFontSmall')
	
	ay = ay + lh + 5
	
	local _, lh = surface.GetTextSize('W')
	
	draw.SimpleText('Version: '..Fruju.Version, 'FrujuFontSmall', x+5, ay, white, 0, 3)
	draw.SimpleText('Date: '..Fruju.Date, 'FrujuFontSmall', x+5, ay+lh, white, 0, 3)
	
	// Logos
	draw.RoundedBox(4, hx, y + rh + 5, rw, ah, Color(0, 0, 0, 100))
	
	surface.SetDrawColor(255, 255, 255, 255)
	
	local tx = hx+20
	local tc =  y+rh+55
	
	for i, data in pairs (Fruju.Logos) do
		surface.SetTexture(data.tex)
		local w, h = surface.GetTextureSize(data.tex)
		
		surface.DrawTexturedRect(tx - (128 - data.w), tc - (h / 2), h, w)
		tx = tx + data.w + 5
	end
end
hook.Add('HUDPaint', 'Fruju.Help', Fruju.Help)

local HELP = {}

function HELP:Init ()
	
end