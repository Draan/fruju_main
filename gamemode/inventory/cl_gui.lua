-- Another menu like the model menu
local ITEM = {}

function ITEM:Init ()
	self.Color = Color(0, 0, 0, 255)
	self.ToColor = Color(0, 0, 0, 255)
	
	self:SetCamPos(Vector(70, 80, 60));
	self:SetLookAt(Vector(0, 0, 0));
	self:SetFOV(70);
end

function ITEM:Setup(item)
	self.Item = item;
	
	self:SetModel(item:GetModel());
	self.Entity:SetMaterial(item:GetMaterial());
	self.Entity:SetSkin(item:GetSkin());
	self:SetColor(item:GetColour());
	
	self:ChooseCamPos(item);
end

function ITEM:SetModel(strModelName)	
	if (!IsValid(self.Entity)) then	
		self.Entity = ents.Create("prop_physics");
		self.Entity:SetModel(strModelName);
		self.Entity:Spawn();
		self.Entity:SetNoDraw(true);
	else
		self.Entity:SetModel(strModelName);
	end	
end

function ITEM:ChooseCamPos(item)		
	local size = (item.Size / 5);
	local cam = Vector((7 * size) + 2, (7 * size) + 7, (7 * size) - 5 + 7);
	
	self:SetCamPos(cam);
end

function ITEM:LayoutEntity()
end

vgui.Register('FrujuInventoryItem', ITEM, "DModelPanel")

local SELECTOR = {}

function SELECTOR:Init()
	self.Selected = 1
	self.Spacing = 5;
	
	self.Panel = vgui.Create("Panel", self);
	
	self:LoadItems();
end

function SELECTOR:LoadItems()
	self.Items = {};
	
	local ply = LocalPlayer()
	if (!ply || !ply:IsPlayer()) then return end
	
	-- Get the inventory items
	for id, item in pairs (ply:GetItems()) do
		local icon = vgui.Create("FrujuInventoryItem", self.Panel);
		icon:Setup(item);
		
		table.insert(self.Items, icon);
	end
end

function SELECTOR:PerformLayout()
	local last;
	local width = 0;
	local offset = 0;
	
	-- Layout each item
	for i, icon in pairs (self.Items) do
		-- Choose a size
		if (self.Selected == i) then
			icon:SetSize(self:GetTall(), self:GetTall());
		else
			icon:SetSize(self:GetTall() * 0.5, self:GetTall() * 0.5);
		end
		
		if (last) then
			icon:SetPos(last.x + last:GetWide() + self.Spacing, (self:GetTall() - icon:GetTall()) / 2);
		else
			icon:SetPos(0, (self:GetTall() - icon:GetTall()) / 2);
		end
		
		last = icon;
		
		width = width + icon:GetWide() + self.Spacing;
		
		if (i < self.Selected) then
			offset = offset + icon:GetWide() + self.Spacing;
		end
	end
	
	-- Layout the panel
	self.Panel:SetSize(width - self.Spacing, self:GetTall());
	self.Panel:SetPos(-offset + ((self:GetWide() - self:GetTall()) / 2), 0);
end

function SELECTOR:PaintOver()
	local s = self:GetTall();
	local x = (self:GetWide() - s) / 2;

	draw.RoundedBox(0, x, 0, s, 2, green)
	draw.RoundedBox(0, x, 0, 2, s, green)
	draw.RoundedBox(0, x, 0+s-2, s, 2, green)
	draw.RoundedBox(0, x+s-2, 0, 2, s, green)
end

function SELECTOR:ChangeItem(change)
	if (self.Selected + change != 0 && self.Selected + change != table.Count(self.Items) + 1) then
		self.Selected = self.Selected + change;
		self:InvalidateLayout();
		
		return true;
	else
		return false;
	end
end

function SELECTOR:RemoveItem(id)
	for k, icon in pairs (self.Items) do
		if (icon.Item.ID == id) then
			icon:Remove();
			table.remove(self.Items, k);
			break;
		end
	end
	
	self:InvalidateLayout();
end

function SELECTOR:AddItem(item)
	local icon = vgui.Create("FrujuInventoryItem", self.Panel);
	icon:Setup(item);
	
	table.insert(self.Items, icon);
	
	self:InvalidateLayout();
end

vgui.Register("FrujuInventorySelector", SELECTOR);

local INVENTORY = {}

function INVENTORY:Init ()
	self.Selector = vgui.Create("FrujuInventorySelector", self);
	
	self.Title = vgui.Create('Label', self)
	self.Title:SetText('Inventory')
	
	self.Quit = vgui.Create('Label', self)
	self.Quit:SetText('Q - Close')
	
	self.Pickup = vgui.Create('Label', self)
	self.Pickup:SetText('E - Drop')
	
	self.Delete = vgui.Create('Label', self)
	self.Delete:SetText('Del - Destroy')
	
	self.Name = vgui.Create('Label', self)
	self.Name:SetText('<Name>')
	
	self.Weight = vgui.Create('Label', self)
	self.Weight:SetText('Weight: 0/'..Config.InventorySize..'Kg')
	
	self.ItemWeight = vgui.Create('Label', self)
	self.ItemWeight:SetText('Item Weight; #')
	
	self.Left = vgui.Create('Label', self)
	self.Left:SetText('<-- A')
	
	self.Right = vgui.Create('Label', self)
	self.Right:SetText('D -->')
	
	self.Current = vgui.Create('Label', self)
	
	self:Update();	
	
	self:SetVisible(true);
