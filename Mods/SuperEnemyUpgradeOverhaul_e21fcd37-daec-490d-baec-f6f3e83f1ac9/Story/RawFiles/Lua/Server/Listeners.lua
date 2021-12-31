---@param globalSettings GlobalSettings
LeaderLib.RegisterListener("ModSettingsLoaded", function(globalSettings)
	Osi.DB_LLSENEMY_LevelModifier:Delete(nil)
	Osi.DB_LLSENEMY_LevelModifier(Settings.Global:GetVariable("AutoLeveling_Modifier", 0))

	-- Migrating settings from old EUO
	if not Settings.LoadedExternally then
		local oldSettings = LeaderLib.SettingsManager.GetMod("046aafd8-ba66-4b37-adfb-519c1a5d04d7")
		if oldSettings ~= nil then
			for flagName,v in pairs(oldSettings.Global.Flags) do
				if Settings.Global.Flags[flagName] ~= nil then
					Settings.Global.Flags[flagName].Enabled = v.Enabled
				end
			end
			-- Remove old EUO settings
			if not Ext.IsModLoaded("046aafd8-ba66-4b37-adfb-519c1a5d04d7") then
				LeaderLib.SettingsManager.Remove("046aafd8-ba66-4b37-adfb-519c1a5d04d7")
			end
		end
		Settings:ApplyFlags()
		Settings:ApplyVariables()
		LeaderLib.SaveGlobalSettings()
	end
end)

-- Retroactively remove blacklisted skills if they were modified
RegisterListener("Initialized", function()
	local status,err = xpcall(function()
		if EnemySkills ~= nil and #EnemySkills > 0 then
			for _,skillgroup in pairs(EnemySkills) do
				if skillgroup.Entries ~= nil then
					for i,skill in pairs(skillgroup.Entries) do
						if IgnoreSkill(skill) then
							skillgroup.Entries[i] = nil
						end
					end
				end
			end
		end
	end, debug.traceback)
	if not status then
		Ext.PrintError("[EUO] Error adjusting EnemySkills:")
		Ext.PrintError(err)
	end

	SetHighestPartyLoremaster()

	-- local db = Osi.DB_IsPlayer:Get(nil)
	-- if db and #db > 0 then
	-- 	for i,v in pairs(db) do
	-- 		for _,slot in Data.VisibleEquipmentSlots:Get() do
	-- 			local uuid = CharacterGetEquippedItem(v[1], slot)
	-- 			if not StringHelpers.IsNullOrEmpty(uuid) then
	-- 				local item = Ext.GetItem(uuid)
	-- 				if item then
	-- 					local name = item.DisplayName
	-- 					fprint(LOGLEVEL.TRACE, "DisplayName(%s) StatsId(%s) NetID(%s)", item.DisplayName, item.StatsId, item.NetID)
	-- 					if not StringHelpers.IsNullOrEmpty(item.CustomDisplayName) then
	-- 						name = item.CustomDisplayName
	-- 					end
	-- 					Ext.BroadcastMessage("SEUO_SaveItemName", Ext.JsonStringify({NetID=item.NetID, DisplayName=name}))
	-- 				end
	-- 			end
	-- 		end
	-- 	end
	-- end

	Combat.CheckSaved()
end)

-- Ext.RegisterOsirisListener("ItemEquipped", Data.OsirisEvents.ItemEquipped, "after", function(uuid, char)
-- 	if GameHelpers.Character.IsPlayer(char) == 1 then
-- 		local item = Ext.GetItem(uuid)
-- 		if item then
-- 			local name = item.DisplayName
-- 			if not StringHelpers.IsNullOrEmpty(item.CustomDisplayName) then
-- 				name = item.CustomDisplayName
-- 			end
-- 			if not StringHelpers.IsNullOrEmpty(name) then
-- 				Ext.BroadcastMessage("SEUO_SaveItemName", Ext.JsonStringify({NetID=item.NetID, DisplayName=name}))
-- 			end
-- 		end
-- 	end
-- end)

Ext.RegisterOsirisListener("CombatEnded", Data.OsirisEvents.CombatEnded, "after", function(id)
	Combat.OnEnded(id)
end)