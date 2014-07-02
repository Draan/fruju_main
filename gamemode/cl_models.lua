local MODEL = {}

function MODEL:Init ()
	self.Color = Color(0, 0, 0, 255)
	self.ToColor = Color(0, 0, 0, 255)
	
	self:SetCamPos( Vector( 35, 15, 70 ) )
	self:SetLookAt( Vector( 0, 0, 60 ) )
	self:SetFOV(50)

end

function MODEL:SetModel(strModelName)
	if (!ClientsideModel) then return end
	
	if (!IsValid(self.Entity)) then	
		self.Entity = ClientsideModel(strModelName, RENDER_GROUP_OPAQUE_ENTITY);
		self.Entity:SetNoDraw(true);
	else
		self.Entity:SetModel(strModelName);
	end	
end

function MODEL:LayoutEntity()
end

function MODEL:PaintOver ()
	local w = self:GetWide()
	local h= self:GetTall()

	draw.RoundedBox(0, 0, 0, w, 2, green)
	draw.RoundedBox(0, 0, 0, 2, h, green)
	draw.RoundedBox(0, 0, 0+h-2, w, 2, green)
	draw.RoundedBox(0, 0+h-2, 0, 2, h, green)
end

vgui.Register('FrujuModel', MODEL, "DModelPanel")

local SELECTOR = {}

function SELECTOR:Init ()
	self.Selected = 1

	self.Model = vgui.Create('FrujuModel', self)
	
	self.Title = vgui.Create('Label', self)
	self.Title:SetText('Select Model')
	
	self.Quit = vgui.Create('Label', self)
	self.Quit:SetText('Q - Close')
	
	self.Left = vgui.Create('Label', self)
	self.Left:SetText('<-- A')
	
	self.Right = vgui.Create('Label', self)
	self.Right:SetText('D -->')
	
	self.Select = vgui.Create('Label', self)
	self.Select:SetText('E - Select')
	
	self.Current = vgui.Create('Label', self)
	self.Current:SetText('Current (1 / 1)')
	
	local ply = LocalPlayer()
	if (!ply || !ply:IsPlayer()) then return end
	
	-- Prepare
	self.Selected = 1
	self.Cop = ply.Cop
	
	// Get the model table
	local models = {}
	if (ply.Cop) then 
		models = table.Copy(Config.PoliceModels.Male)
		table.Add(models, Config.PoliceModels.Female)
	else
		models = table.Copy(Config.PlayerModels.Male)
		table.Add(models, Config.PlayerModels.Female)
	end
	
	local mdl = string.lower(ply:GetModel())
	mdl = string.Replace(mdl, 'humans', 'player')
	
	for i, model in pairs (models) do
		if (mdl == string.lower(model)) then
			self.Selected = i
		end
		
		util.PrecacheModel(model)
	end
	
	self.Model:SetModel(models[self.Selected])
	self.Current:SetText('Current ('..self.Selected..'/'..table.Count(models)..')')
	self.Current:SizeToContents()
	
	self:SetVisible(true)
end

function SELECTOR:PerformLayout ()
	self:SetSize(ScrW(), ScrH() / 3)
	self:SetPos(0, (ScrH() - self:GetTall()) / 2)

	self.Title:SetPos(10, 1)
	self.Title:SizeToContents()
	
	self.Quit:SizeToContents()
	self.Quit:SetPos(self:GetWide() - self.Quit:GetWide() - 10, 0)
	
	self.Model:SetSize(self:GetTall() / 2, self:GetTall() / 2)
	self.Model:SetPos((self:GetWide() - self.Model:GetWide()) / 2, (self:GetTall() - self.Model:GetTall()) / 2)
	
	self.Current:SizeToContents()
	self.Current:SetPos((self:GetWide() - self.Current:GetWide()) / 2, self.Model.y + self.Model:GetTall() + 2)
	
	self.Left:SizeToContents()
	self.Left:SetPos(self.Model.x - self.Left:GetWide() - 10, (self:GetTall() - self.Left:GetTall()) / 2)
	
	self.Right:SizeToContents()
	self.Right:SetPos(self.Model.x + self.Model:GetWide() + 10, self.Left.y)
	
	self.Select:SizeToContents()
	self.Select:SetPos((self:GetWide() - self.Select:GetWide()) / 2, self.Model.y - self.Current:GetTall())
