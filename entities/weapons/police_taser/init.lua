AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')

include('shared.lua')
 
SWEP.Weight = 5
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false 

SWEP.Sound = 'npc/scanner/scanner_electric1.wav'

// Primary attack
function SWEP:PrimaryAttack ()	
	if (!self.Owner.Cop) then return end
	local target = self.Owner:Target(400).Entity
	if (!target or target:IsWorld() or !target:IsPlayer()) then return end

	// Check the charge time is over
	if (!self.UseTime) then self.UseTime = 0 end
	if (CurTime() - self.UseTime < 2) then return end
	self.UseTime = CurTime()
	
	self.Weapon:FireEffect()
	
	// Damage players health
	target:SetHealth(target:Health() - math.random(0, 10))

	// check if the player is dead
	if (target:Health() < 0) then target:Kill() end
		
	// Make target sleep
	target:Sleep(nil, nil, true)
	timer.Simple(30, function() Fruju.TazerWake(target) end)
	target.Stunned = true

	// Animate the owner
	self.BaseClass.ShootEffects( self ) 
	self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
	self.Owner:SetAnimation(PLAYER_ATTACK1)
end

function SWEP:SecondaryAttack()
 
	if ( CLIENT ) then return end 
    
	local target = self.Owner:Target(400).Entity
	if (!target or !target:IsValid() or target:IsWorld()) then return end
	if (target:GetClass() != "prop_ragdoll") then return end

	local shock1 = math.random(-1200, 1200 )
	local shock2 = math.random(-1200, 1200 )
	local shock3 = math.random(-1200, 1200 )
	self.Owner:EmitSound( "Weapon_SMG1.Empty")
	target:GetPhysicsObject():ApplyForceCenter( Vector( shock1, shock2, shock3 ) )    
	
	// Animate the owner
	self.BaseClass.ShootEffects( self ) 
	self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
	self.Owner:SetAnimation(PLAYER_ATTACK1)
end

// Fire effect
function SWEP:FireEffect ()	
	// Fire sound
	self.Owner:EmitSound(self.Sound)
end

// Wake
function Fruju.TazerWake (ply)
	if (!ply || !ply:IsPlayer()) then return end
	
	// Check they are tazed
	if (ply.Stunned) then
		ply:Wake(true)
		ply:UpdateLoadout()
	end
end