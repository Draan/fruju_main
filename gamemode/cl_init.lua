DeriveGamemode('sandbox')

Fruju = {}
Fruju.BaseDir = "../lua_temp/Fruju_Roleplay";

Network = {}
Network.Hooks = {}

// Recieve hook
function Network.Recieve (umsg)
	
	// Get the hook we want to call
	local hook = umsg:ReadString()
	
	if (!Network.Hooks[hook]) then 
		Msg('User message ('..hook..') does not exist\n')
		return
	end
	
	// Call the hook
	for count = 1, 5 do
		if (Network.Hooks[hook](umsg, false)) then return end
		umsg:Reset()
		umsg:ReadString()
		umsg:ReadString()
	end
	
	if (Fruju.Developer) then
		Msg('Usermessage failed, hook: '..hook..'\n')
	end
end
usermessage.Hook('umsg', Network.Recieve)

// Add hook function 
function Network.Hook (identifier, func)
	Network.Hooks[identifier] = func
end

include('shared.lua')
include('cl_hud.lua')
--include('cl_models.lua')
include('cl_scoreboard.lua')
include('cl_help.lua') 

include('restrictions/shared.lua') 
include('chat/cl_init.lua') 
include('player/cl_init.lua') 
include('property/cl_init.lua') 
include('clock/cl_init.lua') 
include('vote/cl_init.lua') 
include('vehicles/cl_init.lua') 
--include('inventory/cl_init.lua') 

function string.Wrap (str, font, width)
	// Check the arguments are valid
	if (!str || string.len(str) == 0) then return str end
	if (!font || string.len(font) == 0) then return str end
	if (!width || width == 0) then return str end
	
	// Get the words and set the line width to zero
	local words = string.Explode(' ', str)
	local linewidth = 0
	local lines = {}
	
	// Check if the string is under the width already
	surface.SetFont(font)
	local w, h = surface.GetTextSize(str)
	if (w <= width) then return str end
	
	// Loop through the words building lines
	for id, word in pairs (words) do
		w, h = surface.GetTextSize(word..' ')
		linewidth = linewidth + w
		
		if (linewidth >= width) then
			words[id] = '//'..word
			linewidth = 0
		end
	end
	
	return string.Implode(' ', words)
end

// Player create hook
function Fruju.PlayerCreated (ent)
	if (!ent || !ent:IsPlayer()) then return end
	
	gamemode.Call('PlayerCreated', ent)
end
hook.Add('OnEntityCreated', 'Fruju.PlayerCreated', Fruju.PlayerCreated)

function GM:PlayerCreated ()
end

// Detect input
Fruju.KeyDown = {}
Fruju.InputEnabled = true;

function Fruju.DetectKeys ()
	for key = 1, 103 do		
		if (input.IsKeyDown(key)) then
			if (!Fruju.KeyDown[key]) then
				if (Fruju.InputEnabled) then
					gamemode.Call('KeyPressed', key);
				end
				
				Fruju.KeyDown[key] = true
			end
		elseif (Fruju.KeyDown[key]) then
			if (Fruju.InputEnabled) then
				gamemode.Call('KeyReleased', key);
			end
			
			Fruju.KeyDown[key] = nil
		end
	end
end
hook.Add('Think', 'Fruju.DetectKeys', Fruju.DetectKeys)

function GM:KeyPressed ()
end

function GM:KeyReleased ()
end

Fruju.MouseDown = {}

function Fruju.DetectMouse ()
	for btn = 107, 113 do		
		if (input.IsMouseDown(btn)) then
			if (!Fruju.MouseDown[btn]) then
				gamemode.Call('MouseDown', btn)
				Fruju.MouseDown[btn] = true
			end
		elseif (Fruju.MouseDown[btn]) then
			gamemode.Call('MouseUp', btn)
			Fruju.MouseDown[btn] = nil
		end
	end
end
hook.Add('Think', 'Fruju.DetectMouse', Fruju.DetectMouse)

function GM:MouseDown ()
end

function GM:MouseUp ()
end

function Fruju.Error(message)
	chat.AddText(Color(255, 0, 0, 255), "[Error]"..' ', Color(255, 255, 255, 255), "Hi, looks like there is an issue, please tell an admin. " ..message);
end

function Fruju.DisableInput()
	Fruju.InputEnabled = false;
end
hook.Add("StartChat", "Fruju.DisableInputChat", Fruju.DisableInput);

function Fruju.EnableInput()
	Fruju.InputEnabled = true;
end
hook.Add("FinishChat", "Fruju.EnableInputChat", Fruju.EnableInput);