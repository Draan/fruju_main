AddCSLuaFile('cl_init.lua');
AddCSLuaFile('shared.lua');

include('shared.lua');
 
SWEP.Weight = 5;
SWEP.AutoSwitchTo = false;
SWEP.AutoSwitchFrom = false;
SWEP.entHeld = nil;
SWEP.currentRotation = Angle(0, 90, 0);
throw = false

local entMeta = FindMetaTable("Entity");
local plyMeta = FindMetaTable("Player");

function SWEP:PrimaryAttack()
	-- Get the owner of the weapon
	local ply = self.Owner;
	if (!ply || !ply:IsPlayer()) then return end
	
	-- Get the entity being held
	local entHeld = self:GetHeld();
	
	if (entHeld && entHeld:IsValid()) then
		if (!gamemode.Call("HandsTryThrow", self)) then return end
		
		self:Drop(true);
	else
		local tr = ply:Target(80);
	
		if (!gamemode.Call("HandsTryPickup", self, tr)) then return end
		
		self:Pickup(tr);
	end
end

function SWEP:SecondaryAttack()
	-- Get the owner of the weapon
	local ply = self.Owner;
	if (!ply || !ply:IsPlayer()) then return end
	
	-- Get the entity being held
	local entHeld = self:GetHeld();
	
	if (entHeld && entHeld:IsValid()) then
		if (!gamemode.Call("HandsTryDrop", ply, self)) then return end
		
		self:Drop();
	else
		gamemode.Call("HandsSecondaryAttack", ply, self);
	end
end

function SWEP:Reload()
	-- Get the owner of the weapon
	local ply = self.Owner;
	if (!ply || !ply:IsPlayer()) then return end
	
	if (!gamemode.Call("HandsTryFreeze", self)) then return end
	
	-- Get the entity being held
	local entHeld = self:GetHeld();
	
	if (entHeld && entHeld:IsValid()) then
		self:Freeze(entHeld);
	else
		local tr = ply:Target(80);

		self:Freeze(tr.Entity);
	end
end

function SWEP:OnRemove ()
	self.Weapon:Drop()
end

function SWEP:OnDrop ()
	self.Weapon:Drop()
end

function SWEP:Holster ()
	self.Weapon:Drop()
	return true
end

function SWEP:Pickup(tr)
	-- Get the entity
	local ent = tr.Entity;
	if (!ent || !ent:IsValid()) then return end
	
	-- Get the phys object
	local phys = ent:GetPhysicsObject();
	if (!phys || !phys:IsValid()) then return end
	
	if (!gamemode.Call("HandsCanPickup", self.Owner, ent, phys)) then return end
	
	-- Get the holder
	local holder, bone = self.Owner:GetHolder();
	if (!holder || !holder:IsValid() || holder:IsConstrained()) then return end
	
	-- Check if they can lift the entity on their own
	if (ent:Mass() > 200 * (table.Count(ent:GetHolding()) + 1)) then 
		self.Owner:Hint('You can\'t lift this on your own, try asking a friend to help.')
		self:SetHeld(ent, tr.PhysicsBone);
	else
		self:SetHeld(ent, tr.PhysicsBone, true);
	end
end

function SWEP:Drop(throw)
	-- Get the held entity
	local held = self:GetHeld();
	if (!held || !held:IsValid()) then return end
	
	self:ClearHeld(throw);	
end

function hands.Drop (ply, ent, throw)
	if (!ply || !ply:IsPlayer()) then return end
	if (!ent || !ent:IsValid()) then return end

	if (constraint.GetAllConstrainedEntities(ent)[ply:GetHolder()]) then 
		timer.Simple(FrameTime(), function() hands.Drop( ply, ent, throw ) end)
		return
	end
	
	local phys = ent:GetPhysicsObject();
	if (!phys || !phys:IsValid()) then return end
	
	phys:Wake();
	
	-- Sort the new velocity if need be
	local v = phys:GetVelocity();
	
	if (v.x > 50 || v.x < -50) then v.x = v.x * 0.25 end
	if (v.y > 50 || v.y < -50) then v.y = v.y * 0.25 end
	if (v.z > 50 || v.z < -50) then v.z = v.z * 0.25 end
	
	phys:SetVelocity(v);
	phys:EnableMotion(true);
	-- Check whether to throw it
	if (throw && ent:Mass() <= 200) then
	-- works but needs delay
		timer.Simple(FrameTime(), function() phys:ApplyForceCenter(ply:GetAimVector() * phys:GetMass() * 500) end);
	end
	
