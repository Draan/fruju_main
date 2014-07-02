AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")

function ENT:Initialize ()
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS ) 
	
	if (self.Entity:GetPhysicsObject():IsValid()) then
		self.Entity:GetPhysicsObject():Wake()
	end 
end

function ENT:Use (ply)
	if (ply:KeyDown(IN_SPEED)) then return end
	
	// Give the player the money
	ply:SetMoney(ply:GetMoney() + (self.Entity.Money or 0))
	ply:Hint('You have picked up '..Fruju.FormatMoney(self.Entity.Money)..'.')
	
	self.Entity:Remove()
end

function ENT:Send (recipient)
	if (recipient) then
		recipient = RecipientFilter()
		recipient:AddAllPlayers()
	end
	
	umsg.Start('umsg', recipient)
	umsg.String('Money.Send')
		umsg.Long(self.Entity:EntIndex())
		umsg.Float(self.Entity.Money or 0)
	umsg.End()
end

function Fruju.RequestMoney (ply, command, args)
	local ent = Entity(args[1])
	if (!ent || !ent:IsValid() || ent:GetClass() != 'fruju_money') then return end
	
	ent:Send(ply)
end
concommand.Add('Money.Request', Fruju.RequestMoney)

function ENT.InventoryPickup(ent, item)
	if (ent:GetClass() != "fruju_money") then return end
	
	-- Store the money info
	item:SetName("Money("..Fruju.FormatMoney(ent.Money)..")");
	item:SetData({Money = ent.Money});
end
hook.Add("InventoryItemPickedUp", "FrujuMoney.InventoryPickup", ENT.InventoryPickup);

function ENT.InventoryDrop(ent, item)
	if (item:GetClass() != "fruju_money") then return end
	
	-- Get the data
	local data = item:GetData();
	if (!data) then return end
	
	-- Restore the money info
	ent:SetMoney(data.Money);
end
hook.Add("InventoryItemDropped", "FrujuMoney.InventoryDrop", ENT.InventoryDrop);