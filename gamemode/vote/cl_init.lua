include('shared.lua')

Vote.GUI = {}

function Vote.Display (umsg)		
	// Get the data
	local question = umsg:ReadString()
	local options = {}
	
	for i = 1, umsg:ReadChar() do
		options[i] = umsg:ReadString()
	end
	
	// Validate the data
	if (type(question) != 'string') then return end
	if (type(options) != 'table' || table.Count(options) < 2) then return end
	
	// Display the vote
	Vote.Active = true
	Vote.Options = options
	Vote.Question = question
	
	// Get the width of everything
	surface.SetFont('FrujuFont')
	
	local w = ScrW() / 4
	local titlew, titleh = surface.GetTextSize(Vote.Question)
	
	if (titlew > w) then
		w = titlew
	end
	
	surface.SetFont('FrujuFontSmall')
	local _, optionh = surface.GetTextSize('A')
	
	for i, option in pairs (options) do
		local optionw = surface.GetTextSize(i..') '..option)
		if (optionw > w) then
			w = optionw
		end
	end
	
	Vote.GUI.W = w + 20
	Vote.GUI.H = titleh + (optionh * table.Count(options)) + 20
	Vote.GUI.X = ScrW() - Vote.GUI.W - 20
	Vote.GUI.Y = (ScrH() - Vote.GUI.H) / 3
	Vote.GUI.TitleH = titleh
	Vote.GUI.OptionH = optionh

	return true
end
Network.Hook('Vote.Display', Vote.Display)

function Vote.Draw ()
	if (!Vote.Active) then return end
	
	draw.RoundedBox(4, Vote.GUI.X, Vote.GUI.Y, Vote.GUI.W, Vote.GUI.H, Color(0, 0, 0, 100))
	
	draw.SimpleText(Vote.Question, 'FrujuFont', Vote.GUI.X + 5, Vote.GUI.Y, purple, 0, 3)
	
	local y = Vote.GUI.Y + Vote.GUI.TitleH
	
	surface.SetFont('FrujuFontSmall')
	
	for i, option in pairs (Vote.Options) do
		local w = surface.GetTextSize(i..')')
		draw.SimpleText(i..')', 'FrujuFontSmall', Vote.GUI.X + 5, ((i-1)*Vote.GUI.OptionH) + y, green, 0, 3)
		draw.SimpleText(' '..option, 'FrujuFontSmall', Vote.GUI.X + 5 + w, ((i-1)*Vote.GUI.OptionH) + y, white, 0, 3)
	end
end
hook.Add('HUDPaint', 'Vote.Draw', Vote.Draw)

function Vote.Hide ()
	Vote.Active = false
	Vote.Options = {}
	Vote.Voted = false
	
	return true
end
Network.Hook('Vote.Hide', Vote.Hide)

function Vote.DetectVote ()	
	if (!Vote.Active) then return end		
	if (Vote.Voted) then return end

	for i = 2, table.Count(Vote.Options) + 1 do
		if (input.IsKeyDown(i)) then
			RunConsoleCommand('rp_vote', i-1)
			Vote.Voted = true
		end
	end
end
hook.Add('Think', 'Vote.DetectVote', Vote.DetectVote)

function Vote.BlockSelection (ply, bind, pressed)
	if (!Vote.Active) then return end

	if (string.find(bind, 'slot1')) then return true end
	if (string.find(bind, 'slot2')) then return true end
	if (string.find(bind, 'slot3')) then return true end
	if (string.find(bind, 'slot4')) then return true end
	if (string.find(bind, 'slot5')) then return true end
	if (string.find(bind, 'slot6')) then return true end
end
hook.Add('PlayerBindPress', 'Vote.BlockSelection', Vote.BlockSelection)