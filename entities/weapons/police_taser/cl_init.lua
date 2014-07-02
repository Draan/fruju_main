include('shared.lua')
 
 
SWEP.PrintName = "Taser"
SWEP.Slot = 1
SWEP.SlotPos = 1
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = true 

// Block client noises
function SWEP:PrimaryAttack()	

	local target = self.Owner:Target(400).Entity
	if (!target || !target:IsPlayer()) then return end

	// Check the charge time is over
	if (!self.UseTime) then self.UseTime = -2 end
	if (CurTime() - self.UseTime < 2) then return end

	self.UseTime = CurTime()
end

function SWEP:SecondaryAttack()
end

function Fruju.TaserHud ()
	local ply = LocalPlayer()
	if (!ply || !ply:IsPlayer()) then return end
	
	local wep = ply:GetActiveWeapon()
	if (!wep || !wep:IsWeapon()) then return end
	if (wep:GetClass() != 'police_taser') then return end
	
	// Draw the charge
	surface.SetFont('FrujuFont')
	
	local w = surface.GetTextSize('Charge: ')
	
	local charge = (CurTime() - (wep.UseTime or -2)) / 2
	if (charge < 0) then charge = 0 end
	if (charge > 1) then charge = 1 end
	
	charge = math.ceil(charge * 100)
	charge = charge..'%'
	
	local x = (ScrW() - (w + surface.GetTextSize(charge))) / 2
	local y = ScrH() - 50
	
	// Draw the charge
	draw.SimpleText('Charge: ', 'FrujuFont', x, y, purple)
	draw.SimpleText(charge, 'FrujuFont', x+w, y, white)
end
hook.Add('HUDPaint', 'Fruju.TaserHud', Fruju.TaserHud)