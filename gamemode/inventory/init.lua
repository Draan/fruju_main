AddCSLuaFile('shared.lua')
AddCSLuaFile('cl_init.lua')
AddCSLuaFile('cl_gui.lua')

include('shared.lua')

local Entity = FindMetaTable('Entity')

function Entity:AddItemCL (id, recipient)
	if (!recipient) then
		recipient = RecipientFilter()
		recipient:AddAllPlayers()
	end
	
	local item = self:GetItem(id)
	if (!item) then return end
	
	umsg.Start('Inventory.AddItem', recipient)
		umsg.Short(self:EntIndex())
		umsg.Short(id)
		umsg.String(item.Class)
		umsg.String(item.Name)
		umsg.String(item.Model)
		umsg.String(item.Material)
		umsg.Short(item.Colour.r)
		umsg.Short(item.Colour.g)
		umsg.Short(item.Colour.b)
		umsg.Short(item.Colour.a)
		umsg.Short(item.Skin)
		umsg.Short(item.Mass)
		umsg.Short(item.Size)
	umsg.End()
end

function Entity:RemoveItemCL (id, recipient)
	if (!recipient) then
		recipient = RecipientFilter()
		recipient:AddAllPlayers()
	end
	
	umsg.Start('Inventory.RemoveItem', recipient)
		umsg.Short(self:EntIndex())
		umsg.Short(id)
	umsg.End()
end

function Entity:UpdateItem (id, recipient)
	if (!recipient) then
		recipient = RecipientFilter()
		recipient:AddAllPlayers()
	end
	
	local item = self:GetItem(id)
	if (!item) then return end
	
	umsg.Start('Inventory.Update', recipient)
		umsg.Short(self:EntIndex())
		umsg.Short(id)
		umsg.String(item.Class)
		umsg.String(item.Name)
		umsg.String(item.Model)
		umsg.String(item.Material)
		umsg.Short(item.Colour.r)
		umsg.Short(item.Colour.g)
		umsg.Short(item.Colour.b)
		umsg.Short(item.Colour.a)
		umsg.Short(item.Skin)
		umsg.Short(item.Mass)
		umsg.Short(item.Size)
	umsg.End()
end

function Entity:GetSize()
	local vec = self:OBBMaxs();
	
	-- Get the biggest size
	local size = vec.x;
	if (vec.y > size) then size = vec.y end
	if (vec.z > size) then size = vec.z end
	
	return size;
end

-- Open hook
function Inventory.Open(ply)
	if (!ply:Alive()) then return end

	ply:Freeze(true);
	
	umsg.Start('Inventory.Open', ply)
	umsg.End()
end
hook.Add("ShowTeam", "Inventory.Open", Inventory.Open);

-- Close command
function Inventory.Close(ply)
	if (!ply:Alive()) then return end
	
	ply:Freeze(false);
end
concommand.Add("Inventory.Close", Inventory.Close);

-- Pickup hook
function Inventory.Pickup(ply)
	if (!ply || !ply:IsPlayer()) then return end

	local wep = ply:GetActiveWeapon();
	
	-- Make sure they have their hands out
	if (!wep || !wep:IsValid()) then return end
	if (wep:GetClass() != Fruju.HandsClass) then return end
	
	-- Check if the player is holding something
	local ent = wep:GetHeld();
	if (!ent || !ent:IsValid()) then return end
	
	-- Make sure they are the primary holderer
	local holder = ply:GetHolder()
	if (!holder || !holder:IsValid()) then return end
	
	-- Get the constrained entities
	
	
	for _, tgt in pairs (constraint.GetAllConstrainedEntities(ent)) do
		if (tgt != ent && tgt != holder) then return end
	end
	
	-- Get the players inventory
	local inventory = ply:GetInventory();
	
	if (!inventory) then
		ply:CreateInventory(Config.InventorySize);
		inventory = ply:GetInventory();
	end
	
	-- Get the mass
	local phys = ent:GetPhysicsObject();
	if (!phys || !phys:IsValid()) then return end
	
	local mass = phys:GetMass();
	
	-- Check the item will fit
	if (inventory.Size + mass > inventory.TotalSize) then
		ply:Hint("You can't fit this item in your inventory.");
		return;
	end
	
	-- Check if it is a chair with a player in it
	if (ent:GetClass() == "prop_vehicle_prisoner_pod") then
		local driver = ent:GetDriver();
		
		if (driver && driver:IsPlayer()) then
			return;
		end
	end
	
	-- Check if it is a ragdoll
	if (ent:GetClass() == "prop_ragdoll") then
		return;
	end
	
	-- Add the item to the inventory
	local item = ply:AddItem(ent:GetClass(), gamemode.Call("InventoryGetName", ent), ent:GetModel(), ent:GetMaterial(), Color(255, 255, 255, 0), ent:GetSkin(), mass, ent:GetSize());
	
	gamemode.Call("InventoryItemPickedUp", ent, item);
	
	ent:Remove();
	
	return true;
end
concommand.Add("Inventory.Pickup", Inventory.Pickup);

function Inventory.DeleteItem(ply, command, args)
	if (!ply || !ply:IsPlayer()) then return end
	
	local item = ply:GetItem(tonumber(args[1]));
	if (!item) then return end
	
	ply:RemoveItem(item.ID);
end
concommand.Add("Inventory.DeleteItem", Inventory.DeleteItem);

function Inventory.DropItem(ply, command, args)
	if (!ply || !ply:IsPlayer()) then return end
	
	local item = ply:GetItem(tonumber(args[1]));
	if (!item) then return end
	
	-- Get the position in front of the player
	local tr = ply:Target(80);
	local colour = item:GetColour();
	
	-- Create the item
	local ent = ents.Create(item:GetClass());
	ent:SetModel(item:GetModel());
	ent:SetMaterial(item:GetMaterial());
	ent:SetColor(colour.r, colour.g, colour.b, colour.a);
	ent:SetSkin(item:GetSkin());
	ent:SetPos(tr.HitPos + tr.HitNormal * 16);
	ent:Spawn();
	
	-- Call the item dropped hook
	gamemode.Call("InventoryItemDropped", ent, item);
	
	-- Clear the item
	ply:RemoveItem(item.ID);
end
concommand.Add("Inventory.DropItem", Inventory.DropItem);

function GM:InventoryGetName(ent)
	-- Check the ent is valid
	if (!ent || !ent:IsValid()) then return "" end
	
	-- Get the name
	local name = string.Explode('/', ent:GetModel());
	name = string.sub(name[table.Count(name)], 0, -5);
	
	-- Remove any numbers and everything after the number
	for i = 1, string.len(name) do
		if (string.byte(string.sub(name, i, i)) >= 48 and string.byte(string.sub(name, i, i)) <= 57) then
			name = string.sub(name, 1, i-1)
			break
		end
	end
	
	-- Break into words
	name = string.Explode('_', name);
	
	for i, part in pairs (name) do
		name[i] = string.upper(string.sub(part, 1, 1))..string.lower(string.sub(part, 2));
	end
	
	-- Turn name back to string with spaces
	return string.Implode(' ', name);
end

function GM:InventoryItemPickedUp(ent, item)
end

function GM:InventoryItemDropped(ent, item)
end