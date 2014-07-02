local Player = FindMetaTable('Player')

// Shared
function Player:Target (distanceOverride)
	// Get the player config
	local distance = 80
	if (distanceOverride) then distance = distanceOverride end

	// Get the target entity
	local vStart = self:GetShootPos() 
 	local vForward = self:GetAimVector() 
   
 	local trace = {} 
 	trace.start = vStart 
 	trace.endpos = vStart + (vForward * distance)
	trace.filter = self
 	 
 	local tr = util.TraceLine(trace)
	
	// Return the entity
	return tr
end

function Player:SetCop (cop, blockUpdate)
	self.Cop = cop
	
	if (SERVER) then 	
		local gender = 'Male'
		if (string.find(string.lower(self:GetModel()), '/female')) then gender = 'Female' end
	
		self:StripWeapons()
		self:UpdateModel(gender)
		self:UpdateLoadout()
		if (!blockUpdate) then self:UpdateCop() end
	end
end

function Player:SetCriminal (criminal)
	self.Criminal = criminal
	
	if (SERVER) then 
		self:StripWeapons()
		self:UpdateLoadout()
		self:UpdateSpeed()
		self:UpdateCriminal()
	end
end

function Player:SetJob (job, blockUpdate)
	if (type(job) != 'string') then return end
	
	self.Job = job
	
	if (SERVER && !blockUpdate) then self:UpdateJob() end
end

function Player:GetJob ()
	return self.Job or Config.DefaultJob
end

function Player:SetMoney (money, blockUpdate)
	if (type(money) != 'number') then return end
	
	self.Money = money
	
	if (SERVER && !blockUpdate) then self:UpdateMoney() end
end

function Player:GetMoney ()
	return self.Money or 0
end

function Player:SetRating (rating)
	self.Rating = rating;
	
	if (SERVER) then
		self:UpdateRating();
		self:StoreStats();
	end
	
	self:UpdateLevel();
end

function Player:GetRating ()
	if (self:IsAdmin()) then
		return 100;
	end

	if (!self.Rating && SERVER) then
		self:GetStats();
	end
	
	return self.Rating or 0;
end

function Player:UpdateLevel ()
	if (!Levels) then return end
	
	local last = self.Level;
	self.Level = nil;
	local rating = self:GetRating();
	
	for i, level in pairs (Levels) do
		if (self.Level) then
			if (level.Rating <= (rating or 0)) then
				self.Level = i;
			end
		else
			self.Level = i;
		end
	end
	
	if (SERVER) then
		if (last && last != self.Level) then
			local current = Levels[self.Level];
			last = Levels[last];
			
			if (!current || !last) then return end
			
			for _, wep in pairs (last.Loadout) do
				if (self:HasWeapon(wep) && !table.HasValue(current.Loadout, wep)) then
					self:StripWeapon(wep);
				end
			end
			
			if (self.Cop) then
				for _, wep in pairs (last.PoliceLoadout) do
					if (self:HasWeapon(wep) && !table.HasValue(current.PoliceLoadout, wep)) then
						self:StripWeapon(wep);
					end
				end
			end
			
			self:UpdateLoadout();
			
			if (self:GetMoveType() == MOVETYPE_NOCLIP && !current.Noclip) then
				self:SetMoveType(MOVETYPE_WALK);
			end
		end
	end
end

function Player:GetLevel ()
	if (!self.Level) then
		self:UpdateLevel();
	end
	
	return Levels[self.Level];
end