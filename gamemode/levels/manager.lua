Level.Name = 'Manager'							-- The name of this group
Level.Rating = 100								-- The rating required to become a member of this group

Level.MaxRating = 100							-- The maximum rating players in this level can give to another player
Level.MinRating = -25							-- The minimum rating players in this level can give to another player
Level.MaxGive = 125								-- The maximum rating players in this level can give to another player in one go
Level.RatingDelay = 0							-- The delay between giving ratings for players in this group

-- All the below values can be boolean (true/false) or a table of values
-- Any lines which are false can also be removed entirely if you want to keep the files clean

Level.Commands = true							-- Can be table of commands: Level.Commands = {}, Level.Commands['job'] = true
Level.AdminCommands = true						-- Can be table - See above
Level.Props = true								-- Can be table of models
Level.Cars = true								-- Can be table of models
Level.Entities = true							-- Can be table of classes (eg. fruju_letter)
Level.Weapons = true							-- Can be table of classes (eg. weapon_pistol)
Level.Effects = true							-- Can be table of models
Level.Ragdolls = true							-- Can be table of models 
Level.NPCs = true								-- Can be table of NPCs (eg. npc_antlion)
Level.Noclip = true								-- True/False

Level.Tools = true								-- Can be table of tools (see http://wiki.garrysmod.com/?title=Gamemode.CanTool)

Level.BlockTool = {}							-- Block certain props from having the tool gun used on it 
Level.BlockTool['player'] = true				-- The table key is the class of the prop

Level.Physgun = {}								-- Props which the player can not use the physgun on	
Level.Physgun['prop_door_rotating'] = true		-- The table key is the class of the prop
Level.Physgun['func_door'] = true
Level.Physgun['func_door_rotating'] = true
Level.Physgun['player'] = true
Level.Physgun['func_button'] = true
Level.Physgun['func_wall'] = true

Level.Loadout = {								-- The default loadout, Each value is the class of the weapon
	Fruju.HandsClass,
	'gmod_tool',
	'weapon_physgun',
	'weapon_physcannon'
}

Level.PoliceLoadout = {							-- The Police loadout, Each value is the class of the weapon
	'police_doorram',
	'police_taser',
	'police_handcuffs',
	'weapon_fiveseven',
	'weapon_m4a1'
}

Level.CanPolice = true							-- Whether the players in this group can join the police