end

function SWEP:Freeze(ent)	
	-- Check the ent is valid
	if (!ent || !ent:IsValid()) then return end

	-- Get the physics object
	local phys = ent:GetPhysicsObject();
	if (!phys || !phys:IsValid()) then return end

	-- Check if the ent is being held
	if (table.Count(ent:GetHolding()) != 0) then
		-- Get the holder
		local holder = self.Owner:GetHolder();
		if (!holder || !holder:IsValid()) then return end
		
		-- Make sure the player is the main holder
		if (!holder:Constrained(ent)) then return end
		
		self:ClearHeld(false, true);
	end
	
	-- Make sure the player isn't standing on the entity
	if (self.Owner:GetGroundEntity() == ent) then return end
	
	-- Stop, drop and freeze
	phys:Sleep();
	phys:EnableMotion(false);
end

function SWEP:Think()	
	self:MoveHolder();
	self:CheckHeld();
end

function SWEP:CheckHeld()
	-- Get the held entity
	local held = self:GetHeld();
	if (!held || !held:IsValid()) then return end
	
	-- Get the holder
	local holder = self.Owner:GetHolder();
	if (!holder || !holder:IsValid()) then return end
	
	local distance = 200;
	local constrained = holder:Constrained(held);
	
	if (!constrained) then 
		distance = 100 
	else
		-- Make sure the physics are awake
		local phys = held:GetPhysicsObject()
		
		if (phys && phys:IsValid()) then
			if (phys:IsAsleep()) then
				phys:Wake()
			end
			
			if (!phys:IsMoveable()) then
				phys:EnableMotion(true)
			end
		end
		
		-- Check the mass
		if (held:Mass(holder) > 200 * table.Count(held:GetHolding())) then
			self:Drop();
		end
	end
	
	-- Check the distance
	if (self.Owner:GetPos():Distance(held:GetPos()) > distance) then
		self:Drop();
	end
end

function SWEP:MoveHolder()
	-- Get the holder
	local holder, bone = self.Owner:GetHolder();
	if (!holder || !holder:IsValid()) then return end
	
	local aimVector = self.Owner:GetAimVector();
	local matrix = Matrix();
	matrix:Rotate(aimVector:Angle());
	matrix:Rotate(self.currentRotation);
	
	-- Move the holder
	holder:SetPos(self.Owner:GetShootPos() + (aimVector * 80));
	holder:SetAngles(matrix:GetAngles());
end

function SWEP:SendHeld()
	-- Check the player is valid
	if (!self.Owner || !self.Owner:IsPlayer()) then return end
	
	-- Get the held ent
	local held = self:GetHeld();
	if (!held || !held:IsValid()) then return end
	
	-- Get the holder
	local holder = self.Owner:GetHolder();
	if (!holder || !holder:IsValid()) then return end
	
	umsg.Start("Hands.SendHeld", self.Owner);
		umsg.Long(held:EntIndex());
		umsg.Float(held:Mass(holder));
	umsg.End();
end

function SWEP:SendRotating()
	-- Check the player is valid
	if (!self.Owner || !self.Owner:IsPlayer()) then return end
	
	umsg.Start("Hands.SetRotating", self.Owner);
		umsg.Bool(self:IsRotating());
	umsg.End();
end

function SWEP:SendClearHeld()
	umsg.Start("Hands.ClearHeld", self.Owner);
	umsg.End();
end

function entMeta:Constrained (ent)
	for _, tgt in pairs (constraint.GetAllConstrainedEntities(self)) do
		if (tgt == ent) then return true end
	end
end

