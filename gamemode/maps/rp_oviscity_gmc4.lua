if (SERVER) then 
	local Player = FindMetaTable('Player')

	Map.ClearByPos = {
		Vector(-2672.5000, -1057.0000, -351.5000),
		Vector(-3504.0000, -615.5000, -395.0000),
		Vector(-3504.0000, -615.5000, -401.0000),
		Vector(-2663.5000, -777.0000, -334.0000),
		Vector(1288.5000, 796.0000, -184.0000),
		Vector(-6661.0000, 189.5000, -820.0000),
		Vector(3556.0000, 788.0000, -784.0000),
		Vector(-6716.0000, 539.0000, -912.0000),
		Vector(-6661.0000, 189.5000, -820.0000)
	}

	Map.Cars = {}
	table.insert(Map.Cars, {'models/NFSMW/CTS/CTS.mdl', 'scripts/vehicles/NFSMW_CTS.txt', 0, 3})
	table.insert(Map.Cars, {'models/NFSMW/CTS/CTS.mdl', 'scripts/vehicles/NFSMW_CTS.txt', 0, 3})
	table.insert(Map.Cars, {'models/NFSMW/GTO/GTO.mdl', 'scripts/vehicles/NFSMW_GTO.txt', 0, 3})
	table.insert(Map.Cars, {'models/NFSMW/GTO/GTO.mdl', 'scripts/vehicles/NFSMW_GTO.txt', 0, 3})
	table.insert(Map.Cars, {'models/beetle.mdl', 'scripts/vehicles/beetle_test.txt', 0, 5})
	table.insert(Map.Cars, {'models/enzo.mdl', 'scripts/vehicles/enzo_test.txt', 0, 3})
	table.insert(Map.Cars, {'models/path.mdl', 'scripts/vehicles/path_test.txt', 0})
	table.insert(Map.Cars, {'models/yugo.mdl', 'scripts/vehicles/yugo.txt', 0})
	table.insert(Map.Cars, {'models/d90.mdl', 'scripts/vehicles/d90_test.txt', 0, 2})
	table.insert(Map.Cars, {'models/f100.mdl', 'scripts/vehicles/f100_test.txt', 0, 3})
	table.insert(Map.Cars, {'models/fury.mdl', 'scripts/vehicles/pfury.txt', 0, 2})
	table.insert(Map.Cars, {'models/lambo.mdl', 'scripts/vehicles/diablo.txt', 0, 16})
	table.insert(Map.Cars, {'models/corvette/corvette.mdl', 'scripts/vehicles/corvette.txt', 0, 2})
	table.insert(Map.Cars, {'models/golf/golf.mdl', 'scripts/vehicles/golf.txt', 0, 2})
	table.insert(Map.Cars, {'models/gmc-pickup.mdl', 'scripts/vehicles/gmc_pickup.txt', 0, 7})
