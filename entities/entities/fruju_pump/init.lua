AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

-- Initialize
function ENT:Initialize ()
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS ) 
	
	if (self.Entity:GetPhysicsObject():IsValid()) then
		self.Entity:GetPhysicsObject():Wake()
	end
	
	self.Car = nil;
	self.Dispensed = 0;
end

-- Spawn function
function ENT:SpawnFunction (ply, tr)
    local ent = ents.Create('fruju_pump')
    ent:SetPos( tr.HitPos + tr.HitNormal * 16 ) 
	ent:SetModel("models/props_wasteland/gaspump001a.mdl")
    ent:Spawn()
 
    return ent
end

function ENT:Think()
	-- Check if there is a car
	if (self.Car && self.Car:IsValid() && self.Car:IsVehicle()) then
		-- Check if the car is within distance
		if (self.Entity:GetPos():Distance(self.Car:GetPos()) < 150) then
			return;
		else
			self.Car = nil;
			self.Dispensed = 0;
			self.Entity:SendDispensed();
			self:ClearCar();
		end
	end
	
	-- Do a trace in front of the pump

	local trace = {};
	trace.start = self.Entity:GetPos() + (self.Entity:GetUp() * 20);
	trace.endpos = trace.start + ((self.Entity:GetForward() * -1) * 80); --* 80
	trace.filter = self.Entity;
	
	local ent = util.TraceLine(trace).Entity;
	if (!ent || !ent:IsValid() || !ent:IsVehicle()) then return end
	if (ent:GetClass() == 'prop_vehicle_prisoner_pod') then return end
	
	-- Store the car
	self.Car = ent;
	self:SendCar();
end

function ENT:Use(ply)
	if (!self.Car || !self.Car:IsValid() || !self.Car:IsVehicle()) then return end
	
	local driver = self.Car:GetDriver();
	
	-- Check if the car is on
	if (!driver || !driver:IsValid()) then
		self.Car:VehicleOff();
		self.Car:ToggleHandbrake(true);
	end	
	
	-- Give the car petrol 
	if (self.Car:GetPetrol() < self.Car:GetTankSize()) then
		self.Car:SetPetrol(self.Car:GetPetrol() + Config.PetrolDispense, true);
		
		self.Dispensed = self.Dispensed + Config.PetrolDispense;
		self:SendDispensed();
	end
end

function ENT:SendDispensed(recipient)
	if (!recipient) then
		recipient = RecipientFilter();
		recipient:AddAllPlayers();
	end
	
	umsg.Start("PetrolPump.Dispensed", recipient)
		umsg.Long(self:EntIndex());
		umsg.Float(self.Dispensed or 0);
	umsg.End();
end

function ENT:SendCar(recipient)
	if (!recipient) then
		recipient = RecipientFilter();
		recipient:AddAllPlayers();
	end
	
	umsg.Start("PetrolPump.Car", recipient)
		umsg.Long(self:EntIndex());
		umsg.Long(self.Car:EntIndex());
	umsg.End();
end

function ENT:ClearCar(recipient)
	if (!recipient) then
		recipient = RecipientFilter();
		recipient:AddAllPlayers();
	end
	
	umsg.Start("PetrolPump.Clear", recipient)
		umsg.Long(self:EntIndex());
	umsg.End();
end

function ENT.Request(ply, command, args)
	if (!ply || !ply:IsValid()) then return end
	
	local ent = Entity(args[1]);
	if (!ent || !ent:IsValid() || ent:GetClass() != "fruju_pump") then return end
	
	ent:SendDispensed(ply);
	
	if (ent.Car && ent.Car:IsValid()) then
		ent:SendCar(ply);
	else
		ent:ClearCar(ply);
	end
end
concommand.Add("PetrolPump.Request", ENT.Request);


