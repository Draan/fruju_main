Chat = {}

// Recieve chat
function Chat.Recieve (umsg)
	local type = umsg:ReadChar()
	local prefix = umsg:ReadString()
	local text = umsg:ReadString()
	
	// Get the color
	local color = Config.ChatColor[type]
	if (!color) then return end
	
	chat.AddText(color, prefix..' ', Color(255, 255, 255, 255), text)
end
usermessage.Hook('Chat', Chat.Recieve)