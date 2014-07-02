Config = {}

// Defaults
Config.DefaultMoney = 200
Config.DefaultJob = 'Unemployed'

// Commands
Config.CommandPrefix = '/'
Config.AdminPrefix = '!'

// Chat
Config.ChatType = {}
Config.ChatType.Normal = 0
Config.ChatType.Whisper = 1
Config.ChatType.Radio = 2
Config.ChatType.OOC = 3
Config.ChatType.Admin = 4
Config.ChatType.Action = 5
Config.ChatType.Announcement = 6
Config.ChatType.Hint = 7
Config.ChatType.Private = 8

Config.ChatColor = {}
Config.ChatColor[Config.ChatType.Normal] = Color(122, 179, 79, 255)
Config.ChatColor[Config.ChatType.Whisper] = Color(122, 179, 79, 255)
Config.ChatColor[Config.ChatType.Radio] = Color(58, 165, 205, 255)
Config.ChatColor[Config.ChatType.OOC] = Color(108, 215, 255, 255)
Config.ChatColor[Config.ChatType.Admin] = Color(200, 100, 255, 255)
Config.ChatColor[Config.ChatType.Action] = Color(255, 255, 255, 255)
Config.ChatColor[Config.ChatType.Announcement] = Color(239, 120, 255, 255)
Config.ChatColor[Config.ChatType.Hint] = Color(255, 200, 100, 255)
Config.ChatColor[Config.ChatType.Private] = Color(122, 179, 79, 255)

Config.WhsiperDistance = 200

// Job
Config.MinJobLength = 3
Config.MaxJobLength = 35

// Pay
Config.MinPay = 20
Config.MaxPay = 35

// Death money drop
Config.MoneyDropMin = 0.1		-- Percentage of money dropped on death
Config.MoneyDropMax = 0.2

// Property
Config.Property = {}
Config.Property['prop_door_rotating'] = true
Config.Property['func_door'] = true
Config.Property['func_door_rotating'] = true
Config.Property['prop_vehicle_jeep'] = true
--Config.Property['prop_vehicle_prisoner_pod'] = true
Config.Property['prop_vehicle_airboat'] = true

// Money/Letters
Config.MoneyDelay = 5
Config.LetterDelay = 8
Config.LetterPrice = 5

-- Police Models
Config.PoliceModels = {}
Config.PoliceModels.Male = {'models/player/leet.mdl'}
Config.PoliceModels.Female = {'models/player/alyx.mdl'}

-- Police Vote
Config.PoliceRatio = 0.3			-- Number of police to citizens - 1 = off
Config.PoliceVoteRatio = 0.6		-- Percentage votes required to win 

// Sleep Time
Config.SleepTime = 15

-- Player Models
Config.PlayerModels = {}
Config.PlayerModels.Male = {
	'models/player/Group01/male_01.mdl',
	'models/player/Group01/male_02.mdl',
	'models/player/Group01/male_03.mdl',
	'models/player/Group01/male_04.mdl',
	'models/player/Group01/male_05.mdl',
	'models/player/Group01/male_06.mdl',
	'models/player/Group01/male_07.mdl',
	'models/player/Group01/male_08.mdl',
	'models/player/Group01/male_09.mdl',
	'models/player/Group01/male_01.mdl',
	'models/player/Group03/male_02.mdl',
	'models/player/Group03/male_03.mdl',
	'models/player/Group03/male_04.mdl',
	'models/player/Group03/male_05.mdl',
	'models/player/Group03/male_06.mdl',
	'models/player/Group03/male_07.mdl',
	'models/player/Group03/male_08.mdl',
	'models/player/Group03/male_09.mdl'
}
	
Config.PlayerModels.Female = {
	'models/player/Group01/female_01.mdl',
	'models/player/Group01/female_02.mdl',
	'models/player/Group01/female_03.mdl',
	'models/player/Group01/female_04.mdl',
	'models/player/Group01/female_06.mdl',
	'models/player/Group03/female_01.mdl',
	'models/player/Group03/female_02.mdl',
	'models/player/Group03/female_03.mdl',
	'models/player/Group03/female_04.mdl',
	'models/player/Group03/female_06.mdl'
}

-- Advertising
Config.advertisements = {
	"Check out tabbytv.com for the latest hubbub",
	"Need help? Press F1"
};

Config.advertisementDelay = 300;

-- Inventory
Config.InventorySize = 75;

-- Petrol tanks
Config.PetrolTank = 100
Config.PetrolSync = 10		-- Delay between syncronizing client and cars petrol
Config.IdleDrain = 0.05

Config.PetrolDrain = {}		-- [Speed (km/h)] = drain per tick 
Config.PetrolDrain[0] = 0.05
Config.PetrolDrain[10] = 0.07
Config.PetrolDrain[20] = 0.09
Config.PetrolDrain[30] = 0.1
Config.PetrolDrain[40] = 0.15
Config.PetrolDrain[50] = 0.2
Config.PetrolDrain[60] = 0.25
Config.PetrolDrain[70] = 0.3
Config.PetrolDrain[80] = 0.35
Config.PetrolDrain[90] = 0.4
Config.PetrolDrain[100] = 0.45
Config.PetrolDrain[110] = 0.5

Config.PetrolDrainSupercar = {}
Config.PetrolDrainSupercar[0] = 0.02
Config.PetrolDrainSupercar[10] = 0.04
Config.PetrolDrainSupercar[20] = 0.05
Config.PetrolDrainSupercar[30] = 0.08
Config.PetrolDrainSupercar[40] = 0.1
Config.PetrolDrainSupercar[50] = 0.13
Config.PetrolDrainSupercar[60] = 0.16
Config.PetrolDrainSupercar[70] = 0.18
Config.PetrolDrainSupercar[80] = 0.2
Config.PetrolDrainSupercar[90] = 0.22
Config.PetrolDrainSupercar[100] = 0.23
Config.PetrolDrainSupercar[110] = 0.24
Config.PetrolDrainSupercar[130] = 0.23

Config.PetrolDrainLight = {}
Config.PetrolDrainLight[0] = 0.01
Config.PetrolDrainLight[10] = 0.01
Config.PetrolDrainLight[20] = 0.02
Config.PetrolDrainLight[30] = 0.035
Config.PetrolDrainLight[40] = 0.05

Config.PetrolDrainHeavy = {}
Config.PetrolDrainHeavy[0] = 0.01
Config.PetrolDrainHeavy[10] = 0.015
Config.PetrolDrainHeavy[20] = 0.035
Config.PetrolDrainHeavy[30] = 0.045
Config.PetrolDrainHeavy[40] = 0.05
Config.PetrolDrainHeavy[50] = 0.62
Config.PetrolDrainHeavy[60] = 0.75
Config.PetrolDrainHeavy[70] = 0.7
Config.PetrolDrainHeavy[80] = 0.68

Config.PetrolDispense = 0.15;

Config.VehicleExits = { "exit1", "exit2", "exit3", "exit4", "exit5", "exit6" };

-- Weapons
Config.NoDrop = {};
Config.NoDrop[Fruju.HandsClass] = true;
Config.NoDrop["weapon_physgun"] = true;
Config.NoDrop["weapon_physcannon"] = true;
Config.NoDrop["gmod_tool"] = true;