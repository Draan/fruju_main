AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")

ENT.Weapon = "";
ENT.Primary = "";
ENT.Secondary = "";
ENT.Clip1 = 0;
ENT.Clip2 = 0;
ENT.PrimaryCount = 0;
ENT.SecondaryCount = 0;

function ENT:Initialize ()
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS ) 
	
	if (self.Entity:GetPhysicsObject():IsValid()) then
		self.Entity:GetPhysicsObject():Wake()
	end 
end

function ENT:Use (ply)
	if (!ply || !ply:IsValid()) then return end
	
	-- Give the player the weapon
	ply.WeaponPickedUp = true;
	ply:PickupWeapon(self.Weapon, self.Primary, self.Secondary, self.PrimaryCount, self.SecondaryCount);
	
	-- Get the weapon
	local wep = ply:GetWeapon(self.Weapon);
	if (!wep || !wep:IsValid()) then return end
	
	wep:SetClip1(self.Clip1);
	wep:SetClip2(self.Clip2);
	
	self.Entity:Remove()
end

function ENT.InventoryPickup(ent, item)
	if (ent:GetClass() != "fruju_weapon") then return end
	
	-- Store the weapon info
	item:SetName("Weapon");
	item:SetData({Weapon = ent.Weapon, Primary = ent.Primary, Secondary = ent.Secondary, Clip1 = ent.Clip1, Clip2 = ent.Clip2, 
					PrimaryCount = ent.PrimaryCount, SecondaryCount = ent.SecondaryCount});
end
hook.Add("InventoryItemPickedUp", "FrujuWeapon.InventoryPickup", ENT.InventoryPickup);

function ENT.InventoryDrop(ent, item)
	if (item:GetClass() != "fruju_weapon") then return end
	
	-- Get the data
	local data = item:GetData()
	if (!data) then return end
	
	-- Restore the weapon info
	ent.Weapon = data.Weapon;
	ent.Primary = data.Primary;
	ent.Secondary = data.Secondary;
	ent.Clip1 = data.Clip1;
	ent.Clip2 = data.Clip2;
	ent.PrimaryCount = data.PrimaryCount;
	ent.SecondaryCount = data.SecondaryCount;
end
hook.Add("InventoryItemDropped", "FrujuWeapon.InventoryDrop", ENT.InventoryDrop);