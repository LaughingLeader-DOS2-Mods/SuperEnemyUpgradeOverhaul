local function Init()

---@type ModSettings
local ModSettings = LeaderLib.Classes.ModSettingsClasses.ModSettings
local settings = ModSettings:Create("e21fcd37-daec-490d-baec-f6f3e83f1ac9")
---@type TranslatedString
local ts = LeaderLib.Classes.TranslatedString

local MenuSectionUpgrades = ts:Create("hd77b5837g7edag4a4cgbf65g812d6dab70b7", "Upgrades")
local MenuSectionHardmode = ts:Create("ha17708c3g1ac2g4036g9a44gd94ccc794825", "Hardmode")
local MenuSectionElites = ts:Create("h38919f09ga85eg44f8gb1e1g025663ee336b", "Elites")
local MenuSectionLevelScaling = ts:Create("h9915de70gf6d4g44a3g8d65ge4b44ea17266", "Level Scaling")
local MenuSectionDuplication = ts:Create("h49ff6a24gb788g48f0g871cg98390ff6dcb5", "Duplication")
local MenuSectionMisc = ts:Create("h256c71a6ge40dg4ed5gbaffgd20cf19ccab3", "Misc")

settings.GetMenuOrder = function()
	return {
		[MenuSectionUpgrades.Value] = {
			"LLENEMY_AuraUpgradesDisabled",
			"LLENEMY_BonusBuffUpgradesDisabled",
			"LLENEMY_BonusSkillsUpgradesDisabled",
			"LLENEMY_BuffUpgradesDisabled",
			"LLENEMY_ClassUpgradesUpgradesDisabled",
			"LLENEMY_ImmunityUpgradesDisabled",
			"LLENEMY_TalentUpgradesDisabled",
			"LLENEMY_SummoningUpgradesDisabled",
			"LLENEMY_SourceBonusSkillsDisabled",
		},
		[MenuSectionHardmode.Value] = {		
			"LLENEMY_HardmodeEnabled",
			"LLENEMY_HardmodeRollingDisabled",
			"Hardmode_MinBonusRolls",
			"Hardmode_MaxBonusRolls",
			"Hardmode_StatusBonusTurnsMin",
			"Hardmode_StatusBonusTurnsMax",
		},
		[MenuSectionElites.Value] = {		
			"Hardmode_EliteMultiplier",
			"Elites_ArmorBoostPerRank",
			"Elites_MagicArmorBoostPerRank",
			"Elites_VitalityBoostPerRank",
			"Elites_DamageBoostPerRank",
		},
		[MenuSectionLevelScaling.Value] = {
			"LLENEMY_EnemyLevelingEnabled",
			"LLENEMY_Debug_LevelCapDisabled",
			"AutoLeveling_Modifier",
		},
		[MenuSectionDuplication.Value] = {
			"LLENEMY_DuplicationUpgradesDisabled",
			"Duplication_MinDupesPerEnemy",
			"Duplication_MaxDupesPerEnemy",
			"Duplication_MaxTotal",
			"Duplication_Chance",
		},
		[MenuSectionMisc.Value] = {
			"LLENEMY_VoidwokenSourceSpawningEnabled",
			"LLENEMY_RewardsDisabled",
			"LLENEMY_PureRNGMode",
			"BonusSkills_Min",
			"BonusSkills_Max",
		},
	}
end

