Level.Name = 'Guest'
Level.Rating = 0

Level.Commands = true

Level.Tools = {}
Level.Tools['weld'] = true

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
	'weapon_physcannon'
}

Level.PoliceLoadout = {
	'police_doorram',
	'police_taser',
	'police_handcuffs',
	'weapon_fiveseven'
}

Level.CanPolice = false