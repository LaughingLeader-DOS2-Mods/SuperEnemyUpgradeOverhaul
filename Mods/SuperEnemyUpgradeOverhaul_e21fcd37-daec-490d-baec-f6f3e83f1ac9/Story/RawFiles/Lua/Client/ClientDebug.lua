local function LLENEMY_Debug_PrintTags(call, datastr)
	Ext.Utils.Print("[LLENEMY_ClientDebug.lua:PrintTags] Received data:\n"..tostring(datastr))
	local data = Ext.JsonParse(datastr)
	for i,entry in pairs(data) do
		local netid = entry[1]
		local character = Ext.GetCharacter(netid)
		if character ~= nil then
			Ext.Utils.Print("[LLENEMY_ClientDebug.lua:PrintTags] Tags for NetID("..tostring(netid)..") character.Stats.NetID("..tostring(character.Stats.NetID)..")")
			Ext.Utils.Print("==========================")
			Ext.Utils.Print(Common.Dump(character:GetTags()))
			Ext.Utils.Print("==========================")
		else
			error("[LLENEMY_ClientDebug.lua:PrintTags] No character found for NetID ("..tostring(netid)..")!")
		end
	end
end

Ext.RegisterNetListener("LLENEMY_Debug_PrintTags", LLENEMY_Debug_PrintTags)

Ext.Require("Client/GameTooltipDebug.lua")