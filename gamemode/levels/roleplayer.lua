Level.Name = 'Roleplayer'
Level.Rating = 15

Level.MaxRating = 20
Level.MaxGive = 1
Level.RatingDelay = 45

Level.Commands = true

Level.Props = true

Level.Tools = {}
Level.Tools['weld'] = true
Level.Tools['rope'] = true
Level.Tools['elastic'] = true
Level.Tools['nocollide'] = true
Level.Tools['winch'] = true
Level.Tools['pulley'] = true
Level.Tools['nail'] = true
Level.Tools['colour'] = true
Level.Tools['balloon'] = true
Level.Tools['material'] = true
Level.Tools['camera'] = true

Level.BlockTool = {}
Level.BlockTool['prop_door_rotating'] = true
Level.BlockTool['func_door'] = true
Level.BlockTool['func_door_rotating'] = true
Level.BlockTool['player'] = true
Level.BlockTool['func_button'] = true
Level.BlockTool['prop_vehicle_jeep'] = true
Level.BlockTool['prop_vehicle_prisoner_pod'] = true
Level.BlockTool['prop_vehicle_airboat'] = true

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
	'weapon_fiveseven'
}

Level.CanPolice = true