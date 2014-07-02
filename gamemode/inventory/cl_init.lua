include('shared.lua')
include('cl_gui.lua')

Inventory.GUI = nil;

function Inventory.AddItemCL(umsg)
	-- Get all the vars
	local ent = Entity(umsg:ReadShort());
	local id = umsg:ReadShort();
	local class = umsg:ReadString();
	local name = umsg:ReadString();
	local model = umsg:ReadString();
	local material = umsg:ReadString();
	local colour = Color(umsg:ReadShort(), umsg:ReadShort(), umsg:ReadShort(), umsg:ReadShort());
	local skin = umsg:ReadShort();
	local mass = umsg:ReadShort();
	local size = umsg:ReadShort();
	
	if (!ent || !ent:IsValid()) then return end
	if (!id || !class || !name || !model || !material || !colour || !skin || !mass || !size) then return end
	
	ent:AddItem(class, name, model, material, colour, skin, mass, size, id);
end
usermessage.Hook("Inventory.AddItem", Inventory.AddItemCL);

function Inventory.RemoveItemCL(umsg)
	-- Get all the vars
	local ent = Entity(umsg:ReadShort());
	local id = umsg:ReadShort();

	if (!ent || !ent:IsValid()) then return end
	if (!ent:GetItem(id)) then return end

	ent:RemoveItem(id);
	
	-- Update the menu if need be
	if (Inventory.GUI && Inventory.GUI:IsValid()) then
		-- Remove the item from the menu
		Inventory.GUI:RemoveItem(id);
		Inventory.GUI:Update();
	end
end
usermessage.Hook("Inventory.RemoveItem", Inventory.RemoveItemCL);

function Inventory.UpdateItem(umsg)
	-- Get all the vars
	local ent = Entity(umsg:ReadShort());
	local id = umsg:ReadShort();
	local class = umsg:ReadString();
	local name = umsg:ReadString();
	local model = umsg:ReadString();
	local material = umsg:ReadString();
	local colour = Color(umsg:ReadShort(), umsg:ReadShort(), umsg:ReadShort(), umsg:ReadShort());
	local skin = umsg:ReadShort();
	local mass = umsg:ReadShort();
	local size = umsg:ReadShort();
	
	if (!ent || !ent:IsValid()) then return end
	if (!id || !class || !name || !model || !material || !colour || !skin || !mass || !size) then return end
	
	-- Get the item
	local item = ent:GetItem(id);
	if (!item) then return end
	
	item:SetClass(class);
	item:SetName(name);
	item:SetModel(model);
	item:SetMaterial(material);
	item:SetColour(colour);
	item:SetSkin(skin);
	item:SetMass(mass);
	item:SetSize(size);
end
usermessage.Hook("Inventory.Update", Inventory.UpdateItem);

function Inventory.Open()
	if (!Inventory.GUI || !Inventory.GUI:IsValid()) then
		Inventory.GUI = vgui.Create('FrujuInventory');
	end
end
usermessage.Hook("Inventory.Open", Inventory.Open)

function Inventory.HideMenu ()
	if (!Inventory.GUI || !Inventory.GUI:IsValid()) then return end
	
	return false;
end
hook.Add('SpawnMenuOpen', 'Inventory.HideMenu', Inventory.HideMenu)

function Inventory.Input(key)	
	-- GUI
	if (Inventory.GUI && Inventory.GUI:IsValid()) then
		if (key == KEY_A) then
			Inventory.GUI.Selector:ChangeItem(-1);
			Inventory.GUI:Update();
		elseif (key == KEY_D) then
			Inventory.GUI.Selector:ChangeItem(1);	
			Inventory.GUI:Update();
		elseif (key == KEY_E) then
			Inventory.GUI:DropItem();
			Inventory.GUI.Selector:ChangeItem(-1);
		elseif (key == KEY_DELETE) then
			Inventory.GUI:DeleteItem();
			Inventory.GUI.Selector:ChangeItem(-1);
		elseif (key == KEY_Q) then
			Inventory.GUI:Close();	
		end
	end
end
hook.Add("KeyPressed", "Inventory.Input", Inventory.Input);

function Inventory.DetectPickup(btn)
	if (btn == MOUSE_MIDDLE) then
		RunConsoleCommand("Inventory.Pickup");
	end
end
hook.Add("MouseUp", "Inventory.DetectPickup", Inventory.DetectPickup);