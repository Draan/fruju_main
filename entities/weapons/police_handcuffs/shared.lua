SWEP.Author = "Rory"
SWEP.Contact = ""
SWEP.Purpose = ""
SWEP.Instructions = "Left click to arrest/release a player"
SWEP.Spawnable = true
SWEP.AdminSpawnable = true

SWEP.ViewModelFOV	= 62
SWEP.ViewModelFlip	= false
SWEP.ViewModel		= "models/weapons/v_stunbaton.mdl"
SWEP.WorldModel		= "models/weapons/w_stunbaton.mdl"
SWEP.AnimPrefix = "normal"

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none" 

function SWEP:PrimaryAttack ()	
	local tgt = self.Weapon:FindSuspect()
	if (!tgt || !tgt:IsValid()) then return end
	
	if (tgt:IsPlayer()) then
		tgt:SetCriminal(true)
	elseif (SERVER) then
		self.Weapon:ArrestVehicle(tgt)
	end
	
	if (SERVER) then 
		self.Owner:Hint('You have arrested '..tgt:Nick()..'.')
		tgt:Hint('You have been arrested.')
	end
	
	self.Weapon:ShootEffects()
	self.Weapon:SetNextPrimaryFire(CurTime() + 1)  
end

function SWEP:SecondaryAttack ()
	local tgt = self.Weapon:FindSuspect()
	if (!tgt || !tgt:IsValid() || !tgt.Criminal) then return end
	
	tgt:SetCriminal(false)
	
	if (SERVER) then 
		self.Owner:Hint('You have released '..tgt:Nick()..'.')
		tgt:Hint('You have been released.')
	end
	
	self.Weapon:ShootEffects()
    self.Weapon:SetNextSecondaryFire(CurTime() + 1)
end

function SWEP:FindSuspect ()
	if (!self.Owner.Cop) then return end
	
	local target = self.Owner:Target().Entity
	if (!target || !target:IsValid()) then return end
	
	if (!target:IsPlayer() && !target:IsVehicle()) then return end
	
	return target
end

function SWEP:ShootEffects ()
	self.Owner:SetAnimation(PLAYER_ATTACK1)
	self.Weapon:SendWeaponAnim(ACT_RANGE_ATTACK1)
end