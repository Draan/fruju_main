include('shared.lua')

local speedo = surface.GetTextureID('fruju/speedo')
local fuel = surface.GetTextureID('fruju/fuel')
local needle = surface.GetTextureID('fruju/needle')
local fuelneedle = surface.GetTextureID('fruju/fuelneedle')
local revLimit = surface.GetTextureID('fruju/rev_limit')

function Vehicle.Speedo ()
	local ply = LocalPlayer()
	if (!ply || !ply:IsPlayer()) then return end

	local car = ply:GetVehicle();
	if (!car || !car:IsValid() || car:GetClass() == 'prop_vehicle_prisoner_pod') then return end
	
	local scrw = ScrW()
	local scrh = ScrH()
	
	local rotation = math.floor(car:GetVelocity():Length() * -0.09144)
	if (rotation < -260) then rotation = -260 end
	
	surface.SetDrawColor(255, 255, 255, 255);

	surface.SetTexture(speedo)
	surface.DrawTexturedRect(scrw - 256, scrh - 256, 256, 256)
	
	if (car.IsOn) then
		surface.SetTexture(needle)
		surface.DrawTexturedRectRotated(scrw - 128, scrh - 128, 256, 256, rotation)
		
		surface.SetTexture(revLimit)
		surface.DrawTexturedRectRotated(scrw - 128, scrh - 128, 256, 256, -Vehicle.GetRevLimiter())
	end
	
	surface.SetTexture(fuel)
	surface.DrawTexturedRect(scrw - 350, scrh - 128, 128, 128)
	
	local petrol = car:GetPetrol() / car:GetTankSize();
	
	if (car.IsOn) then
		surface.SetTexture(fuelneedle)
		surface.DrawTexturedRectRotated(scrw - 286, scrh - 64, 128, 128, petrol * -90)
	end
	
	-- Get the text size
	surface.SetFont("FrujuFontSmall");
	local tw, th = surface.GetTextSize("A");
	
	draw.SimpleText("Right Click: Turn car on/off", "FrujuFontSmall", 10, ScrH() - (th * 2) - 5, blue);
	draw.SimpleText("Scroll Up/Down then press W to move", "FrujuFontSmall", 10, ScrH() - th - 5, blue);
end
hook.Add('HUDPaint', 'Vehicle.Speedo', Vehicle.Speedo)

function Vehicle.UpdateVehicle (umsg)
	local ent = Entity(umsg:ReadLong())
	if (!ent || !ent:IsValid()) then return end
	
	local petrol = umsg:ReadFloat();
	local tankSize = umsg:ReadFloat();
	local on = umsg:ReadBool();
	
	if (!petrol || !tankSize) then return end

	ent.PetrolTankSize = tankSize;
	ent.Petrol = petrol;
	ent.IsOn = on;
end
usermessage.Hook('Vehicle.Update', Vehicle.UpdateVehicle)

function Vehicle.UpdatePassenger(umsg)
	local ent = Entity(umsg:ReadLong())
	if (!ent || !ent:IsValid()) then return end
	
	local passenger = umsg:ReadBool();
	
	ent:SetPassenger(passenger);
end
usermessage.Hook("Vehicle.UpdatePassenger", Vehicle.UpdatePassenger);

function Vehicle.Created (ent)
	local ply = LocalPlayer()
	if (!ply || !ply:IsPlayer()) then return end
	if (!ent || !ent:IsValid()) then return end
	
	if (!string.find(ent:GetClass(), 'vehicle')) then return end
	
	if (ent:GetClass() == 'prop_vehicle_prisoner_pod') then 
		RunConsoleCommand('Vehicle.RequestPassenger', ent:EntIndex());
	else	
		RunConsoleCommand('Vehicle.Request', ent:EntIndex());
	end
end
hook.Add('OnEntityCreated', 'Vehicle.Created', Vehicle.Created)

function Vehicle:GetDriver ()
	for _, ply in pairs (player.GetAll()) do
		if (ply:GetVehicle() == self) then 
			return ply
		end
	end
end

function Vehicle.HandsDrawHud(ply, wep)
	if (ply:InVehicle()) then
		return false;
	end
end
hook.Add("HandsDrawHud", "Vehicle.HandsDrawHud", Vehicle.HandsDrawHud);

function Vehicle.ChangeRevLimiter(change)
	local new = Vehicle.GetRevLimiter() + change;
	
	if (new < 0) then
		Vehicle.RevLimiter = 0;
	elseif (new > 260) then
		Vehicle.RevLimiter = 260;
	else
		Vehicle.RevLimiter = new;
	end
end

function Vehicle.GetRevLimiter()
	return Vehicle.RevLimiter or 0;
end

function Vehicle.RevLimiterInput(ply, bind, pressed)
	local me = LocalPlayer();
	if (!me || !me:IsPlayer()) then return end
	if (!me:InVehicle()) then return end
	
	if (string.find(bind, "invnext")) then
		Vehicle.ChangeRevLimiter(-10);
	elseif (string.find(bind, "invprev")) then
		Vehicle.ChangeRevLimiter(10);
	end
end
hook.Add("PlayerBindPress", "Vehicle.RevLimiterInput", Vehicle.RevLimiterInput);

Vehicle.WasIn = false;

function Vehicle.DriverInput()
	if (!Fruju.InputEnabled) then return end
	
	local ply = LocalPlayer();
	if (!ply || !ply:IsPlayer()) then return end
	
	local car = ply:GetVehicle();
	
	if (!car || !car:IsValid()) then 
		if (Vehicle.WasIn) then
			RunConsoleCommand("-forward");
			Vehicle.WasIn = false;
		end
		
		return 
	end
	
	if (math.floor(car:GetVelocity():Length() * 0.09144) < Vehicle.GetRevLimiter()) then
		if (input.IsKeyDown(KEY_W)) then
			RunConsoleCommand("+forward");
		else
			RunConsoleCommand("-forward");
		end
	else
		RunConsoleCommand("-forward");
	end
	
	Vehicle.WasIn = true;
end
hook.Add("Think", "Vehicle.DriverInput", Vehicle.DriverInput);