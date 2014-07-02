local Property = FindMetaTable('Entity')

util.PrecacheSound('doors/default_locked.wav')
util.PrecacheSound('doors/door_latch3.wav')

// Shared
function Property:AddOwner (ply)
	if (!ply || !ply:IsPlayer()) then return end
	if (!self.Owners) then self.Owners = {} end
	
	local id = 0
	if (SERVER) then id = ply:UniqueID() else id = ply:EntIndex() end
	self.Owners[id] = true
	
	if (SERVER) then self:AddOwnerCL(ply) end
end

function Property:RemoveOwner (ply)
	if (!ply || !ply:IsPlayer()) then return end
	if (!self.Owners) then self.Owners = {} end
	
	local id = 0
	if (SERVER) then id = ply:UniqueID() else id = ply:EntIndex() end
	self.Owners[id] = nil
	
	if (SERVER) then self:RemoveOwnerCL(ply) end
end

function Property:Lock ()
	self.Locked = true
	
	if (SERVER) then
		self:Fire('lock', true)
		self:UpdateLocked() 
		
		self:EmitSound("doors/default_locked.wav");
	end
end

function Property:Unlock ()
	self.Locked = false
	
	if (SERVER) then 
		self:Fire('unlock', true)
		self:UpdateLocked() 
		
		self:EmitSound("doors/door_latch3.wav");
	end
end

function Property:SetRamLevel (level)
	self.RamLevel = level
	
	if (SERVER) then self:UpdateRamLevel() end
end

function Property:SetRamTime (time)
	self.RamTime = time
	
	if (SERVER) then self:UpdateRamTime() end
end


function Property:SetName (name)
	if (type(name) != 'string') then return end
	
	self.Name = name
	
	if (SERVER) then self:UpdateName() end
end

function Property:IsProperty ()
	if (!self:IsValid()) then return false end

	return Config.Property[self:GetClass()]
end

function Property:IsOwner (ply)
	if (!self.Owners) then return end

	local id = 0
	if (SERVER) then id = ply:UniqueID() else id = ply:EntIndex() end
	return self.Owners[id]
end

function Property.GetAll ()
	local property = {}
	
	for _, ent in pairs (ents.GetAll()) do
		if (ent:IsValid() && ent:IsProperty()) then
			table.insert(property, ent)
		end
	end
	
	return property
end

function Property:IsOwned ()
	if (!self.Owners) then return end

	for _, owned in pairs (self.Owners) do
		if (owned) then
			return true
		end
	end
end