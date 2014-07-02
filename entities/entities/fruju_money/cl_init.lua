include('shared.lua')

function Fruju.MoneyHud ()
	local ply = LocalPlayer()
	if (!ply || !ply:IsPlayer()) then return end
	
	local ent = ply:Target(150).Entity 
	if (!ent || !ent:IsValid() || ent:GetClass() != 'fruju_money') then return end
	
	local money = Fruju.FormatMoney(ent.Money)
	if (!money) then return end
	
	surface.SetFont('FrujuFontSmall')
	local w, h = surface.GetTextSize(money)
	
	draw.SimpleText(money, 'FrujuFontSmall', (ScrW() - w) / 2, (ScrH() / 2) - h - 5, white, 0, 3)
end
hook.Add('HUDPaint', 'Fruju.MoneyHud', Fruju.MoneyHud)

function Fruju.RecieveMoney (umsg)	
	local ent = Entity(umsg:ReadLong());
	local money = umsg:ReadFloat();
	
	if (!ent || !ent:IsValid() || ent:GetClass() != 'fruju_money') then return end
	if (!money) then return end
	
	ent.Money = money;
	
	return true
end
Network.Hook('Money.Send', Fruju.RecieveMoney)

function Fruju.RequestMoney (ent)
	if (ent:IsValid() && ent:GetClass() == 'fruju_money') then
		RunConsoleCommand('Money.Request', ent:EntIndex())
	end
end
hook.Add('OnEntityCreated', 'Fruju.RequestMoney', Fruju.RequestMoney)