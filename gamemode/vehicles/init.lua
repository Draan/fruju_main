AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')

include('shared.lua')

util.PrecacheSound("doors/door_locked2.wav");

function Vehicle.ControlsPress(ply, key)
	local ent = ply:GetVehicle()
	if (!ent || !ent:IsVehicle()) then return end
	if (ent:GetClass() == 'prop_vehicle_prisoner_pod') then return end
	
	if (key == IN_ATTACK) then
		ent:Horn();
	elseif (key == IN_ATTACK2) then
		if (ent.IsOn) then
			ent:VehicleOff();
		else
			ent:VehicleOn();
		end	
	elseif (key == IN_JUMP && !ent.IsOn) then
		ent:ToggleHandbrake(true);
	end
end
hook.Add('KeyPress', 'Vehicle.ControlsPress', Vehicle.ControlsPress);

function Vehicle.ControlsRelease(ply, key)
	local ent = ply:GetVehicle()
	if (!ent || !ent:IsVehicle()) then return end
	if (ent:GetClass() == 'prop_vehicle_prisoner_pod') then return end
	
	if (key == IN_JUMP && !ent.IsOn) then
		ent:ToggleHandbrake(false);
	end
end
hook.Add('KeyRelease', 'Vehicle.ControlsRelease', Vehicle.ControlsRelease);

function Vehicle:Horn()
	if (self:GetClass() == 'prop_vehicle_prisoner_pod') then return end
	
	if (!self.HornDelay || CurTime() - self.HornDelay > 1.5) then
		-- Get the vehicle table
		local tbl = self.VehicleTable;
	
		-- Handle custom horns
		if (!tbl || !tbl.Horn) then
			self:EmitSound('fruju/horn.wav', 85, 100);
		else
			self:EmitSound(tbl.Horn.Sound, 100, tbl.Horn.Pitch);
		end
	end
end
concommand.Add("HonkHorn", function() end);

function Vehicle:UpdateVehicle(recipient)
	if (!recipient) then
		recipient = RecipientFilter()
		recipient:AddAllPlayers()
	end
	
	umsg.Start('Vehicle.Update', recipient)
		umsg.Long(self:EntIndex());
		umsg.Float(self:GetPetrol());
		umsg.Float(self:GetTankSize());
		umsg.Bool(self.IsOn or false);
	umsg.End()
end

function Vehicle.RequestVehicle(ply, command, args)
	local ent = Entity(args[1])
	if (!ent || !ent:IsValid()) then return end
	if (ent:GetClass() == 'prop_vehicle_prisoner_pod') then return end

	ent:UpdateVehicle(ply);
end
concommand.Add('Vehicle.Request', Vehicle.RequestVehicle)

function Vehicle.VehicleCreated (ply, ent)
	if (!ent || !ent:IsValid() || !ent:IsVehicle()) then return end
	if (ent:GetClass() == 'prop_vehicle_prisoner_pod') then return end
	
	ent:LoadHeadlights();
	
	ent:SetTankSize(ent:DefaultTankSize());
	ent:SetPetrol(ent:GetTankSize())
	ent:VehicleOff();
	ent:ToggleHandbrake(true);
end
hook.Add('PlayerSpawnedVehicle', 'Vehicle.Created', Vehicle.VehicleCreated);
hook.Remove("PlayerSpawnedVehicle", "SpawnedVehicle"); 

function Vehicle:VehicleOff ()
	if (self:GetClass() == 'prop_vehicle_prisoner_pod') then return end

	self.IsOn = false;
	self:Fire('TurnOff', '', 0)
	self:ToggleHandbrake(false);
	self:UpdateVehicle();
end
hook.Add('PetrolOff', 'Vehicle.TurnOff', Vehicle.VehicleOff)

function Vehicle:VehicleOn ()
	if (self:GetClass() == 'prop_vehicle_prisoner_pod') then return end
	if (self:GetPetrol() == 0) then return end
	
	self.IsOn = true;
	self:Fire('TurnOn', '', 0)
	self:ToggleHandbrake(false);
	self:UpdateVehicle();
end

function Vehicle:ToggleHandbrake(on)
	if (on) then
		self:Fire('HandBrakeOn', '', 0);
	else
		self:Fire('HandBrakeOff', '', 0);
	end
end

function Vehicle.StayOnExit(ply, ent)
	if (ent:GetClass() == 'prop_vehicle_prisoner_pod') then return end
	
	if (ent.IsOn) then
		ent:VehicleOn();
		ent:Fire('HandBrakeOn', '', 0);
	end
end
hook.Add("PlayerLeaveVehicle", "Vehicle.StayOnExit", Vehicle.StayOnExit);

function Vehicle.CarLoadout(ply, ent)
	if (!ply || !ply:IsValid()) then return end
	
	if (ply.DoLoadout) then
		ply:UpdateLoadout();
	end
end
hook.Add("PlayerLeaveVehicle", "Vehicle.CarLoadout", Vehicle.CarLoadout);

function Vehicle:LoadHeadlights()
end

