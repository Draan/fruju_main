Level.Name = 'Moderator'
Level.Rating = 65

Level.MaxRating = 50
Level.MinRating = -15
Level.MaxGive = 3
Level.RatingDelay = 20

Level.Commands = true
Level.AdminCommands = {}
Level.AdminCommands.removecop = true
Level.AdminCommands.unown = true
Level.AdminCommands.own = true
Level.AdminCommands.lock = true
Level.AdminCommands.unlock = true
Level.AdminCommands.stun = true
Level.AdminCommands.unstun = true
Level.AdminCommands.mute = true
Level.AdminCommands.unmute = true
Level.AdminCommands.endvote = true
Level.AdminCommands.vote = true
Level.AdminCommands.kick = true
Level.AdminCommands.map = true
Level.AdminCommands.playme = true
Level.AdminCommands['@'] = true
Level.AdminCommands['@@'] = true
Level.AdminCommands['@@@'] = true

Level.Props = true
Level.Cars = true
Level.Entities = true
Level.Weapons = true
Level.Effects = true
Level.Ragdoll = true
Level.Noclip = true
Level.NPCs = true

Level.Tools = true

Level.BlockTool = {}
Level.BlockTool['prop_door_rotating'] = true
Level.BlockTool['func_door'] = true
Level.BlockTool['func_door_rotating'] = true
Level.BlockTool['player'] = true
Level.BlockTool['func_button'] = true

Level.Physgun = {}
Level.Physgun['prop_door_rotating'] = true
Level.Physgun['func_door'] = true
Level.Physgun['func_door_rotating'] = true
Level.Physgun['player'] = true
Level.Physgun['func_button'] = true
Level.Physgun['func_wall'] = true

Level.Loadout = {
	Fruju.HandsClass,
	'gmod_tool',
	'weapon_physgun',
	'weapon_physcannon'
}

Level.PoliceLoadout = {
	'police_doorram',
	'police_taser',
	'police_handcuffs',
	'weapon_fiveseven',
	'weapon_m4a1'
}

Level.CanPolice = true