local extensions = {};
extensions["mdl"] = true;
extensions["ttf"] = true;
extensions["vtf"] = true;
extensions["vmt"] = true;
extensions["wav"] = true;
extensions["mp3"] = true;

function Fruju.AddResources(search, real)	
	local files, dirs = file.Find(search.."/*", "GAME");

	table.Add(files, dirs)
	if (!files) then return end
	
	for _, fResource in pairs (files) do
		local extension = string.GetExtensionFromFilename(fResource);
		
		if (extension == nil) then
			if (!real) then
				Fruju.AddResources(search..'/'..fResource, fResource);
			else
				Fruju.AddResources(search..'/'..fResource, real..'/'..fResource);
			end
		elseif (extensions[extension]) then
			print(real..'/'..fResource)
			resource.AddFile(real..'/'..fResource);
		end
	end
end

Fruju.AddResources(Fruju.BaseDir.."/content");