function Vehicle.TryEnter(ply, ent)
	if (!ply || !ply:IsPlayer()) then return end
	if (!ent || !ent:IsVehicle()) then return end
	if (ply:InVehicle()) then return end
	
	-- Treat passenger seats as parent
	if (ent:GetClass() == "prop_vehicle_prisoner_pod") then
		if (ent.Passenger) then
			local parent = ent:GetParent();
			if (!parent || !parent:IsVehicle()) then return end
			
			local driver = parent:GetDriver();
			if (driver && driver:IsValid()) then return end
			
			ply:EnterVehicle(parent);
			return false;
		end
		
		return;
	end
	
	-- Check if the car has a driver
	local driver = ent:GetDriver();
	
	-- Try get in a passenger seat
	if (driver && driver:IsValid() && ent.Passengers) then
		local passenger = nil;
		
		for _, seat in pairs (ent.Passengers) do
			if (seat && seat:IsValid()) then
				passenger = seat:GetDriver();
				
				if (!passenger || !passenger:IsPlayer()) then 
					ply:EnterVehicle(seat);

					return false;
				end
			end
		end
	end
end
hook.Remove("PlayerEnteredVehicle", "EnteredVehicle"); 


function Vehicle.BlockUse(ply, ent)
	if (ent && ent:IsVehicle()) then 
		return false;
	end
end
hook.Add("PlayerUse", "Vehicle.BlockUse", Vehicle.BlockUse);

function Vehicle.DetectTryEnter(ply, key)
	if (key != IN_USE) then return end
	if (!ply || !ply:IsPlayer()) then return end
	if (ply:InVehicle()) then return end
	
	-- Get the target entity
	local ent = ply:Target().Entity;
	if (!ent || !ent:IsVehicle()) then return end
	
	-- Get the parent if its a passenger
	if (ent.Passenger) then
		local parent = ent:GetParent();
		if (!parent || !parent:IsValid()) then return end
		
		ent = parent;
	end
	
	-- Get if the vehicle is locked
	if (ent:GetClass() != "prop_vehicle_prisoner_pod") then
		if (ent.Locked && !ent:IsOwner(ply)) then
			ent:EmitSound("doors/door_locked2.wav");
			return
		end
	end
	
	-- Check for a driver
	local driver = ent:GetDriver();
	
	ply.VehicleEntered = true;
	
	if (!driver || !driver:IsValid()) then
		ply:EnterVehicle(ent);
	else
		local tbl = ent.VehicleTable;
		
		if (tbl && tbl.Passengers) then
			Vehicle.TryEnter(ply, ent);
		end	
	end
end
hook.Add("KeyPress", "Vehicle.DetectTryEnter", Vehicle.DetectTryEnter);

function Vehicle.TryExit(ent, ply)
	if (!ply || !ply:IsPlayer()) then return end
	if (!ent || !ent:IsVehicle()) then return end

	-- Stop people jumping in then straight back out
	if (ply.VehicleEntered) then
		return false;
	end
	
	if (ent:GetClass() == "prop_vehicle_prisoner_pod") then return end
	
	-- Only allow owners out of a locked car
	if (ent.Locked && !ent:IsOwner(ply)) then
		ent:EmitSound("doors/door_locked2.wav");
		return false;
	end	
end
hook.Add("CanExitVehicle", "Vehicle.TryExit", Vehicle.TryExit);

function Vehicle.VehicleEntryThink()
	for _, ply in pairs (player.GetAll()) do
		if (ply.VehicleEntered) then
			ply.VehicleEntered = false;
		end
	end
end
hook.Add("Think", "Vehicle.VehicleEntryThink", Vehicle.VehicleEntryThink);

function Vehicle.PlayerExitVehicle(ply, ent)
	if (!ply || !ply:IsPlayer()) then return end
	if (!ent || !ent:IsVehicle()) then return end
	
	-- Handle passengers
	if (ent.Passenger) then
		local parent = ent:GetParent();
		if (!parent || !parent:IsVehicle()) then return end
			
		Vehicle.PlayerExitVehicle(ply, parent);
		return
	end
		
	local tbl = ent.VehicleTable;
	
	-- Custom Exits
	if (tbl && tbl.Customexits) then
		local pos = nil;
		local carPos = ent:GetPos();
		local ang = ent:GetAngles();
		local hit;
		
		for _, offset in pairs (tbl.Customexits) do
			pos = carPos + (offset.x * ang:Forward() + offset.y * ang:Right() + offset.z * ang:Up());

			if (ply:VisibleVec(pos) && !Vehicle.EntityInExit(pos)) then
				ply:SetPos(pos);
				return;
			end
		end
	end
	
	-- Normal Exits
	if (Config && Config.VehicleExits) then
		local attachment = nil;

		for _, vechExit in pairs (Config.VehicleExits) do
			attachment = ent:GetAttachment(ent:LookupAttachment(vechExit));
			
			if (attachment  && !Vehicle.EntityInExit(attachment.Pos)) then
				if (ply:VisibleVec(attachment.Pos)) then
					ply:SetPos(attachment.Pos);
					return;
				end
			end
		end
	end
end
hook.Add("PlayerLeaveVehicle", "Vehicle.PlayerExitVehicle", Vehicle.PlayerExitVehicle);
hook.Remove("KeyPress", "ExitingCar");

function Vehicle.EntityInExit(vec)
	for _, ent in pairs (ents.FindInSphere(vec, 20)) do
		if (ent && ent:IsPlayer()) then
			return true;
		end
	end
	
	return false;
end