end

function INVENTORY:PerformLayout ()
	self:SetSize(ScrW(), ScrH() / 3)
	self:SetPos(0, (ScrH() - self:GetTall()) / 2)
	
	self.Selector:SetSize(((self:GetTall() / 2) * 3)+ (self.Selector.Spacing * 4), self:GetTall() / 2);
	self.Selector:SetPos((self:GetWide() - self.Selector:GetWide()) / 2, (self:GetTall() - self.Selector:GetTall()) / 2);

	self.Title:SetPos(10, 1)
	self.Title:SizeToContents()
	
	self.Quit:SizeToContents();
	self.Quit:SetPos(self:GetWide() - self.Quit:GetWide() - 10, 0);
	
	self.Delete:SizeToContents();
	self.Delete:SetPos(10, self:GetTall() - self.Delete:GetTall() - 2);
	
	self.Pickup:SizeToContents();
	self.Pickup:SetPos(10, self.Delete.y - self.Pickup:GetTall());
	
	self.Current:SizeToContents()
	self.Current:SetPos((self:GetWide() - self.Current:GetWide()) / 2, self.Selector.y + self.Selector:GetTall() + 2)
	
	self.Name:SizeToContents()
	self.Name:SetPos((self:GetWide() - self.Name:GetWide()) / 2, self.Selector.y - self.Name:GetTall())
	
	self.Left:SizeToContents()
	self.Left:SetPos(self.Selector.x - self.Left:GetWide() - 10, (self:GetTall() - self.Left:GetTall()) / 2)
	
	self.Right:SizeToContents()
	self.Right:SetPos(self.Selector.x + self.Selector:GetWide() + 10, self.Left.y)
	
	self.Weight:SizeToContents();
	self.Weight:SetPos(self:GetWide() - self.Weight:GetWide() - 10, self:GetTall() - self.Delete:GetTall() - 2);
	
	self.ItemWeight:SizeToContents();
	self.ItemWeight:SetPos(self:GetWide() - self.ItemWeight:GetWide() - 10, self.Weight.y - self.ItemWeight:GetTall());
end

function INVENTORY:Paint ()
	draw.RoundedBox(0, 0, 0, self:GetWide(), self:GetTall(), Color(0, 0, 0, 100))
end

function INVENTORY:ApplySchemeSettings ()
	self.Title:SetFontInternal('FrujuFont')
	self.Title:SetFGColor(purple)
	
	self.Quit:SetFontInternal('FrujuFontSmall')
	self.Quit:SetFGColor(blue)
	
	self.Pickup:SetFontInternal('FrujuFontSmall')
	self.Pickup:SetFGColor(blue)
	
	self.Delete:SetFontInternal('FrujuFontSmall')
	self.Delete:SetFGColor(blue)
	
	self.Left:SetFontInternal('FrujuFontSmall')
	self.Left:SetFGColor(white)
	
	self.Right:SetFontInternal('FrujuFontSmall')
	self.Right:SetFGColor(white)
	
	self.Current:SetFontInternal('FrujuFontSmall')
	self.Current:SetFGColor(white)
	
	self.Name:SetFontInternal('FrujuFontSmall')
	self.Name:SetFGColor(white)
	
	self.Weight:SetFontInternal('FrujuFontSmall')
	self.Weight:SetFGColor(white)
	
	self.ItemWeight:SetFontInternal('FrujuFontSmall')
	self.ItemWeight:SetFGColor(white)
end

function INVENTORY:DropItem ()	
	local icon = self.Selector.Items[self.Selector.Selected];
	if (!icon || !icon:IsValid()) then return end
	
	local item = icon.Item;
	if (!item) then return end
	
	RunConsoleCommand("Inventory.DropItem", item.ID);
end

function INVENTORY:DeleteItem()
	local icon = self.Selector.Items[self.Selector.Selected];
	if (!icon || !icon:IsValid()) then return end
	
	local item = icon.Item;
	if (!item) then return end
	
	RunConsoleCommand("Inventory.DeleteItem", item.ID);
end

function INVENTORY:Update()
	-- Update Current, item weight and name
	local count = table.Count(self.Selector.Items);
	
	if (count == 0) then
		self.Current:SetText('Empty');
		self.Name:SetText("");
		self.ItemWeight:SetText("");
	else
		self.Current:SetText('Current ('..self.Selector.Selected..' / '..table.Count(self.Selector.Items)..')')
		
		local icon = self.Selector.Items[self.Selector.Selected];
		
		if (icon && icon:IsValid()) then
			local item = icon.Item;
			
			if (item) then
				self.Name:SetText(item.Name);
				self.ItemWeight:SetText("Item Weight: ".. item:GetMass().."Kg");
			end
		end
	end
	
	local ply = LocalPlayer();
	
	-- Update Weight
	if (ply && ply:IsValid()) then
		local inventory = ply:GetInventory();
		
		if (inventory) then
			self.Weight:SetText("Weight: ".. inventory.Size .."Kg/".. Config.InventorySize .."Kg"); 
		end
	end
	
	self:InvalidateLayout();
end

function INVENTORY:RemoveItem(id)
	self.Selector:RemoveItem(id);
end

function INVENTORY:Close ()
	self:Remove();
	RunConsoleCommand("Inventory.Close");
end

vgui.Register('FrujuInventory', INVENTORY)