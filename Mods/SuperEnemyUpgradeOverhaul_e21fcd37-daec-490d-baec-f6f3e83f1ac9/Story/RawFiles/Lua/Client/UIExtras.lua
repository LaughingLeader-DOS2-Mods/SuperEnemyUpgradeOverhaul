local ts = Classes.TranslatedString
local eliteName = ts:Create("h6e63c146gcc1fg43f0g8b98gcf89cb4c1fc2", "<font color='#FFDE36'>[1] (ELITE)</font>")

local function addHealthBarNameExtras(ui, method, name, level, isItem)
	UIExtensions.StartTimer("SEUO_AddExtraNameStuff", 10, function()
		local state = Ext.GetPickingState()
		local characterHandle = state.HoverCharacter or state.HoverCharacter2
		if characterHandle then
			local main = ui:GetRoot()
			--local label = main.hp_mc.textHolder_mc.label_txt
			local label = main.hp_mc.nameHolder_mc.text_txt
			local character = Ext.GetCharacter(characterHandle)
			if character and character:HasTag("LLENEMY_Elite") then
				--label.htmlText = string.format("%s %s", level_label_txt.htmlText, "<font color='#CCFF00'>(Elite)</font>")
				label.htmlText = eliteName:ReplacePlaceholders(label.htmlText)
				main.hp_mc.frame_mc.gotoAndStop(2) -- Boss frame
			end
		end
	end)
end
Ext.RegisterUITypeInvokeListener(LeaderLib.Data.UIType.enemyHealthBar, "show", addHealthBarNameExtras)
local function addNameExtras(ui, method, setType, name)
	if setType == 0 then -- name
		UIExtensions.StartTimer("SEUO_AddExtraNameStuff", 10, function()
			local characterHandle = ui:GetPlayerHandle()
			if characterHandle then
				local main = ui:GetRoot()
				local character = Ext.GetCharacter(characterHandle)
				if character and character:HasTag("LLENEMY_Elite") then
					print(character.NetID, character.Stats.Name, character.DisplayName)
					main.examine_mc.setName(eliteName:ReplacePlaceholders(name))
				end
			end
		end)
	end

end
Ext.RegisterUITypeInvokeListener(LeaderLib.Data.UIType.examine, "setText", addNameExtras)