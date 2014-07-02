Restrictions = {}

function Restrictions.Physgun (ply, ent)
	local level = ply:GetLevel()
	if (!level || !level.Physgun) then return end
	
	if (!ent || !ent:IsValid()) then return end
	local class = ent:GetClass()
	if (!class) then return end
	
	if (type(level.Physgun) != 'boolean' && level.Physgun[class]) then return false end
	
	return true
end
hook.Add('PhysgunPickup', 'Restrictions.Physgun', Restrictions.Physgun)
