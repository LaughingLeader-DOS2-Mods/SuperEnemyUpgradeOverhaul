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
LeaderLib.RegisterListener("Initialized", function()
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
end)