end

function SELECTOR:Paint ()
	draw.RoundedBox(0, 0, 0, self:GetWide(), self:GetTall(), Color(0, 0, 0, 100))
end

function SELECTOR:ApplySchemeSettings ()
	self.Title:SetFontInternal('FrujuFont')
	self.Title:SetFGColor(purple)
	
	self.Quit:SetFontInternal('FrujuFontSmall')
	self.Quit:SetFGColor(blue)
	
	self.Left:SetFontInternal('FrujuFontSmall')
	self.Left:SetFGColor(white)
	
	self.Right:SetFontInternal('FrujuFontSmall')
	self.Right:SetFGColor(white)
	
	self.Current:SetFontInternal('FrujuFontSmall')
	self.Current:SetFGColor(white)
	
	self.Select:SetFontInternal('FrujuFontSmall')
	self.Select:SetFGColor(white)
end

function SELECTOR:ChangeModel (add)
	local ply = LocalPlayer()
	if (!ply || !ply:IsPlayer()) then return end

	local models = {}
	if (ply.Cop) then 
		models = table.Copy(Config.PoliceModels.Male)
		table.Add(models, Config.PoliceModels.Female)
	else
		models = table.Copy(Config.PlayerModels.Male)
		table.Add(models, Config.PlayerModels.Female)
	end

	if (self.Selected + add == 0) then return end
	if (self.Selected + add == table.Count(models) + 1) then return end

	self.Selected = self.Selected + add
	self.Model:SetModel(models[self.Selected])
	
	self.Current:SetText('Current ('..self.Selected..'/'..table.Count(models)..')')
	self.Current:SizeToContents()
end

function SELECTOR:SelectModel ()
	local ply = LocalPlayer()
	if (!ply || !ply:IsPlayer()) then return end

	local models = {}
	if (ply.Cop) then 
		models = table.Copy(Config.PoliceModels.Male)
		table.Add(models, Config.PoliceModels.Female)
	else
		models = table.Copy(Config.PlayerModels.Male)
		table.Add(models, Config.PlayerModels.Female)
	end
	
	if (!models[self.Selected]) then return end
	
	self:Close(self.Selected)
end

function SELECTOR:Close (send)
	self:Remove();
	RunConsoleCommand('Fruju.Model', (send or 0))
end

vgui.Register('FrujuSelector', SELECTOR)

function Fruju.DisplayModel ()
	if (!Fruju.ModelSelector || !Fruju.ModelSelector:IsValid()) then
		Fruju.ModelSelector = vgui.Create('FrujuSelector')
	end
	
	return true
end
Network.Hook('Fruju.Model', Fruju.DisplayModel)

function Fruju.HideMenu ()
	if (!Fruju.ModelSelector || !Fruju.ModelSelector:IsValid()) then return end
	
	return false;
end
hook.Add('SpawnMenuOpen', 'Fruju.HideMenu', Fruju.HideMenu)

function Fruju.ModelsInput(key)
	if (!Fruju.ModelSelector || !Fruju.ModelSelector:IsValid()) then return end
	
	if (key == KEY_A) then
		Fruju.ModelSelector:ChangeModel(-1)
	elseif (key == KEY_D) then 
		Fruju.ModelSelector:ChangeModel(1)
	elseif (key == KEY_E) then 
		Fruju.ModelSelector:SelectModel()
	elseif (key == KEY_Q) then
		Fruju.ModelSelector:Close()
	end
end
hook.Add("KeyPressed", "Fruju.ModelsInput", Fruju.ModelsInput);