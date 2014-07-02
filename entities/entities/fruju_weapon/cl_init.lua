include('shared.lua')

function ENT.HandIcon(ply, wep)
	local target = ply:Target().Entity;
	
	if (!target || !target:IsValid()) then return end
	if (target:GetClass() != "fruju_weapon") then return end
	
	return "gun";
end
hook.Add("HandsHudTexture", "Weapon.HandIcon", ENT.HandIcon);