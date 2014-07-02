include('shared.lua');
 
SWEP.PrintName = "Hands";
SWEP.Slot = 1;
SWEP.SlotPos = 1;
SWEP.DrawAmmo = false;
SWEP.DrawCrosshair = false ;

local textures = {};
textures["default"] = surface.GetTextureID('fruju/hand');
textures["holding"] = surface.GetTextureID('fruju/holding');
textures["nohold"] = surface.GetTextureID('fruju/nohold');
textures["fist"] = surface.GetTextureID('fruju/fist');
textures["unlocked"] = surface.GetTextureID('fruju/unlocked');
textures["locked"] = surface.GetTextureID('fruju/locked');
textures["button"] = surface.GetTextureID('fruju/button');
textures["car"] = surface.GetTextureID('fruju/car');
textures["pump"] = surface.GetTextureID('fruju/pump');
textures["chair"] = surface.GetTextureID('fruju/chair');
textures["gun"] = surface.GetTextureID('fruju/gun');
textures["letter"] = surface.GetTextureID('fruju/letter');

local entMeta = FindMetaTable("Entity");

function SWEP:PrimaryAttack () end
function SWEP:SecondaryAttack () end
function SWEP:DrawWorldModel() end

function hands.HUD ()	
	-- Get the local player
	local ply = LocalPlayer();
	if (!ply || !ply:IsPlayer()) then return end
	
	-- Get the weapon
	local wep = ply:GetActiveWeapon();
	if (!wep || !wep:IsValid() || wep:GetClass() != Fruju.HandsClass) then return end
	
	-- Check whether to draw the hud
	if (!gamemode.Call("HandsDrawHud", ply, wep)) then return end

	local texture = textures[gamemode.Call("HandsHudTexture", ply, wep)];
	
	surface.SetTexture(texture);
	
	local scrw = ScrW()
	local scrh = ScrH()
	
	local w, h = surface.GetTextureSize(texture);
	
	surface.SetDrawColor(255, 255, 255, 255)
	surface.DrawTexturedRect((scrw - w) / 2, (scrh - h) / 2, w, h)
	
	gamemode.Call("HandsDrawText", ply, wep, scrw, scrh, w, h);
end
hook.Add('HUDPaint', 'hands.Hud', hands.HUD);

function hands.GetHeldEnt(umsg)
	local ply = LocalPlayer();
	if (!ply || !ply:IsValid()) then return end
	
	for _, wep in pairs (ply:GetWeapons()) do
		if (wep:GetClass() == Fruju.HandsClass) then
			local held = Entity(umsg:ReadLong());
			if (!held || !held:IsValid()) then return end

			wep.heldMass = umsg:ReadFloat() or 0;
			wep:SetHeld(held);
			
			break;
		end
	end
end
usermessage.Hook("Hands.SendHeld", hands.GetHeldEnt);

function hands.ClearHeldEnt(umsg)
	local ply = LocalPlayer();
	if (!ply || !ply:IsValid()) then return end
	
	for _, wep in pairs (ply:GetWeapons()) do
		if (wep:GetClass() == Fruju.HandsClass) then
			wep:ClearHeld();
			break;
		end
	end
end
usermessage.Hook("Hands.ClearHeld", hands.ClearHeldEnt);

function hands.UpdateHolding(umsg)
	-- Get the entity
	local ent = Entity(umsg:ReadLong());
	local holding = umsg:ReadShort();
	
	if (!ent || !ent:IsValid()) then return end
	
	ent.numHolding = holding or 0;
end
usermessage.Hook("Hands.UpdateHolding", hands.UpdateHolding);

function hands.GetHoldingTexture(ply, wep)
	local held = wep:GetHeld();
	if (!held || !held:IsValid()) then return end

	-- Get the players needed to lift the ent
	local playersNeeded = math.ceil((wep.heldMass or 0) / 200);
	
	if ((held.numHolding or 0) < playersNeeded) then
		return "nohold";
	else
		return "holding";
	end
end
hook.Add("HandsHudTexture", "hands.GetHoldingTexture", hands.GetHoldingTexture);

function hands.GetButtonTexture(ply, wep)
	local ent = ply:Target().Entity;
	
	if (!ent || !ent:IsValid()) then return end
	
	if (ent:GetClass() == "class C_BaseEntity") then
		return "button";
	end	
end
hook.Add("HandsHudTexture", "hands.GetButtonTexture", hands.GetButtonTexture);

function hands.GetPlayersToLift(ply, wep, scrw, scrh, w, h)
	local held = wep:GetHeld();
	if (!held || !held:IsValid()) then return end
	
	-- Get the players needed to lift the ent
	local playersNeeded = math.ceil((wep.heldMass or 0) / 200) - held.numHolding or 0;
	if (playersNeeded <= 0) then return end
	
	surface.SetFont('Default');
	local w, _ = surface.GetTextSize(playersNeeded);
		
	draw.SimpleText(playersNeeded, 'Default', ((scrw - w) / 2) - 5, ((scrh - 32) / 2) + 13, Color(95, 95, 95, 255), 0, 3);
end
hook.Add("HandsDrawText", "hands.GetPlayersToLift", hands.GetPlayersToLift);