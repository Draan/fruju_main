AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')

include('shared.lua')
 
 
SWEP.Weight = 5
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false 

function SWEP:Deploy ()
	self:SetWeaponHoldType("melee")
end

function SWEP:Equip ()
	self:SetWeaponHoldType("melee")
end

function SWEP:ArrestVehicle (ent)
	local ply = ent:GetDriver()
	if (!ply || !ply:IsPlayer()) then return end
	
	ply:ExitVehicle()
	if (!ply.Criminal) then ply:SetCriminal(true) end
	
	ent:Lock()
end