DeriveGamemode('sandbox')

Fruju = {}
Fruju.BaseDir = "gamemodes/tabby_roleplay";

// Send client files
AddCSLuaFile('shared.lua')
AddCSLuaFile('config.lua')
AddCSLuaFile('cl_init.lua')
AddCSLuaFile('cl_hud.lua')
AddCSLuaFile('cl_models.lua')
AddCSLuaFile('cl_scoreboard.lua')
AddCSLuaFile('cl_help.lua')
AddCSLuaFile('hands.lua');

// Includes
include('shared.lua')
include('police.lua')
include('player.lua')

include('chat/init.lua')
include('player/init.lua')
include('clock/init.lua')
include('property/init.lua')
include('vote/init.lua')
include('restrictions/init.lua')
include('vehicles/init.lua')
--include('inventory/init.lua')

include('commands.lua')
include('admin.lua')
include('logs.lua')
include('advertising.lua');
include("resource.lua");

-- Block help
function GM:ShowHelp() return end

-- Fix damage
function GM:GetFallDamage(ply, speed)	
	return speed * 0.139;
end

local function PreventPickup ( ply , ent ) -- disable half life use options, hands ftw
    return false
end
hook.Add( "AllowPlayerPickup", "Gobbildygoo", PreventPickup )

-- Log Map
function Fruju.MapLoaded ()
	Log.Add(nil, 'The current map is: '..game.GetMap()..'.')
end
hook.Add('InitPostEntity', 'Fruju.MapLoaded', Fruju.MapLoaded)