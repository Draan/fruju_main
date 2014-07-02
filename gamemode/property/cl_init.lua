include('shared.lua')

local Property = FindMetaTable('Entity')

function Property.AddOwnerCL (umsg)
	local ent = Entity(umsg:ReadShort())
	local ply = player.GetByID(umsg:ReadChar())
	
	if (!ent || !ent:IsValid()) then return end
	if (!ply || !ply:IsPlayer()) then return end
	
	ent:AddOwner(ply)
	
	return true
end
usermessage.Hook('Property.AddOwner', Property.AddOwnerCL)

function Property.RemoveOwnerCL (umsg)
	local ent = Entity(umsg:ReadShort())
	local ply = player.GetByID(umsg:ReadChar())
	
	if (!ent || !ent:IsValid()) then return end
	if (!ply || !ply:IsPlayer()) then return end
	
	ent:RemoveOwner(ply)
	
	return true
end
usermessage.Hook('Property.RemoveOwner', Property.RemoveOwnerCL)

function Property.UpdateName (umsg)
	local ent = Entity(umsg:ReadShort())
	local name = umsg:ReadString()
	
	if (!ent || !ent:IsValid()) then return end
	if (type(name) != 'string') then return end
	
	ent:SetName(name)
	
	return true
end
usermessage.Hook('Property.UpdateName', Property.UpdateName)

function Property.UpdateLocked (umsg)
	local ent = Entity(umsg:ReadShort())
	local locked = umsg:ReadBool()
	
	if  (!ent || !ent:IsValid()) then return end
	
	ent.Locked = locked
	
	return true
end
usermessage.Hook('Property.UpdateLocked', Property.UpdateLocked)

function Property.UpdateRamLevel (umsg)		
	local ent = Entity(umsg:ReadShort())
	local level = umsg:ReadChar()
	
	if (!ent || !ent:IsValid()) then return end
	
	ent:SetRamLevel(level)
	
	return true
end
usermessage.Hook('Property.UpdateRamLevel', Property.UpdateRamLevel)

function Property.UpdateRamTime (umsg)		
	local ent = Entity(umsg:ReadShort())
	local time = umsg:ReadFloat()
	
	if (!ent || !ent:IsValid()) then return end
	
	ent:SetRamTime(time)
	
	return true
end
usermessage.Hook('Property.UpdateRamTime', Property.UpdateRamTime)

// Request
function Property.RequestProperty (ent)
	if (!ent || !ent:IsValid() || !ent:IsProperty()) then return end
	
	RunConsoleCommand('Property.Request', ent:EntIndex())
end
hook.Add('OnEntityCreated', 'Property.Request', Property.RequestProperty)

function Property.RequestSpawn (ply)
	if (!ply || ply != LocalPlayer()) then return end
	
	for _, ent in pairs (Property.GetAll()) do
		Property.RequestProperty(ent);
	end
end
hook.Add('PlayerCreated', 'Property.RequestSpawn', Property.RequestSpawn)

function Property.GetHandsTexture(ply, wep)
	-- Get the players target
	local target = ply:Target().Entity;
	
	if (!target || !target:IsValid()) then return end
	if (!target:IsProperty() && !target:IsVehicle()) then return end
	
	if (target:IsOwner(ply)) then
		if (target.Locked) then
			return "locked"
		else
			return "unlocked"
		end
	elseif (target:GetClass() == "fruju_pump") then
		return "pump";
	elseif (target:GetClass() == 'prop_vehicle_prisoner_pod') then		
		if (target.Passenger) then
			return "car";
		else
			return "chair";
		end
	elseif (string.find(target:GetClass(), 'vehicle')) then
		return "car"
	else
		return "fist"
	end
end
hook.Add("HandsHudTexture", "Property.GetHandsTexture", Property.GetHandsTexture);