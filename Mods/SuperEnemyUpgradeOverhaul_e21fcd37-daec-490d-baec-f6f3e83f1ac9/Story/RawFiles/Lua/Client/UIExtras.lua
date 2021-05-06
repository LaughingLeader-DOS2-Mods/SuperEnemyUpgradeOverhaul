local ts = Classes.TranslatedString
local eliteName = ts:Create("h6e63c146gcc1fg43f0g8b98gcf89cb4c1fc2", "<font color='#FFDE36'>[1] (ELITE)</font>")
local sourceSpawnedWrapper = ts:Create("h873b94aeg56aeg47c5gbf72g08bd3a09af51", "<font color='#00FFAA'>[1] (SOURCE-SPAWNED)</font>")

local function addHealthBarNameExtras(ui, method, name, level, isItem)
	if not Ext.GetPickingState then
		return
	end
	UIExtensions.StartTimer("SEUO_AddExtraNameStuff", 10, function()
		local state = Ext.GetPickingState()
		local characterHandle = state.HoverCharacter or state.HoverCharacter2
		if characterHandle then
			local main = ui:GetRoot()
			--local label = main.hp_mc.textHolder_mc.label_txt
			local label = main.hp_mc.nameHolder_mc.text_txt
			local character = Ext.GetCharacter(characterHandle)
			if character then 
				if character:HasTag("LLENEMY_Elite") then
					--label.htmlText = string.format("%s %s", level_label_txt.htmlText, "<font color='#CCFF00'>(Elite)</font>")
					label.htmlText = eliteName:ReplacePlaceholders(label.htmlText)
					main.hp_mc.frame_mc.gotoAndStop(2) -- Boss frame
				end
				if character:HasTag("LLENEMY_SourceVoidwoken") then
					local levelText = main.hp_mc.textHolder_mc.label_txt.htmlText
					main.hp_mc.textHolder_mc.label_txt.htmlText = sourceSpawnedWrapper:ReplacePlaceholders(levelText)
				end
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
				if character then 
					if character:HasTag("LLENEMY_Elite") then
						main.examine_mc.setName(eliteName:ReplacePlaceholders(name))
					end
					if character:HasTag("LLENEMY_SourceVoidwoken") then
						--main.examine_mc.addTitle(sourceSpawnedWrapper:ReplacePlaceholders(""))
					end
				end
			end
		end)
	end

end
Ext.RegisterUITypeInvokeListener(LeaderLib.Data.UIType.examine, "setText", addNameExtras)