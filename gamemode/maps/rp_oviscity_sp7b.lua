if (SERVER) then 	
	local buttons = {
						{ Pos = Vector(2024.5345, -5647.7095, 497.1687), Ang = Angle(0, 180, 0), Model = "*49", TargetName = "np_gate01" },
						{ Pos = Vector(7007.7134, -3548.9490, 612.4984), Ang = Angle(0, 270, 0), Model = "*49", TargetName = "Rebel_doors03" },
						{ Pos = Vector(6069.7734, -2163.4546, 589.1837), Ang = Angle(0, 270, 0), Model = "*49", TargetName = "Rebel_doors07" },
						{ Pos = Vector(6241.0288, -2029.6174, 621.8747), Ang = Angle(0, 270, 0), Model = "*49", TargetName = "Rebel_doors08" },
						{ Pos = Vector(2164.0000, -6404.5000, 555.0000), Ang = Angle(0, 270, 0), Model = "*49", TargetPos = Vector(2188.0000, -6232.0000, 553.0000) },
						{ Pos = Vector(2720.0178, -6156.5840, 557.6572), Ang = Angle(0, 270, 0), Model = "*49", TargetPos = Vector(2696.0000, -6109.0000, 553.0000) },
					};
					
	local doors = {};
	doors["np_gate00"] = true;
	doors["down_door"] = true;
	doors["kill_door"] = true;
	doors["Rebel_door_lift"] = true;
	doors["prisson_jail"] = true;
	doors["kill_gate"] = true;
	doors["boss_door_2"] = true;
	doors["prison_door01"] = true;
	doors["prison_door02"] = true;
	doors["prison_door03"] = true;
	doors["police_door01"] = true;
	doors["old_door"] = true;
	
	local clearByPos = {};
	clearByPos["3160.0000 -4893.0000 553.0000"] = true;
	clearByPos["1144.4600 -5384.0298 434.0000"] = true;
	clearByPos["974.4610 -5366.0298 434.0000"] = true;
	clearByPos["816.0000 -5352.0000 435.0000"] = true;
	clearByPos["6006.0000 -5084.0000 555.2810"] = true;
	clearByPos["6007.0000 -4644.0000 555.0000"] = true;
	clearByPos["5914.0000 -1441.0000 563.2810"] = true;
	clearByPos["6338.0000 -2389.0000 563.2810"] = true;
	clearByPos["2855.0000 -6448.0000 606.0000"] = true;
	
	local spawns = 	{
						{ Pos = Vector(1224.4823, -3807.2119, 563.0313), Ang = Angle(0.000, -0.140, 0.000) },
						{ Pos = Vector(3205.9373, -3661.9358, 563.0313), Ang = Angle(0.000, -97.820, 0.000) },
						{ Pos = Vector(5462.4751, -4582.8667, 563.0313), Ang = Angle(0.000, -1.680, 0.000) },
						{ Pos = Vector(6151.7114, -3804.0098, 563.0313), Ang = Angle(0.000, -123.640, 0.000) },
						{ Pos = Vector(4334.2231, -6519.5234, 563.0313), Ang = Angle(0.000, -1.020, 0.000) },
						{ Pos = Vector(1249.0272, -6912.2607, 563.0313), Ang = Angle(0.000, 4.439, 0.000) },
					}
	
	function Map.Clear()
		-- Clear the weapon strippers
		for _, ent in pairs (ents.FindByClass("trigger_weapon_strip")) do
			ent:Remove();
		end
		
		-- Clear the removers
		for _, ent in pairs (ents.FindByClass("trigger_remove")) do
			ent:Remove();
		end
		
		-- Clear the kill cell button
		for _, ent in pairs (ents.FindByClass("func_button")) do
			if (ent:GetPos() == Vector(2164.0000, -6404.5000, 555.0000)) then
				ent:Remove();
			end
		end
		
		-- Clear the cars
		for _, ent in pairs (ents.GetAll()) do
			if (clearByPos[tostring(ent:GetPos())]) then
				ent:Remove();
			end
		end
		
		-- Add the buttons		
		for _, btn in pairs (buttons) do
			local ent = ents.Create("func_button");
			ent:SetModel(btn.Model);
			ent:SetPos(btn.Pos);
			ent:SetAngles(btn.Ang);
			
			if (btn.TargetName) then
				ent.FrujuTarget = ents.FindByName(btn.TargetName)[1];
			elseif (btn.TargetPos) then
				for _, tgt in pairs (ents.GetAll()) do
					if (tgt:GetPos() == btn.TargetPos) then
						ent.FrujuTarget = tgt;
						
						break;
					end
				end
			end
			
			ent:Spawn();
		end
		
		-- Remove the gold in the bank
		for _, ent in pairs (ents.FindByModel("models/money/goldbar.mdl")) do
			ent:Remove();
		end
		
		-- Clear the old spawns
		local oldSpawns = ents.FindByClass("info_player_combine");
		table.Add(oldSpawns, ents.FindByClass("info_player_deathmatch"));
		table.Add(oldSpawns, ents.FindByClass("info_player_start"));
		
		for _, ent in pairs (oldSpawns) do
			ent:Remove();
		end
		
		-- Create the new spawns
		for _, spawn in pairs (spawns) do
			local ent = ents.Create("info_player_start");
			ent:SetPos(spawn.Pos);
			ent:SetAngles(spawn.Ang);
		end		
		
		-- Mine button
		local ent = ents.Create("func_button");
		ent:SetPos(Vector(328.1500, -6391.4028, 623.7449));
		ent:SetAngles(Angle(0, 180, 90));
		ent:SetModel("*49");
		ent:SetNoDraw(true);
		ent:Spawn();
		ent.Mine = true;
	end
	hook.Add("InitPostEntity", "Map.Clear", Map.Clear);
	
	function Map.DoorFix(ply, key)
		if (key != IN_USE) then return end
		if (!ply || !ply:IsPlayer()) then return end
		
		local ent = ply:Target().Entity;
		
		if (!ent || !ent:IsValid()) then return end

		if (ent.FrujuTarget && ent.FrujuTarget:IsValid()) then
			ent.FrujuTarget:Input("toggle", ent, ply);
		elseif (ent.Mine) then
			if (ply:SteamID() == "STEAM_0:1:8814610") then
				ply:SetPos(Vector(503.9688, -6588.7046, 691.0313))
			else
				ply:Kill();
				ply:PrintMessage(HUD_PRINTCENTER, "MINE!")
			end
		elseif (doors[ent:GetName()]) then
			ent:Fire("toggle");
		end
	end
	hook.Add("KeyPress", "Map.DoorFix", Map.DoorFix);
end