Events.ModSettingsLoaded:Subscribe(function(e)
	if Ext.Osiris.IsCallable() then
		Osi.DB_LLSENEMY_LevelModifier:Delete(nil)
		Osi.DB_LLSENEMY_LevelModifier(Settings.Global:GetVariable("AutoLeveling_Modifier", 0))
	end

	-- Migrating settings from old EUO
	if not Settings.LoadedExternally then
		local oldSettings = SettingsManager.GetMod("046aafd8-ba66-4b37-adfb-519c1a5d04d7")
		if oldSettings ~= nil then
			for flagName,v in pairs(oldSettings.Global.Flags) do
				if Settings.Global.Flags[flagName] ~= nil then
					Settings.Global.Flags[flagName].Enabled = v.Enabled
				end
			end
			-- Remove old EUO settings
			if not Ext.Mod.IsModLoaded("046aafd8-ba66-4b37-adfb-519c1a5d04d7") then
				SettingsManager.Remove("046aafd8-ba66-4b37-adfb-519c1a5d04d7")
			end
		end
		Settings:ApplyFlags()
		Settings:ApplyVariables()
		SaveGlobalSettings()
	end
end, {MatchArgs={UUID=ModuleUUID}})

-- Retroactively remove blacklisted skills if they were modified
Events.Initialized:Subscribe(function(e)
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
		Ext.Utils.PrintError("[EUO] Error adjusting EnemySkills:")
		Ext.Utils.PrintError(err)
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

Ext.Osiris.RegisterListener("CombatEnded", Data.OsirisEvents.CombatEnded, "after", function(id)
	Combat.OnEnded(id)
end)