-- Hands hooks
-- Author: Rory Douglas

hands = {};

hands.ignoreClasses = {};
hands.ignoreClasses['func_tracktrain'] = true
hands.ignoreClasses['prop_dynamic'] = true
hands.ignoreClasses['func_wall_toggle'] = true
hands.ignoreClasses['item_healthcharger'] = true
hands.ignoreClasses['func_brush'] = true
hands.ignoreClasses['item_ammo_crate'] = true
hands.ignoreClasses['item_suitcharger'] = true
hands.ignoreClasses['func_breakable_surf'] = true
hands.ignoreClasses['func_monitor'] = true
hands.ignoreClasses['func_breakable'] = true
hands.ignoreClasses['func_breakable'] = true

if (SERVER) then
	hands.ignoreClasses['func_button'] = true

	function GM:HandsTryThrow()
		return true;
	end

	function GM:HandsTryPickup()
		return true;
	end

	function GM:HandsTryDrop()
		return true;
	end

	function GM:HandsTryFreeze()
		return true;
	end

	function GM:HandsSecondaryAttack()
		return true;
	end

	function GM:HandsReload()
		return true;
	end

	function GM:PlayerShouldHaveHands()
		return true;
	end
	
	function GM:HandsCanPickup(ply, ent)
		if (hands.ignoreClasses[ent:GetClass()] || ent:IsPlayer() || ent:IsNPC()) then
			return false;
		else
			return true;
		end
	end
else
	function GM:HandsDrawHud(ply, wep)
		local held = wep:GetHeld();
		
		if (held && held:IsValid()) then
			return true;
		end
	
		local tr = ply:Target(80);
		
		local ent = tr.Entity;
		if (!ent || !ent:IsValid() || ent:IsPlayer()) then return end
		
		if (hands.ignoreClasses[ent:GetClass()]) then
			return false;
		else
			return true;
		end
	end
	
	function GM:HandsHudTexture()
		return "default";
	end
	
	function GM:HandsDrawText()
	end
end