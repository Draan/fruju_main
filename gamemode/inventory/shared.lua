Item = {}
Item.__index = Item
Inventory = {};

local Entity = FindMetaTable('Entity')

function Entity:CreateInventory (size)
	self.Inventory = {}
	self.Inventory.Items = {}
	self.Inventory.TotalSize = size or 0
	self.Inventory.Size = 0
end

function Entity:GetInventory ()
	return self.Inventory
end

function Entity:GetItem (id)
	local inventory = self:GetInventory()
	if (!inventory) then return end
	
	return inventory.Items[id]
end

function Entity:GetItems()
	local inventory = self:GetInventory(Config.InventorySize)
	if (!inventory) then return {} end
	
	return inventory.Items or {}
end

function Entity:AddItem (class, name, model, material, colour, skin, mass, size, id)
	if (!self.Inventory) then 
		self:CreateInventory();
	end
	
	local mt = setmetatable({Class = class, Name = name, Model = model, Material = material, Colour = colour, Skin = skin, Mass = mass, Size = size, Data = {}, Parent = self, ID = id or 0}, Item)
	
	if (id) then
		self.Inventory.Items[id] = mt
	else
		id = table.insert(self.Inventory.Items, mt)
		mt.ID = id;
	end
	
	self:UpdateSize();
	
	if (SERVER) then
		self:AddItemCL(id)
	end
	
	return mt;
end

function Entity:RemoveItem (id)
	local item = self:GetItem(id)
	if (!item) then return end
	
	self.Inventory.Items[id] = nil
	
	self:UpdateSize();
	
	if (SERVER) then
		self:RemoveItemCL(id)
	end
end

function Entity:UpdateSize ()
	local inventory = self:GetInventory()
	if (!inventory) then return end

	local size = 0
	
	for _, item in pairs (inventory.Items) do
		size = size + (item.Mass or 0)
	end
	
	self.Inventory.Size = size
end

function Item:GetData ()
	return self.Data
end

function Item:SetData (tbl)
	self.Data = tbl
end

function Item:GetClass()
	return self.Class;
end

function Item:SetClass(class)
	self.Class = class;
	
	if (SERVER && self.Parent:IsValid()) then
		self.Parent:UpdateItem(self.ID);
	end
end

function Item:GetName()
	return self.Name;
end

function Item:SetName(name)
	self.Name = name;
	
	if (SERVER && self.Parent:IsValid()) then
		self.Parent:UpdateItem(self.ID);
	end
end

function Item:GetModel()
	return self.Model;
end

function Item:SetModel(model)
	self.Model = model;
	
	if (SERVER && self.Parent:IsValid()) then
		self.Parent:UpdateItem(self.ID);
	end
end

function Item:GetMaterial()
	return self.Material;
end

function Item:SetMaterial(material)
	self.Material = material;
	
	if (SERVER && self.Parent:IsValid()) then
		self.Parent:UpdateItem(self.ID);
	end
end

function Item:GetColour()
	return self.Colour;
end

function Item:SetColour(colour)
	self.Colour = colour;
	
	if (SERVER && self.Parent:IsValid()) then
		self.Parent:UpdateItem(self.ID);
	end
end

function Item:GetSkin()
	return self.Skin;
end

function Item:SetSkin(skin)
	self.Skin = skin;
	
	if (SERVER && self.Parent:IsValid()) then
		self.Parent:UpdateItem(self.ID);
	end
end

function Item:GetMass()
	return self.Mass;
end

function Item:SetMass(mass)
	self.Mass = mass;
	
	if (SERVER && self.Parent:IsValid()) then
		self.Parent:UpdateItem(self.ID);
	end
end

function Item:SetSize(size)
	self.Size = size;
	
	if (SERVER && self.Parent:IsValid()) then
		self.Parent:UpdateItem(self.ID);
	end
end

function Item:GetSize()
	return self.Size;
end