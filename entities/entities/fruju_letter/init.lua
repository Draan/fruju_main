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
	if (CurTime() - (ply.LetterUseTime or -1) < 2) then return end
	
	umsg.Start('umsg', ply)
	umsg.String('Fruju.DrawLetter')
		umsg.Short(self.Entity:EntIndex())
	umsg.End()
	
	ply.LetterUseTime = CurTime();
end

function ENT:Send (recipient)
	if (!recipient) then
		recipient = RecipientFilter()
		recipient:AddAllPlayers()
	end

	umsg.Start('umsg', recipient)
	umsg.String('Fruju.Letter')
		umsg.Short(self.Entity:EntIndex())
		umsg.String(self.Entity.Writer)
		umsg.String(self.Entity.Letter)
	umsg.End()
end

function Fruju.RequestLetter (ply, command, args)
	local letter = Entity(args[1])
	if (!letter || !letter:IsValid()) then return end
	
	letter:Send(ply)
end
concommand.Add('Letter.Request', Fruju.RequestLetter)

function ENT.InventoryPickup(ent, item)
	if (ent:GetClass() != "fruju_letter") then return end
	
	-- Store the letter info
	item:SetName("Letter");
	item:SetData({Writer = ent.Writer, Letter = ent.Letter});
end
hook.Add("InventoryItemPickedUp", "FrujuLetter.InventoryPickup", ENT.InventoryPickup);

function ENT.InventoryDrop(ent, item)
	if (item:GetClass() != "fruju_letter") then return end
	
	-- Get the data
	local data = item:GetData();
	if (!data) then return end
	
	-- Restore the letter info
	ent.Writer = data.Writer;
	ent.Letter = data.Letter
end
hook.Add("InventoryItemDropped", "FrujuLetter.InventoryDrop", ENT.InventoryDrop);