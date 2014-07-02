AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')

include('shared.lua')
 
SWEP.Weight = 5
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false 

// Sounds
SWEP.RamSound = {}
SWEP.RamSound[1] = 'physics/wood/wood_box_impact_hard1.wav'
SWEP.RamSound[2] = 'physics/wood/wood_box_impact_hard2.wav'
SWEP.RamSound[3] = 'physics/wood/wood_box_impact_hard3.wav'
SWEP.RamSound[4] = 'physics/wood/wood_crate_impact_hard5.wav'
SWEP.RamSound[5] = 'physics/wood/wood_crate_impact_hard1.wav'

SWEP.LevelSound = {}
SWEP.LevelSound[1] = 'physics/wood/wood_panel_break1.wav'
SWEP.LevelSound[2] = 'physics/wood/wood_plank_break3.wav'
SWEP.LevelSound[3] = 'physics/wood/wood_plank_break4.wav'
SWEP.LevelSound[4] = 'physics/wood/wood_plank_break1.wav'

SWEP.SucceedSound = 'doors/heavy_metal_stop1.wav'

// Property information
SWEP.Property = {}

// Secondary attack
function SWEP:SecondaryAttack ()
	return false
end

function SWEP:Deploy ()
	self:SetWeaponHoldType("rpg")
end

function SWEP:Equip ()
	self:SetWeaponHoldType("rpg")
end

// Primary attack
function SWEP:PrimaryAttack ()
	// Check the owner is a player
	if (!self.Owner:IsPlayer()) then return end

	// Get the target
	local target = self.Owner:Target().Entity
	if (!target || !target:IsValid() || !target:IsProperty()) then return end
	
	// Set the chance and level to 0
	local chance = 0
	local level = 0
	
	// Select a sound to play
	local sound = self.RamSound[math.random(table.Count(self.RamSound))]
	
	// Get the chance and level based on whether the owner is a police officer
	if (self.Owner.Cop) then
		chance = 2
		level = 2
	else
		chance = 4
		level = 4
	end
	
	// Check if it is time to reset the targets level
	if (target.RamTime) then
		if (CurTime() - target.RamTime > 60) then
			target:SetRamLevel(0)
		end
	end
	
	// Have an attempt at ramming the property
	if (1 == math.random(1, chance)) then
		// Add to the targets level
		target:SetRamLevel((target.RamLevel or 0) + 1)
		
		// Check if the targets level is over the owners level
		if (target.RamLevel >= level) then
			self.Weapon:Success(target)
		end
		
		// Change the sound of the entity
		sound = self.LevelSound[math.random(table.Count(self.LevelSound))]
	end
	
	// Update the properties ram time
	target:SetRamTime(CurTime())
	
	// Run the fire effects
	self.Owner:ViewPunch(Angle(-5,0,0))
	target:EmitSound(sound)
	self.Weapon:SetNextPrimaryFire(CurTime() + 1.5)
end

// Success
function SWEP:Success (target)
	// Unlock/open the target
	target:Unlock()
	target:Fire('Open', '')
	
	// Check if the open effects should be run on the target
	if (target:GetClass() == 'prop_door_rotating') then
		self.Weapon:OpenEffects (target)
	else
		// Play the success sound
		target:EmitSound(self.SucceedSound)
	end	
	
	// Set the ram level back to 0
	target:SetRamLevel(0)
end

// Open effect
function SWEP:OpenEffects (target)
	// Create a fake door
	local fake = ents.Create('prop_physics')
	fake:SetModel(target:GetModel())
	fake:SetPos(target:GetPos())
	fake:SetAngles(target:GetAngles())
	fake:SetSkin(target:GetSkin())
	
	// Set the color of the fake
	local r, g, b, a = target:GetColor()
	fake:SetColor( target:GetColor() )
	
	// Store the fake door on the real door and set the alpha level of the real door
	target.Fake = fake
	target.FakePos = target:GetPos()
	target:SetRenderMode( 10 )  -- Totally hide that sheet
	target:SetColor( Color(0, 0, 0, 0) )
	target:SetNotSolid(true);
	
	// Spawn the fake door
	fake:Spawn()
	fake:EmitSound(self.SucceedSound)
	
	// Knock the fake door over	
	local phys = fake:GetPhysicsObject();
	
	if (phys && phys:IsValid()) then
		local tr = self.Owner:Target();
		
		local force = phys:GetMass() * 350;
		phys:ApplyForceOffset(self.Owner:GetAimVector() * force, tr.HitPos);
	end
	// Make sure this door stays open
	Fruju.KeepOpen(target)
end

// Keep open
function Fruju.KeepOpen (target) 

	if (CurTime() - target.RamTime < 30) then
		// Keep the target open
		target:Fire('Open', '')
		
		// Call this again 1 second later
		timer.Simple(1, function() Fruju.KeepOpen(target) end)
	else
		// Return the door to normal
		Fruju.ReturnDoor (target)
	end
end

// Return door
function Fruju.ReturnDoor (target)
	// Set the real doors position back to normal
	target:SetNotSolid(false);
	
	// Set the color of the fake
	target:SetRenderMode( 0 )  -- Stop hiding that sheet
	target:SetColor( target.Fake:GetColor() )
	
	// Close the real door
	target:Fire('Close', '')
	target:SetRamLevel(0)
	
	// Remove the fake door if needed
	if (target.Fake && target.Fake:IsValid()) then 
		target.Fake:Remove() 
	end
end

// Clear ram time
function Fruju.ClearLevel ()
	for _, ent in pairs (ents.GetAll()) do
		if (ent:IsValid() && ent.RamLevel && ent.RamTime) then
			if (ent.RamLevel > 0) then
				if (CurTime() - ent.RamTime > 60) then
					ent:SetRamLevel(0)
				end
			end
		end
	end
end
hook.Add('Think', 'Fruju.ClearLevel', Fruju.ClearLevel)
