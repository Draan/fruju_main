AddCSLuaFile('shared.lua')
AddCSLuaFile('cl_init.lua')

include('shared.lua')

util.PrecacheSound('physics/wood/wood_crate_impact_hard2.wav') 
util.PrecacheSound('physics/wood/wood_box_Impact_hard5.wav')

local Property = FindMetaTable('Entity')

function Property:AddOwnerCL (ply, recipient)
	if (!recipient) then
		recipient = RecipientFilter()
		recipient:AddAllPlayers()
	end
	
	if (!ply || !ply:IsPlayer()) then return end
	
	umsg.Start('Property.AddOwner', recipient)
		umsg.Short(self:EntIndex())
		umsg.Char(ply:EntIndex())
	umsg.End()
end	

function Property.Clear (ply)
	for _, ent in pairs (Property.GetAll()) do
		if (ent:IsOwner(ply)) then
			ent:RemoveOwner(ply)
		end
	end
end
hook.Add('PlayerDisconnected', 'Property.ClearDisconnect', Property.Clear)

function Property:RemoveOwnerCL (ply, recipient)
	if (!recipient) then
		recipient = RecipientFilter()
		recipient:AddAllPlayers()
	end
	
	umsg.Start('Property.RemoveOwner', recipient)
		umsg.Short(self:EntIndex())
		umsg.Char(ply:EntIndex())
	umsg.End()
end

function Property:UpdateName (recipient)
	if (!recipient) then
		recipient = RecipientFilter()
		recipient:AddAllPlayers()
	end
	
	umsg.Start('Property.UpdateName', recipient)
		umsg.Short(self:EntIndex())
		umsg.String(self.Name or '')
	umsg.End()
end

function Property:UpdateLocked (recipient)
	if (!recipient) then
		recipient = RecipientFilter()
		recipient:AddAllPlayers()
	end
	
	umsg.Start('Property.UpdateLocked', recipient)
		umsg.Short(self:EntIndex())
		umsg.Bool(self.Locked)
	umsg.End()
end

function Property:UpdateRamLevel (recipient)
	if (!recipient) then
		recipient = RecipientFilter()
		recipient:AddAllPlayers()
	end
	
	umsg.Start('Property.UpdateRamLevel', recipient)
		umsg.Short(self:EntIndex())
		umsg.Char(self.RamLevel)
	umsg.End()
end

function Property:UpdateRamTime (recipient)
	if (!recipient) then
		recipient = RecipientFilter()
		recipient:AddAllPlayers()
	end
	
	umsg.Start('Property.UpdateRamTime', recipient)
		umsg.Short(self:EntIndex())
		umsg.Float(self.RamTime)
	umsg.End()
end

function Property:UpdateProperty(recipient)
	if (!recipient) then
		recipient = RecipientFilter()
		recipient:AddAllPlayers()
	end
	
	if (!self.Owners) then return end
	
	for ply, owner in pairs (self.Owners) do			
		if (owner) then
			ply = player.GetByUniqueID(ply)
			self:AddOwnerCL(ply, recipient)
		end
	end
end

function Property.RequestProperty (ply, command, args)
	local ent = Entity(args[1])
	if (!ent || !ent:IsValid()) then return end
	
	ent:UpdateProperty(ply)
	ent:UpdateName(ply)
	ent:UpdateLocked(ply)
	ent:UpdateRamLevel(ply)
end
concommand.Add('Property.Request', Property.RequestProperty)

function Property.HandsTryPickup(wep, tr)
	local ply = wep.Owner;
	if (!ply || !ply:IsPlayer()) then return end
	
	local ent = tr.Entity;
	if (!ent || !ent:IsValid() || !ent:IsProperty()) then return end
	
	if (ent:IsOwner(ply)) then
		ent:Lock();
	elseif (!ent:IsVehicle() && ent:GetClass() != "fruju_pump") then
		ent:EmitSound('physics/wood/wood_crate_impact_hard2.wav')
	end
	
	return false;
end
hook.Add("HandsTryPickup", "Property.HandsTryPickup", Property.HandsTryPickup);

function Property.HandsSecondaryAttack(ply)
	local ent = ply:Target().Entity;
	
	if (!ent || !ent:IsValid()) then return end

	if (ent:IsProperty()) then
		if (ent:IsOwner(ply)) then
			ent:Unlock()
		elseif (!ent:IsVehicle()) then
			ent:EmitSound('physics/wood/wood_box_Impact_hard5.wav')
		end
		
		return false
	end
end
hook.Add("HandsSecondaryAttack", "Property.HandsSecondaryAttack", Property.HandsSecondaryAttack);
