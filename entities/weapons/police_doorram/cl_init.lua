include('shared.lua')
 
 
SWEP.PrintName = "Door Ram"
SWEP.Slot = 2
SWEP.SlotPos = 2
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = false 

// Block the click noise
function SWEP:PrimaryAttack()
end

// Block the click noise
function SWEP:SecondaryAttack()
end

// Hud
function Fruju.RamHud ()
	local ply = LocalPlayer()
	if (!ply || !ply:IsPlayer()) then return end
	
	if (ply:InVehicle()) then return end
	
	local wep = ply:GetActiveWeapon()
	if (!wep || !wep:IsWeapon()) then return end
	if (wep:GetClass() != 'police_doorram') then return end
	
	// Get the target
	local target = ply:Target().Entity
	if (!target || !target:IsValid() || !target:IsProperty()) then return end
	
	local level = 2
	if (!ply.Cop) then level = 4 end
	
	local progress = (target.RamLevel or 0) / level
	if (progress < 0) then progress = 0 end
	if (progress > 1) then progress = 1 end
	progress = math.ceil(progress * 100)
	progress = progress..'%'
	
	// Draw the charge
	surface.SetFont('FrujuFont')
	
	local w = surface.GetTextSize('Progress: ')
	
	local x = (ScrW() - (w + surface.GetTextSize(progress))) / 2
	local y = ScrH() - 50
	
	// Draw the progress
	draw.SimpleText('Progress: ', 'FrujuFont', x, y, purple)
	draw.SimpleText(progress, 'FrujuFont', x+w, y, white)
end
hook.Add('HUDPaint', 'Fruju.RamHud', Fruju.RamHud)