--	table.insert(Map.Cars, {'models/sickness/murcielago.mdl', 'scripts/vehicles/murcielago.txt', 0, 6})
--	table.insert(Map.Cars, {'models/sickness/360spyder.mdl', 'scripts/vehicles/360.txt', 0, 4})
--	table.insert(Map.Cars, {'models/sickness/lotus_elise.mdl', 'scripts/vehicles/elise.txt', 0, 8})
--	table.insert(Map.Cars, {'models/sickness/bmw-m5.mdl', 'scripts/vehicles/bmwm5.txt', 0, 7})

	Map.PostBox = {
		Vector(-5254.9688, -364.2327, -465.7706),
		Vector(-2009.0313, -1988.9745, -340.5331),
		Vector(1969.8922, 1618.9688, -342.8304),
		Vector(-2881.0313, 2128.8540, -342.4932)
	}
	
	Map.TrainSeat = false
	Map.Train = false
	Map.TrainSpeed = 0

	// Clear
	function Map.Clear ()
		// Nuke
		for _, ent in pairs (ents.FindByName('fun_*')) do
			ent:Remove()
		end
		
		// RP Buttons
		for _, ent in pairs (ents.FindByName('rp_*')) do
			ent:Remove()
		end
		
		// NPCs
		for _, ent in pairs (ents.FindByClass('npc_*')) do
			ent:Remove()
		end
		
		// PD
		ents.FindByName('pd_igniter')[1]:Remove()
		ents.FindByName('pd_hurt')[1]:Remove()
		ents.FindByName('pd_red')[1]:Remove()
		
		// Clear by pos
		timer.Simple(5, Map.ClearPos)
		
		// Replace cars
		math.randomseed(os.time())
		timer.Simple(10, Map.ReplaceCars)	

		// Fix Train
		ents.FindByName('trainunlock')[1]:Remove()
		ents.FindByName('train_ui')[1]:Remove()
		ents.FindByName('train_dest')[1]:Remove()
		ents.FindByName('train_dest')[1]:Remove()
		ents.FindByName('train_tele')[1]:Remove()
		ents.FindByName('innerdor')[1]:Remove()
		ents.FindByName('trainseat')[1]:Remove()
		ents.FindByName('train_button_forward')[1]:Remove()
		
		Map.Train = ents.FindByName('intro_train_2')[1]
		if (!Map.Train || !Map.Train:IsValid()) then return end
		
		Map.TrainSeat = ents.Create('prop_vehicle_prisoner_pod')
		Map.TrainSeat:SetModel('models/nova/airboat_seat.mdl')
		Map.TrainSeat:SetPos(Map.Train:GetPos() + Vector(-349.8211, 43.0845, 78.0313))
		Map.TrainSeat:SetAngles(Map.Train:GetAngles() + Angle(0, 100, 0))
		Map.TrainSeat:Spawn()	
		Map.TrainSeat:SetParent(Map.Train)
		
		Map.Train:SetKeyValue('wheels', 1000)
	end
	hook.Add('InitPostEntity', 'Map.Clear', Map.Clear)
	
	// Clear Pos
	function Map.ClearPos ()
		for _, ent in pairs (ents.GetAll()) do
			if (ent:IsValid()) then
				local pos = ent:GetPos()
				
				for _, vec in pairs (Map.ClearByPos) do
					if (vec == pos) then
						ent:Remove()
					end
				end
			end
		end
	end
	
	// Replace cars
	function Map.ReplaceCars ()
		for _, ent in pairs (ents.FindByClass('prop_vehicle_jeep')) do
			ent:Remove()
			
			local num = math.random(1, table.Count(Map.Cars))
			local car = Map.Cars[num]
			
			local new = ents.Create('prop_vehicle_jeep')
			new:SetPos(ent:GetPos())
			new:SetAngles(ent:GetAngles())
			new:SetModel(car[1])
			new:SetKeyValue('vehiclescript', car[2])
			local colour = car[3]
			if (car[4]) then colour = math.random(car[3], car[4]) end
			new:SetSkin(colour or 0)
			new:Spawn()
			
			table.remove(Map.Cars, num)
		end
	end
	
	// PD Cell
	function Map.PDOpenCell (ply, key)
		if (key != IN_USE) then return end
		local ent = ply:Target().Entity

		if (!ent || !ent:IsValid()) then return end
		if (ent:GetPos() != Vector(-3488.0000, -615.5000, -390.0000)) then return end

		if (!ply.Cop) then return end

		local door = ents.FindByName('pd_tortureroom')[1]
		if (!door || !door:IsValid()) then return end

		door:Fire('Open', '', 0)
	end
	hook.Add('KeyPress', 'Map.PDOpenCell', Map.PDOpenCell)
	
	// Fix Apartment
	function Map.FixApartment (ply, key)
		if (key != IN_USE) then return end
		local ent = ply:Target().Entity
	
		if (!ent || !ent:IsValid() || !ent:GetName()) then return end
		if (ent:GetName() != 'apt1_door') then return end

		ent:Fire('Toggle', '', 0)
	end
	hook.Add('KeyPress', 'Map.FixApartment', Map.FixApartment)
	
	// Post boxes
	function Map.PostBoxes ()
		for _, pos in pairs (Map.PostBox) do
			for _, ent in pairs (ents.FindInSphere(pos, 4)) do
				if (ent:IsValid() && !ent:IsPlayer()) then
					ent:SetPos(Vector(-2863.5042, 2738.3252, -262.0313))
				end
			end
		end	
	end
	hook.Add('Think', 'Map.PostBoxes', Map.PostBoxes)
	
	// Exit train
	function Map.ExitTrain (ply, ent)
		if (!Map.Train || !Map.TrainSeat || !Map.Train:IsValid() || !Map.TrainSeat:IsValid()) then return end
		if (ent != Map.TrainSeat) then return end
		
		if (Map.TrainSpeed >= 200) then
			timer.Simple(0.5, Player.EnterVehicle, ply, ent)
			return
		end
		
		ply:SetPos(Map.TrainSeat:GetPos() + (Map.TrainSeat:GetAngles():Forward() * -50))
	end
	hook.Add('PlayerLeaveVehicle', 'Map.ExitTrain', Map.ExitTrain)
	
	// Try Exit train
	function Map.TryExit (ply)
		if (!Map.Train || !Map.TrainSeat || !Map.Train:IsValid() || !Map.TrainSeat:IsValid()) then return end
		if (ply:GetVehicle() != Map.TrainSeat) then return end
		if (Map.TrainSpeed >= 200) then return false end
	end
	hook.Add('CanExitVehicle', 'Map.TryExit', Map.TryExit)
	
	// Movement
	function Map.TrainMovement ()
		if (!Map.Train || !Map.Train:IsValid()) then return end
		if (!Map.TrainSeat || !Map.TrainSeat:IsValid()) then return end
		
		// Control the doors
		if (Map.TrainSpeed >= 200) then
			for _, ent in pairs (ents.FindByName('train_door_2')) do
				ent:Fire('close', '', 0)
			end
		end
		
		local ply = Map.TrainSeat:GetDriver()
		if (!ply || !ply:IsValid() || !ply:IsPlayer()) then return end
		
		if (ply:KeyDown(IN_JUMP) && Map.TrainSpeed != 0) then
			if (Map.TrainSpeed < 0) then
				if (Map.TrainSpeed + 15 > 0) then
					Map.TrainChangeSpeed(0)
				else
					Map.TrainChangeSpeed(Map.TrainSpeed + 15)
				end
			else
				if (Map.TrainSpeed - 15 < 0) then
					Map.TrainChangeSpeed(0)
				else
					Map.TrainChangeSpeed(Map.TrainSpeed - 15)
				end
			end
		elseif (ply:KeyDown(IN_FORWARD) && Map.TrainSpeed < 1000) then
			Map.TrainChangeSpeed(Map.TrainSpeed + 5)
		elseif (ply:KeyDown(IN_BACK) && Map.TrainSpeed > -200) then
			Map.TrainChangeSpeed(Map.TrainSpeed - 5)
		end
		
		if (ply:KeyDown(IN_ATTACK) && Map.TrainSpeed < 200) then
			for _, ent in pairs (ents.FindByName('train_door_2')) do
				ent:Fire('unlock', '', 0)
				ent:Fire('toggle', '', 0)
			end
		end
		
		if (ply:KeyDown(IN_ATTACK2)) then
			local horn = ents.FindByName('trainhorn')[1]
			if (!horn || !horn:IsValid()) then return end
			
			horn:Fire('PlaySound', '', 0)
		end
	end
	hook.Add('Think', 'Map.TrainMovement', Map.TrainMovement)
	
	// Change speed
	function Map.TrainChangeSpeed (speed)
		Map.TrainSpeed = speed
		Map.Train:SetKeyValue('startspeed', speed)
		
		if (speed == 0) then
			Map.Train:Fire('setspeeddir', 0, 0)
		elseif (speed < 0) then
			Map.Train:Fire('setspeeddir', 1, 0)
		else
			Map.Train:Fire('setspeeddir', -1, 0)
		end
	end
end