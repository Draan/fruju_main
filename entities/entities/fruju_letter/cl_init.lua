include('shared.lua')

Fruju.LetterTime = -6
Fruju.Letter = nil

function Fruju.LetterDraw ()
	if (!Fruju.Letter || !Fruju.Letter:IsValid()) then return end
	if (!Fruju.Letter.Letter) then return end
	
	if (CurTime() - Fruju.LetterTime > 3) then 
		Fruju.Letter = nil
		return 
	end
	
	local ply = LocalPlayer() 
	if (!ply || !ply:IsPlayer()) then return end
	
	if (ply:GetPos():Distance(Fruju.Letter:GetPos()) > 120) then 
		Fruju.Letter = nil
		return 
	end
	
	local DrawnFirst = false
	
	// Get the size
	local w = ScrW() / 2
	local h = ScrH() / 1.5
	local x = (ScrW() - w) / 2
	local y = (ScrH() - h) / 2
	local oy = y
	
	// Draw the background
	draw.RoundedBox(4, x, y, w, h, Color(0, 0, 0, 100))
	x = x + 5
	
	surface.SetFont('FrujuFontSmall')
	local _, lineh = surface.GetTextSize('A')
	
	// Draw the text
	for num, line in pairs (Fruju.Letter.Letter) do
		if (!DrawnFirst) then
			local tw = surface.GetTextSize(string.upper(string.sub(line, 1, 1)))
			draw.SimpleText(string.upper(string.sub(line, 1, 1)), 'FrujuFontSmall', x, y, blue, 0, 3)
			draw.SimpleText(string.sub(line, 2), 'FrujuFontSmall', x+tw, y, white, 0, 3)
			DrawnFirst = true
		else
			draw.SimpleText(line, 'FrujuFontSmall', x, y, white, 0, 3)
		end
		
		y = y + lineh
	end
	
	// Draw the writer
	local linew, lineh = surface.GetTextSize(Fruju.Letter.Writer or '')
	draw.SimpleText(Fruju.Letter.Writer, 'FrujuFontSmall', (ScrW() - linew) / 2, oy+h-lineh, purple, 0, 3)
end
hook.Add('HUDPaint', 'Fruju.LetterDraw', Fruju.LetterDraw)

function Fruju.RecieveLetter (umsg)	
	local ent = Entity(umsg:ReadShort())
	local writer = umsg:ReadString()
	local letter = umsg:ReadString()
	
	if (!ent || !ent:IsValid()) then return end
	if (!writer) then return end
	if (!letter) then return end
	
	local w = (ScrW() / 1.5) - 10
	
	local lines = string.Explode('//', string.Wrap(letter, 'FrujuFontSmall', w))
	
	for i, line in pairs (lines) do
		if (string.sub(line, 1, 1) == '/') then
			lines[i] = string.sub(line, 2)
		end
	end
	
	ent.Letter = lines
	ent.Writer = writer
	
	return true
end
Network.Hook('Fruju.Letter', Fruju.RecieveLetter)

function Fruju.DrawLetter (umsg)
	Fruju.Letter = Entity(umsg:ReadShort())
	
	if (!Fruju.Letter || !Fruju.Letter:IsValid() || Fruju.Letter:GetClass() != 'fruju_letter') then return end
	
	Fruju.LetterTime = CurTime()

	return true
end
Network.Hook('Fruju.DrawLetter', Fruju.DrawLetter)

function Fruju.RequestLetter (ent)
	if (!ent || !ent:IsValid()) then return end
	if (ent:GetClass() != 'fruju_letter') then return end
	
	RunConsoleCommand('Letter.Request', ent:EntIndex())
end
hook.Add('OnEntityCreated', 'Fruju.RequestLetter', Fruju.RequestLetter)

function ENT.HandIcon(ply, wep)
	local target = ply:Target().Entity;
	
	if (!target || !target:IsValid()) then return end
	if (target:GetClass() != "fruju_letter") then return end
	
	return "letter";
end
hook.Add("HandsHudTexture", "Letter.HandIcon", ENT.HandIcon);