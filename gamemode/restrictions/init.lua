AddCSLuaFile('shared.lua')
include('shared.lua')

function Restrictions.Noclip (ply)
	local level = ply:GetLevel()
	if (!level || !level.Noclip) then return false end
	
	return true
end
hook.Add('PlayerNoClip', 'Restrictions.Noclip', Restrictions.Noclip)

function Restrictions.SpawnProp (ply, mdl)
	local level = ply:GetLevel()
	if (!level || !level.Props) then return false end
	
	if (type(level.Props) == 'boolean' || level.Props[mdl]) then
		return true
	end

	return false
end
hook.Add('PlayerSpawnProp', 'Restrictions.SpawnProp', Restrictions.SpawnProp)

function Restrictions.SpawnVehicle (ply, mdl)
	local level = ply:GetLevel()
	if (!level || !level.Cars) then return false end

	if (type(level.Cars) == 'boolean' || level.Cars[mdl]) then
		return true
	end

	return false
end
hook.Add('PlayerSpawnVehicle', 'Restrictions.SpawnVehicle', Restrictions.SpawnVehicle)

function Restrictions.SpawnRagdoll (ply, mdl)
	local level = ply:GetLevel()
	if (!level || !level.Ragdolls) then return false end
	
	if (type(level.Ragdolls) == 'boolean' || level.Ragdolls[mdl]) then
		return true
	end

	return false
end
hook.Add('PlayerSpawnRagdoll', 'Restrictions.SpawnRagdoll', Restrictions.SpawnRagdoll)

function Restrictions.SpawnNPC (ply, npc)
	local level = ply:GetLevel()
	if (!level || !level.NPCs) then return false end
	
	if (type(level.NPCs) == 'boolean' || level.NPCs[npc]) then
		return true
	end

	return false
end
hook.Add('PlayerSpawnNPC', 'Restrictions.SpawnNPC', Restrictions.SpawnNPC)

function Restrictions.SpawnSENT (ply, class)
	local level = ply:GetLevel()
	if (!level || !level.Entities) then return false end
	
	if (type(level.Entities) == 'boolean' || level.Entities[class]) then
		return true
	end

	return false
end
hook.Add('PlayerSpawnSENT', 'Restrictions.SpawnSENT', Restrictions.SpawnSENT)

function Restrictions.SpawnEffect (ply, mdl)
	local level = ply:GetLevel()
	if (!level || !level.Effects) then return false end
	
	if (type(level.Effects) == 'boolean' || level.Effects[mdl]) then
		return true
	end

	return false
end
hook.Add('PlayerSpawnEffect', 'Restrictions.SpawnEffect', Restrictions.SpawnEffect)

function Restrictions.SpawnWeapon (ply, class, wep)
	local level = ply:GetLevel()
	if (!level || !level.Weapons) then return false end
	
	if (type(level.Weapons) == 'boolean' || level.Weapons[class]) then
		gamemode.Call("PlayerSpawnFrujuWeapon", ply, class, wep);
	end

	return false;
end
hook.Add('PlayerSpawnSWEP', 'Restrictions.SpawnWeapon', Restrictions.SpawnWeapon)

function Restrictions.GiveWeapon (ply, class, wep)
	local level = ply:GetLevel()
	if (!level || !level.Weapons) then return false end
	
	if (type(level.Weapons) == 'boolean' || level.Weapons[class]) then
		return true;
	end

	return false;
end
hook.Add('PlayerGiveSWEP', 'Restrictions.GiveWeapon', Restrictions.GiveWeapon)

function Restrictions.Toolgun (ply, tr, tool)
	local level = ply:GetLevel()
	if (!level || !level.Tools) then return false end

	if (type(level.Tools) != 'boolean' && !level.Tools[tool]) then return false end

	if (!tr.Entity || !tr.Entity:IsValid()) then return end
	local class = tr.Entity:GetClass()
	if (!class) then return end

	if (level.BlockTool && level.BlockTool[class]) then return false end

	return true
end
hook.Add('CanTool', 'Restrictions.Toolgun', Restrictions.Toolgun)

function Restrictions.CarGun (ply, ent)	
	ent:Fire('FinishRemoveTauCannon','True',0) 
end
hook.Add('PlayerEnteredVehicle', 'Restrictions.CarGun', Restrictions.CarGun)

function GM:PlayerSpawnFrujuWeapon()
end