Level.Name = 'Admin'
Level.Rating = 85

Level.MaxRating = 70
Level.MinRating = -25
Level.MaxGive = 5
Level.RatingDelay = 10

Level.Commands = true
Level.AdminCommands = true
Level.Props = true
Level.Cars = true
Level.Entities = true
Level.Weapons = true
Level.Effects = true
Level.Ragdolls = true
Level.NPCs = true
Level.Noclip = true

Level.Tools = true

Level.BlockTool = {}
Level.BlockTool['player'] = true

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