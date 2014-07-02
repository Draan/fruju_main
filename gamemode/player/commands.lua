// Ratings
function Chat.Rating (ply, text)
	local level = ply:GetLevel()
	if (!level) then return end

	local prefix = string.sub(text, 1, 1)
	
	if (prefix != '+' && prefix != '-') then return end
	
	if (prefix == '+' && (!level.MaxRating || !level.MaxGive)) then 
		ply:Hint('You are not allowed to grant positive ratings.')
		return false
	end
	
	if (prefix == '-' && (!level.MinRating  || !level.MaxGive)) then 
		ply:Hint('You are not allowed to grant negative ratings.')
		return false
	end
	
	local args = string.Explode(' ', text)
	
	local tgt = Fruju.FindPlayer(string.sub(args[1], 2))
	
	if (!tgt || !tgt:IsPlayer()) then
		ply:Hint('Unable to find the specified player.')
		return false
	end
	
	if (tgt == ply) then
		ply:Hint('You are not allowed to rate yourself.');
		return false;
	end
	
	if (ply.LastRating && CurTime() - ply.LastRating < (level.RatingDelay or 30)) then
		time = math.ceil((level.RatingDelay or 30) - (CurTime() - ply.LastRating))
		local second = 'seconds'
		if (time == 1) then second = 'second' end
		
		ply:Hint('Please wait '..time..' '..second..' before giving a rating.')
		return false
	end
	
	ply.LastRating = CurTime()
	
	local num = 1
	
	if (args[2] && string.len(args[2]) != 0) then
		num = tonumber(args[2]) or 1
	end
	
	if (num > level.MaxGive) then
		num = level.MaxGive
	end
	
	local tgtRating = tgt:GetRating() or 0 
	local plyRating = ply:GetRating() or 0
	
	if (tgtRating > plyRating) then
		ply:Hint(tgt:Nick()..' already has a rating higher than yours.')
		return false
	elseif (prefix == '+' && tgtRating + num > plyRating) then 
		num = plyRating - tgtRating
	elseif (prefix == '-' && tgtRating - num < Levels[1].Rating) then 
		num = tgtRating - Levels[1].Rating
	end
	
	local rating = 'positive'
	if (prefix == '-') then 
		rating = 'negative'
		num = num * -1
	end
	
	tgt:SetRating(tgt:GetRating() + num)
	
	local text = num
	if (num > 0) then
		text = prefix..num
	end
	
	ply:Hint('You have given '..tgt:Nick()..' a '..rating..' rating ('..text..').')
	tgt:Hint('You have recieved a '..rating..' rating ('..text..').')
	Log.Add(ply, 'Gave '..tgt:Nick()..' a '..rating..' rating ('..text..').')
	
	return false
end
hook.Add('InterceptChat', 'Chat.Rating', Chat.Rating)