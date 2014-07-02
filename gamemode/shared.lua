GM.Name 	= "Fruju RolePlay"
GM.Author 	= "Rory"
GM.Email 	= ""
GM.Website 	= ""

Levels = {}

Fruju.HandsClass = "fruju_hands";

include('config.lua')
include('restrictions/shared.lua')
include('hands.lua');

function Fruju.FormatMoney (amount)
	if (type(amount) != 'number') then return '$0.00' end
	
	amount = tostring(amount)
	
	parts = string.Explode('.', amount)
	
	if (not parts[2]) then return '$'..amount..'.00' end
	
	local power = 10 ^ -(string.len(parts[2]) - 2)
	
	parts[2] = math.Round(tonumber(parts[2]) * power)
	
	if (string.len(parts[2]) == 1) then parts[2] = '0'..parts[2] end
	
	return '$'..string.Implode('.', parts)
end

function Fruju.FindPlayer (name)
	local matches = {}
	
	if (type(name) != 'string') then return end
	name = string.lower(name)
	name = string.Trim(name)
	
	for _, ply in pairs (player.GetAll()) do
		if (name == string.lower(ply:Nick())) then
			return ply
		elseif (string.find(string.lower(ply:Nick()), name)) then
			table.insert(matches, ply)
		end
	end
	
	if (table.Count(matches) > 0) then
		return matches[1]
	end
end


ListOfLevels = {"admin.lua", "guest.lua", "manager.lua", "mingebag.lua", "moderator.lua", "roleplayer.lua", "trusted.lua", "untrusted.lua"}

// Load levels
for _, level in pairs (ListOfLevels) do
	Level = {}
	if (SERVER) then AddCSLuaFile('levels/'..level) end
	include('levels/'..level);

	table.insert(Levels, table.Copy(Level))
end

table.sort(Levels, function (a, b) return a.Rating < b.Rating end)

// Load map
Map = {}
local map = game.GetMap()..'.lua'

if (file.Exists(Fruju.BaseDir.."/gamemode/maps/"..map, "GAME")) then
	include ('maps/'..map)
	
	if (SERVER) then
		AddCSLuaFile('maps/'..map)
	end
end