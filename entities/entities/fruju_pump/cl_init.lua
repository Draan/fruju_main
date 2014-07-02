include("shared.lua")

function ENT:Initialize()
	self.Dispensed = 0;
end

function ENT:Draw ()
	--self.Entity:DrawEntityOutline(0)
	self.Entity:DrawModel()
	
	-- The coolness vars for the 2d3d
	local rot = Vector(-90,90,0)
	local x = -90
	local y = -60
	local w = 205
	local h = 160
	
	local ang = self.Entity:GetAngles()
	ang:RotateAroundAxis(ang:Right(), 	rot.x)
	ang:RotateAroundAxis(ang:Up(), 		rot.y)
	ang:RotateAroundAxis(ang:Forward(), rot.z)
	
	local pos = self.Entity:GetPos() + (self.Entity:GetForward() * 9.4) + (self.Entity:GetUp() * 48) + (self.Entity:GetRight() * 1.84)
	
	-- Pump screen
	cam.Start3D2D(pos,ang,0.15)
		-- Background
		surface.SetDrawColor(33, 33, 33, 255)
		surface.DrawRect(x,y, w, h)
		
		-- Get the text height
		surface.SetFont("Default");
		local tw, th = surface.GetTextSize("A");
		
		x = x + 20;
		y = y + 10;
		
		if (self.Locked) then
			self:DrawLocked(x, y);
		elseif (self.Car && self.Car:IsValid()) then
			self:DrawActive(x, y, w, h, th);
		else
			self:DrawIdle(x, y);		
		end
		
	cam.End3D2D()
end

function ENT:DrawActive(x, y, w, h, th)
	-- Petrol Title
	surface.SetTextColor(purple.r, purple.g, purple.b, purple.a);
	surface.SetTextPos(x, y);
	surface.DrawText("Petrol In Car");
	
	--draw.SimpleText("Petrol In Car", "Default", x, y, purple);
	y = y + th + 2;
	
	-- Petrol
	surface.SetDrawColor(green.r, green.g, green.b, green.a);
	surface.DrawOutlinedRect(x, y, w / 2, th + 2);
	
	surface.SetTextColor(white.r, white.g, white.b, white.a);
	surface.SetTextPos(x+2, y+1);
	surface.DrawText(math.floor((self.Car:GetPetrol() / self.Car:GetTankSize()) * 100).."%");
	
	--draw.SimpleText(math.floor((self.Car:GetPetrol() / Vehicle.GetTankSize()) * 100).."%", "Default", x+2, y + 1, white);
	y = y + th + 5;
	
	-- Dispensed Title
	surface.SetTextColor(purple.r, purple.g, purple.b, purple.a);
	surface.SetTextPos(x, y);
	surface.DrawText("Petrol Dispensed");
	
	--draw.SimpleText("Petrol Dispensed", "Default", x, y, purple);
	y = y + th + 2;
	
	-- Dispensed
	surface.SetDrawColor(green.r, green.g, green.b, green.a);
	surface.DrawOutlinedRect(x, y, w / 2, th + 2);
	
	surface.SetTextColor(white.r, white.g, white.b, white.a);
	surface.SetTextPos(x+2, y+1);
	surface.DrawText(math.floor(self.Dispensed).. " Litres");
	
	--draw.SimpleText(math.floor(self.Dispensed).. " Litres", "Default", x+2, y + 1, white);
end

function ENT:DrawIdle(x, y)
	-- Petrol Title
	surface.SetTextColor(purple.r, purple.g, purple.b, purple.a);
	surface.SetTextPos(x, y);
	surface.DrawText("> Petrol Pump");
end	

function ENT:DrawLocked(x, y)
	-- Petrol Title
	surface.SetTextColor(red.r, red.g, red.b, red.a);
	surface.SetTextPos(x, y);
	surface.DrawText("> Locked");
end	

function ENT.RecieveDispensed(umsg)
	local ent = Entity(umsg:ReadLong());
	local dispensed = umsg:ReadFloat();
	
	if (!ent || !ent:IsValid() || ent:GetClass() != "fruju_pump") then return end
	if (!dispensed) then return end
	
	ent.Dispensed = dispensed;
end
usermessage.Hook("PetrolPump.Dispensed", ENT.RecieveDispensed);

function ENT.RecieveCar(umsg)
	local ent = Entity(umsg:ReadLong());
	local car = Entity(umsg:ReadLong());
	
	if (!ent || !ent:IsValid() || ent:GetClass() != "fruju_pump") then return end
	if (!car || !car:IsValid()) then return end
	
	ent.Car = car;
end
usermessage.Hook("PetrolPump.Car", ENT.RecieveCar);

function ENT.ClearCar(umsg)
	local ent = Entity(umsg:ReadLong());
	
	if (!ent || !ent:IsValid() || ent:GetClass() != "fruju_pump") then return end
	
	ent.Car = nil;
end
usermessage.Hook("PetrolPump.Clear", ENT.ClearCar);

function ENT:Request()
	local ply = LocalPlayer();
	if (!ply || !ply:IsValid()) then return end
	
	if (!self || !self:IsValid() || self:GetClass() != "fruju_pump") then return end
	
	RunConsoleCommand("PetrolPump.Request", self:EntIndex());
end
hook.Add("OnEntityCreated", "ENT.Request", ENT.Request);