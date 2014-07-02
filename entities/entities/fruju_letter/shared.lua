ENT.Type = "anim"
ENT.Base = "fruju_base"
  
ENT.PrintName = "Letter"
ENT.Author = "Rory"
ENT.Contact = "-"
ENT.Purpose = "Letter Entity"
ENT.Instructions = "-" 

ENT.Spawnable			= false
ENT.AdminSpawnable		= false	

function ENT:OnRemove ()
	self.Entity.Letter = nil
	self.Entity.Writer = nil
end