settings.Global:AddFlag("LLENEMY_EnemyLevelingEnabled")
settings.Global:AddFlag("LLENEMY_HardmodeEnabled")
settings.Global:AddFlag("LLENEMY_HardmodeRollingDisabled")
settings.Global:AddFlag("LLENEMY_RewardsDisabled")
settings.Global:AddFlag("LLENEMY_VoidwokenSourceSpawningEnabled")
settings.Global:AddFlag("LLENEMY_AuraUpgradesDisabled")
settings.Global:AddFlag("LLENEMY_BonusBuffUpgradesDisabled")
settings.Global:AddFlag("LLENEMY_BonusSkillsUpgradesDisabled")
settings.Global:AddFlag("LLENEMY_BuffUpgradesDisabled")
settings.Global:AddFlag("LLENEMY_ClassUpgradesUpgradesDisabled")
settings.Global:AddFlag("LLENEMY_DuplicationUpgradesDisabled", "Global", true)
settings.Global:AddFlag("LLENEMY_ImmunityUpgradesDisabled")
settings.Global:AddFlag("LLENEMY_TalentUpgradesDisabled")
settings.Global:AddFlag("LLENEMY_SummoningUpgradesDisabled")
settings.Global:AddFlag("LLENEMY_SourceBonusSkillsDisabled")
settings.Global:AddFlag("LLENEMY_PureRNGMode")
settings.Global:AddFlag("LLENEMY_Debug_LevelCapDisabled")
--settings.Global:AddFlag("MigrateSettings", "Global", true)
settings.Global:AddLocalizedVariable("AutoLeveling_Modifier", "LLENEMY_Variable_AutoLeveling_Modifier", 0, Ext.ExtraData.SoftLevelCap, 1)
settings.Global:AddLocalizedVariable("Hardmode_MinBonusRolls", "LLENEMY_Variable_Hardmode_MinBonusRolls", 1, 0, 99)
settings.Global:AddLocalizedVariable("Hardmode_MaxBonusRolls", "LLENEMY_Variable_Hardmode_MaxBonusRolls", 4, 0, 99)
settings.Global:AddLocalizedVariable("Hardmode_StatusBonusTurnsMin", "LLENEMY_Variable_Hardmode_StatusBonusTurnsMin", 0, 0, 99)
settings.Global:AddLocalizedVariable("Hardmode_StatusBonusTurnsMax", "LLENEMY_Variable_Hardmode_StatusBonusTurnsMax", 3, 0, 99)
settings.Global:AddLocalizedVariable("BonusSkills_Min", "LLENEMY_Variable_BonusSkills_Min", 0, 0, 99)
settings.Global:AddLocalizedVariable("BonusSkills_Max", "LLENEMY_Variable_BonusSkills_Max", 3, 0, 99)
settings.Global:AddVariable("EnemySkillIgnoreList", {})
settings.Global:AddLocalizedVariable("Duplication_MinDupesPerEnemy", "LLENEMY_Variable_Duplication_MinDupesPerEnemy", 0, 0, 10)
settings.Global:AddLocalizedVariable("Duplication_MaxDupesPerEnemy", "LLENEMY_Variable_Duplication_MaxDupesPerEnemy", 1, 0, 10)
settings.Global:AddLocalizedVariable("Duplication_MaxTotal", "LLENEMY_Variable_Duplication_MaxTotal", -1, -1, 99)
settings.Global:AddLocalizedVariable("Duplication_Chance", "LLENEMY_Variable_Duplication_Chance", 30, 0, 100)
settings.Global:AddLocalizedVariable("Hardmode_EliteMultiplier", "LLENEMY_Variable_Hardmode_EliteMultiplier", 2, 0, 10, 0.1)
settings.Global:AddLocalizedVariable("Elites_ArmorBoostPerRank", "LLENEMY_Variable_Elites_ArmorBoostPerRank", 2.5, 0, 10, 0.1)
settings.Global:AddLocalizedVariable("Elites_MagicArmorBoostPerRank", "LLENEMY_Variable_Elites_MagicArmorBoostPerRank", 2.5, 0, 10, 0.1)
settings.Global:AddLocalizedVariable("Elites_VitalityBoostPerRank", "LLENEMY_Variable_Elites_VitalityBoostPerRank", 2.5, 0, 10, 0.1)
settings.Global:AddLocalizedVariable("Elites_DamageBoostPerRank", "LLENEMY_Variable_Elites_DamageBoostPerRank", 1, 0, 10, 0.1)

---@param self SettingsData
---@param name string
---@param data VariableData
settings.UpdateVariable = function(self, name, data)
	if name == "AutoLeveling_Modifier" then
		local entry = Osi.DB_LLSENEMY_LevelModifier:Get(nil)
		if entry ~= nil then
			data.Value = entry[1][1]
		end
	end
end
return settings
end

return Init