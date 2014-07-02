white = Color(255, 255, 255, 255)
blue = Color(108, 215, 255, 255)
purple = Color(199, 120, 255, 255)
green = Color(122, 179, 79, 255)
red = Color(255, 100, 100, 255)

surface.CreateFont( 'FrujuFontSmall', {
	font = "HamburgerHeaven",
	size = 25,
	weight = 400,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
} )

surface.CreateFont( 'FrujuFont', {
	font = "HamburgerHeaven",
	size = 30,
	weight = 400,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
} )

// Draw hud
function Fruju.DrawHUD ()
	local ply = LocalPlayer()
	if (!ply || !ply:IsPlayer()) then return end
	
	surface.SetFont('FrujuFont')
	
	local health = math.ceil((ply:Health() / 100) * 100)
	if (health > 100) then health = 100 
	elseif (health < 0) then health = 0 end
	
	local x, y = surface.GetTextSize('Health')
	draw.SimpleText('Health', 'FrujuFont', 10, 0, blue, 0, 3)
	draw.SimpleText(health..'%', 'FrujuFont', 20+x, 0, white, 0, 3)
	
	x = surface.GetTextSize('Job')
	draw.SimpleText('Job', 'FrujuFont', 10, y-5, blue, 0, 3)
	draw.SimpleText(ply:GetJob(), 'FrujuFont', 20+x, y-5, white, 0, 3)
	
	x = surface.GetTextSize('Money')
	draw.SimpleText('Money', 'FrujuFont', 10, (y-5)*2, blue, 0, 3)
	draw.SimpleText(Fruju.FormatMoney(ply:GetMoney()), 'FrujuFont', 20+x, (y-5)*2, white, 0, 3)
	

	for _, tgt in pairs (player.GetAll()) do
		if (tgt:Alive() && tgt != ply) then
			Fruju.PlayerHud(ply, tgt);
		end
	end	
	
	Fruju.PropertyHud(ply)
end
hook.Add('HUDPaint', 'Fruju.DrawHUD', Fruju.DrawHUD) 

// Should draw
function Fruju.ShouldDraw (name)
	if (name == 'CHudSuitPower') then return false end
	if (name == 'CHudHealth') then return false end
	if (name == 'CHudBattery') then return false end
	if (name == 'CHudAmmo') then return false end
	if (name == 'CHudSecondaryAmmo') then return false end
	if (name == 'CHudTrain') then return false end
	if (name == 'CHudHintDisplay') then return false end
	if (name == 'CHudVehicle') then return false end
	if (name == 'CHudDeathNotice') then return false end
	
	return true
end
hook.Add('HUDShouldDraw', 'Fruju.ShouldDraw', Fruju.ShouldDraw)

function GM:HUDDrawTargetID () return false end

function Fruju.PlayerHud (ply, tgt)   	
	-- Create a trace
	local trace = {};
	trace.start = ply:EyePos();
	local direction = tgt:EyePos() - trace.start
	direction:Normalize()

	trace.filter = { ply, ply:GetActiveWeapon(), tgt:GetActiveWeapon(), ply:GetViewModel(), tgt:GetViewModel() };
	
	-- Get their vehicle
	local vehicle = tgt:GetVehicle();
	
	if (vehicle && vehicle:IsValid()) then	
		trace.endpos = trace.start + direction * 600;
		table.insert(trace.filter, vehicle);
		
		if (util.TraceHull(trace).Entity != vehicle) then return end
	
		Fruju.DrawPlayerHudVehicle(ply, tgt, vehicle)
	else
		trace.endpos = trace.start + direction * 400;
		
		if (util.TraceHull(trace).Entity != tgt) then return end
	
		Fruju.DrawPlayerHudPlayer(ply, tgt)
	end		
end

function Fruju.DrawPlayerHudVehicle(ply, tgt, car)
	local pos = (tgt:EyePos() + Vector(0, 0, 7)):ToScreen();
	
	surface.SetFont('FrujuFontSmall');
	local w, h = surface.GetTextSize(tgt:Nick());
	local x = pos.x - (w / 2);
	local y = pos.y - (2 * h);
	
	local color = green;
	if (tgt.Criminal) then color = red;
	elseif (tgt.Cop) then color = blue end
	
	local job = tgt:GetJob();
	
	if (ply.Cop && !car.Passenger) then
		job = job.. " ("..math.floor(car:GetVelocity():Length() * 0.0568182) .." mph)";
	end
	
	draw.SimpleText(tgt:Nick(), 'FrujuFontSmall', x, y, color, 0, 3);
	draw.SimpleText(job, 'FrujuFontSmall', pos.x - (surface.GetTextSize(job) / 2), y + h - 10, white, 0, 3);
end

function Fruju.DrawPlayerHudPlayer(ply, tgt)
	local pos = (tgt:EyePos() + Vector(0, 0, 7)):ToScreen();
	
	surface.SetFont('FrujuFontSmall');
	local w, h = surface.GetTextSize(tgt:Nick());
	local x = pos.x - (w / 2);
	local y = pos.y - (2 * h);
	
	local color = green;
	if (tgt.Criminal) then color = red;
	elseif (tgt.Cop) then color = blue end
	
	draw.SimpleText(tgt:Nick(), 'FrujuFontSmall', x, y, color, 0, 3);
	draw.SimpleText(tgt:GetJob(), 'FrujuFontSmall', pos.x - (surface.GetTextSize(tgt:GetJob()) / 2), y + h - 10, white, 0, 3);
end

function Fruju.PropertyHud (ply)
	if (ply:InVehicle()) then return end
	local ent = ply:Target(200).Entity
	if (!ent || !ent:IsValid() || !ent:IsProperty()) then return end
	if (!ent:IsOwned()) then return end
	
	surface.SetFont('FrujuFontSmall')
	
	local owners_start = ''
	local owners = ''
	if (table.Count(ent.Owners) == 1) then
		owners_start = 'Owner: '
	else
		owners_start = 'Owners: '
	end
	
	for _, owner in pairs (player.GetAll()) do
		if (ent:IsOwner(owner)) then
			if (owner == ply) then
				owners = owners..' You,'
			elseif (owner:IsPlayer()) then
				owners = owners..' '..owner:Nick()..','
			end
		end
	end
	
	owners = string.sub(owners, 1, -2)
	
	local w, h = surface.GetTextSize(owners_start..owners)
	local x = (ScrW() - w) / 2
	local y = ((ScrH() - h) / 2) - (h * 2)
	
	draw.SimpleText(owners_start, 'FrujuFontSmall', x, y, purple)
	draw.SimpleText(owners, 'FrujuFontSmall', x + surface.GetTextSize(owners_start), y, white)
end