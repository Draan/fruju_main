SWEP.Author = "Rory Douglas";
SWEP.Contact = "";
SWEP.Purpose = "";
SWEP.Instructions = "";
SWEP.Spawnable = true;
SWEP.AdminSpawnable = true;
SWEP.isRotating = false;
SWEP.rotationEyeAngles = nil;

SWEP.ViewModelFOV	= 80;
SWEP.ViewModelFlip	= false;
SWEP.ViewModel		= "models/weapons/v_c4.mdl";
SWEP.WorldModel		= "models/weapons/w_c4.mdl";
SWEP.AnimPrefix = "normal";
SWEP.CSMuzzleFlashes	= false;

SWEP.Primary.ClipSize = -1;
SWEP.Primary.DefaultClip = -1;
SWEP.Primary.Automatic = false;
SWEP.Primary.Ammo = "none";
SWEP.Secondary.ClipSize = -1;
SWEP.Secondary.DefaultClip = -1;
SWEP.Secondary.Automatic = false;
SWEP.Secondary.Ammo = "none";

local entMeta = FindMetaTable("Entity");

function SWEP:Initialize ()
	self:SetWeaponHoldType("normal");
end

function SWEP:Equip (ply)
	self:SetWeaponHoldType("normal");
	ply:DrawViewModel(false);
end

function SWEP:Deploy ()
	self:SetWeaponHoldType("normal");
	
	if (SERVER) then
		self.Owner:DrawViewModel(false);
	end
end

function SWEP:GetHeld()
	if (!self.entHeld || !self.entHeld:IsValid()) then return end
	
	if (!self.entHeld:IsHolding(self.Owner)) then 
		self.entHeld = false;
		return;
	end
	
	return self.entHeld;
end

function SWEP:SetHeld(ent, entBone, weld)
	if (!ent|| !ent:IsValid()) then return end

	self.entHeld = ent;
	ent:AddHolding(self.Owner);
	
	if (SERVER) then
		local holder, bone = self.Owner:GetHolder();
		if (!holder || !holder:IsValid()) then return end

		if (weld) then
			constraint.Weld(holder, ent, bone, entBone, 0, true);
			ent:SetOwner(self.Owner);
		end
		
		self:SendHeld();
	end
end

function SWEP:ClearHeld(throw, freeze)
	if (!self.entHeld || !self.entHeld:IsValid()) then return end

	if (SERVER) then
		local holder = self.Owner:GetHolder();
		if (!holder || !holder:IsValid()) then return end
		
		if (holder:Constrained(self.entHeld)) then
			constraint.RemoveAll(holder);
			self.entHeld:SetOwner(nil);
			self.entHeld.thrown = CurTime();
			
			if (!freeze) then
				hands.Drop(self.Owner, self.entHeld, throw);
			end
		end
		
		self:SendClearHeld();
	end
	
	self:SetRotating(false);
	self.entHeld:RemoveHolding(self.Owner);
	self.entHeld = nil;
end

function SWEP:IsRotating()
	return self.isRotating;
end

function SWEP:SetRotating(rotating)
	self.isRotating = rotating;
	
	if (self.Owner && self.Owner:IsPlayer()) then
		self.rotationEyeAngles = self.Owner:GetAimVector():Angle();
	end
	
	if (SERVER) then
		self:SendRotating();
	end
end

function entMeta:IsHolding(ply)
	self.holding = self.holding or {};
	
	return self.holding[ply:UniqueID()];
end

function entMeta:IsMainHolder(ply)
	return (self.holding[1] == ply);
end

function entMeta:AddHolding(ply)
	self.holding = self.holding or {};

	self.holding[ply:UniqueID()] = true;
	
	if (SERVER) then
		self:UpdateHolding();
	end
end

function entMeta:RemoveHolding(ply)
	self.holding = self.holding or {};
	
	self.holding[ply:UniqueID()] = nil;
	
	if (SERVER) then
		self:UpdateHolding();
	end
end

function entMeta:GetHolding()
	return self.holding or {};
end