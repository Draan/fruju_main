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

function ENT:AcceptInput ()
end

function ENT:KeyValue ()
end

function ENT:OnRemove ()
end

function ENT:OnRestore ()
end

function ENT:OnTakeDamage ()
end

function ENT:PhysicsCollide ()
end

function ENT:PhysicsSimulate ()
end

function ENT:PhysicsUpdate ()
end

function ENT:StartTouch ()
end

function ENT:Think ()
end

function ENT:Touch ()
end

function ENT:UpdateTransmitState ()
end

function ENT:Use ()
end