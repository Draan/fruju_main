Vehicle = FindMetaTable('Entity')

function Vehicle:GetPetrol ()
	if (self:GetClass() == 'prop_vehicle_prisoner_pod') then return end
	
	return self.Petrol or 0;
end

function Vehicle:SetPetrol (petrol, update)
	if (self:GetClass() == 'prop_vehicle_prisoner_pod') then return end
	
	if (petrol < 0) then
		self.Petrol = 0;
	elseif (petrol > self:GetTankSize()) then
		self.Petrol = self:GetTankSize();
	else
		self.Petrol = petrol;
	end
	
	if (SERVER && update) then
		self:UpdateVehicle()
	end
end

function Vehicle:SetTankSize(size)
	if (self:GetClass() == 'prop_vehicle_prisoner_pod') then return end
	
	self.PetrolTankSize = size or 0;
	
	if (SERVER) then
		self:UpdateVehicle()
	end
end

function Vehicle:GetTankSize()
	if (self:GetClass() == 'prop_vehicle_prisoner_pod') then return end
	
	return self.PetrolTankSize or 0;
end

function Vehicle:DefaultTankSize ()
	if (self:GetClass() == 'prop_vehicle_prisoner_pod') then return end
	
	local tbl = self.VehicleTable;
	
	if (tbl && tbl.PetrolTank) then
		return tbl.PetrolTank;
	else
		return Config.PetrolTank or 100;
	end
end

function Vehicle:SetPassenger(passenger)
	self.Passenger = passenger;
	
	if (SERVER) then
		self:UpdatePassenger();
	end
end

function Vehicle:GetDrain ()
	if (self:GetClass() == 'prop_vehicle_prisoner_pod') then return end
	
	local drainTable = nil;
	
	if (self.VehicleTable && self.VehicleTable.PetrolDrain) then
		drainTable = self.VehicleTable.PetrolDrain;
	elseif (Config.PetrolDrain) then
		drainTable = Config.PetrolDrain;
	else
		return 0;
	end
	
	local ply = self:GetDriver();
	
	if (!ply || !ply:IsPlayer()) then 
		return drainTable[0] 
	end
	
	if (!ply:KeyDown(IN_FORWARD) && !ply:KeyDown(IN_BACK)) then
		return drainTable[0];
	end

	local speed = math.floor(self:GetVelocity():Length() * 0.09144)
	local drain = Config.IdleDrain or 0.01 
	
	for spd, drn in pairs (Config.PetrolDrain) do
		if (speed >= spd) then
			drain = drn
		else
			break
		end
	end
	
	return drain
end

Vehicle.DrainTime = 0
function Vehicle.DrainHook ()
	if (Vehicle.DrainTime && CurTime() - Vehicle.DrainTime < 0.5) then return end
	Vehicle.DrainTime = CurTime()

	for _, ent in pairs (ents.GetAll()) do
		if (ent:IsValid()) then
			if (string.sub(ent:GetClass(), 1, 12) == 'prop_vehicle' && ent:GetClass() != 'prop_vehicle_prisoner_pod') then
				ent:Drain()
			end
		end
	end
end
hook.Add('Tick', 'Vehicle.DrainHook', Vehicle.DrainHook)

function Vehicle:Drain ()
	if (!self.IsOn) then return end
	if (self:GetClass() == 'prop_vehicle_prisoner_pod') then return end
	
	local petrol = self:GetPetrol() - self:GetDrain()
	
	if (petrol <= 0) then 
		gamemode.Call('PetrolOff', self)
		petrol = 0 
	elseif (self:GetPetrol() == 0 && petrol > 0) then
		gamemode.Call('PetrolOn', self)
	end
	
	self:SetPetrol(petrol)
	
	if (CLIENT && (!self.PetrolRequest || CurTime() - self.PetrolRequest > (Config.PetrolSync or 10))) then
		self.PetrolRequest = CurTime();
		RunConsoleCommand('Vehicle.Request', self:EntIndex())
	end
end

function GM:PetrolOff (ent)
end

function GM:PetrolOn (ent)
end

function Vehicle.LoadVehicleTables()
	local vehicleList = list.GetForEdit("Vehicles");
	
	if (vehicleList && Vehicle.VehicleTables) then
		for vehicle, tbl in pairs (Vehicle.VehicleTables) do
			if (vehicleList[vehicle]) then
				table.Merge(vehicleList[vehicle], tbl);
			end
		end
	end
end
hook.Add("InitPostEntity", "Vehicle.LoadVehicleTables", Vehicle.LoadVehicleTables);

-- Modify the car mods lists
Vehicle.VehicleTables = {};

local vehicleTableList = { "Industrial.lua", "Nova_vehicles.lua", "Sickness.lua", "VP_Cars.lua", "VP_Gimmick.lua", "VP_Government.lua", "VP_HL2.lua"} -- Cheap hack for gmod 13 (stupid file.find)

for _, fileName in pairs ( vehicleTableList ) do		
	if (SERVER) then AddCSLuaFile( "vehicles/"..fileName) end
	include('vehicles/'..fileName);
end