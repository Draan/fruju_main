Level.Name = 'Trusted'
Level.Rating = 40

Level.MaxRating = 35
Level.MinRating = -5
Level.MaxGive = 2
Level.RatingDelay = 30

Level.Commands = true
Level.Props = true
Level.Cars = true
Level.Ragdolls = true
Level.Entities = true
Level.Weapons = true
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
Level.Physgun['prop_vehicle_jeep'] = true
Level.Physgun['prop_vehicle_prisoner_pod'] = true
Level.Physgun['prop_vehicle_airboat'] = true
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