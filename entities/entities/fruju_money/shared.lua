ENT.Type = "anim"
ENT.Base = "fruju_base"
  
ENT.PrintName = "Money"
ENT.Author = "Rory"
ENT.Contact = "-"
ENT.Purpose = "Money Entity"
ENT.Instructions = "-" 

ENT.Spawnable			= false
ENT.AdminSpawnable		= false	

function ENT:SetMoney (money)
	self.Entity.Money = money
end