function entMeta:Mass (ignore)
	local mass = 0;

	for _, ent in pairs (constraint.GetAllConstrainedEntities(self)) do
		if (ent != ignore) then
			local phys = ent:GetPhysicsObject();
			
			if (phys && phys:IsValid()) then
				mass = mass + phys:GetMass();
			end
		end
	end
	
	return mass;
end

function entMeta:UpdateHolding(recipient)
	if (!recipient) then
		recipient = RecipientFilter();
		recipient:AddAllPlayers();
	end
	
	umsg.Start("Hands.UpdateHolding", recipient)
		umsg.Long(self:EntIndex());
		umsg.Short(table.Count(self:GetHolding()));
	umsg.End();
end

function plyMeta:GetHolder ()
	if (self.holder && self.holder:IsValid()) then
		return self.holder, (self.holdBone or 0);
	end
	
	return self:CreateHolder();
end

function plyMeta:CreateHolder ()
	local ent, phys, bone = constraint.CreateStaticAnchorPoint(self:GetPos())
	self.holder = ent;
	ent:SetOwner(self);
	self.holdBone = bone;
	self.holderOffset = Angle(0, 0, 0);
	ent:SetNoDraw(true);
	
	return ent, bone;
end

function hands.BlockPickupGround(ply, ent)
	if (ply:GetGroundEntity() == ent) then
		return false;
	end
end
hook.Add("HandsCanPickup", "hands.BlockPickupGround", hands.BlockPickupGround);

function hands.BlockPickupWorld(ply, ent)
	for _, data in pairs (constraint.FindConstraints(ent, 'Weld') or {}) do
		if (data.Ent1:IsWorld() || data.Ent2:IsWorld()) then return false end
	end
end
hook.Add("HandsCanPickup", "hands.BlockPickupWorld", hands.BlockPickupWorld);

function hands.BlockPickupHolding(ply, ent)
	for id, holding in pairs (ent:GetHolding()) do
		local tgt = player.GetByUniqueID(id);
		
		if (tgt && tgt:IsPlayer()) then
			local holder = tgt:GetHolder();
			
			if (holder && holder:IsValid()) then
				if (holder:Constrained(ent)) then return false end
			end
		end
	end
end
hook.Add("HandsCanPickup", "hands.BlockPickupHolding", hands.BlockPickupHolding);

function hands.BlockDamage (ply, ent)
	if (!ent || !ent:IsValid() || ent:IsWorld()) then return end
	
	if (ent.thrown && CurTime() - ent.thrown < 5) then
		ply:SetHealth(ply:Health() - math.random(1, 5));
		if (ply:Health() <= 0) then ply:Kill() end
		return false;
	end
	
	for _, attacker in pairs (player.GetAll()) do
		local holder = attacker:GetHolder();
		
		if (holder && holder:IsValid()) then
			if (holder:Constrained(ent)) then return false end
		end
	end
end
hook.Add('PlayerShouldTakeDamage', 'hands.BlockDamage', hands.BlockDamage);

function hands.KeyPressed(ply, key)
	if (key == IN_USE) then
		local wep = ply:GetActiveWeapon();
		
		if (wep && wep:IsValid() && wep:GetClass() == Fruju.HandsClass) then
			wep:SetRotating(true);
		end
	end
end
hook.Add("KeyPress", "hands.KeyPressed", hands.KeyPressed);

function hands.KeyReleased(ply, key)
	if (key == IN_USE) then
		local wep = ply:GetActiveWeapon();
		
		if (wep && wep:IsValid() && wep:GetClass() == Fruju.HandsClass) then
			wep:SetRotating(false);
		end
	end
end
hook.Add("KeyRelease", "hands.KeyReleased", hands.KeyReleased);

function hands.PerformRotation(ply, cmd, args)
	local wep = ply:GetActiveWeapon();
	
	if (wep && wep:IsValid() && wep:GetClass() == Fruju.HandsClass) then
		if (wep:IsRotating()) then	
			local x = args[1];
			local y = args[2];
				
			wep.currentRotation:RotateAroundAxis(Vector(0, 1, 0), -y * 0.005);
			wep.currentRotation:RotateAroundAxis(Vector(0, 0, 1), x * 0.005);	
		end
	end
end
concommand.Add("hands.SendRotation", hands.PerformRotation);