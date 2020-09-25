local function Init()

---@type ModSettings
local ModSettings = LeaderLib.Classes.ModSettingsClasses.ModSettings
local settings = ModSettings:Create("e21fcd37-daec-490d-baec-f6f3e83f1ac9")
local ts = LeaderLib.Classes.TranslatedString

settings.GetMenuOrder = function()
	return {
		Upgrades = {
			"LLENEMY_AuraUpgradesDisabled",
			"LLENEMY_BonusBuffUpgradesDisabled",
			"LLENEMY_BonusSkillsUpgradesDisabled",
			"LLENEMY_BuffUpgradesDisabled",
			"LLENEMY_ClassUpgradesUpgradesDisabled",
			"LLENEMY_DuplicationUpgradesDisabled",
			"LLENEMY_ImmunityUpgradesDisabled",
			"LLENEMY_TalentUpgradesDisabled",
			"LLENEMY_SummoningUpgradesDisabled",
			"LLENEMY_SourceBonusSkillsDisabled",
			},
		Hardmode = {		
			"LLENEMY_HardmodeEnabled",
			"LLENEMY_HardmodeRollingDisabled",
			"Hardmode_MinBonusRolls",
			"Hardmode_MaxBonusRolls",
			"Hardmode_StatusBonusTurnsMin",
			"Hardmode_StatusBonusTurnsMax",
		},
		Elites = {		
			"Hardmode_EliteMultiplier",
			"Elites_ArmorBoostPerRank",
			"Elites_MagicArmorBoostPerRank",
			"Elites_VitalityBoostPerRank",
			"Elites_DamageBoostPerRank",
		},
		["Level Scaling"] = {
			"LLENEMY_EnemyLevelingEnabled",
			"LLENEMY_Debug_LevelCapDisabled",
			"AutoLeveling_Modifier",
		},
		Duplication = {
			"Duplication_MinDupesPerEnemy",
			"Duplication_MaxDupesPerEnemy",
			"Duplication_MaxTotal",
			"Duplication_Chance",
		},
		Misc = {
			"LLENEMY_VoidwokenSourceSpawningEnabled",
			"LLENEMY_RewardsDisabled",
			"LLENEMY_PureRNGMode",
			"BonusSkills_Min",
			"BonusSkills_Max",
		},
	}
end

settings.Global:AddFlag("LLENEMY_EnemyLevelingEnabled", "Global", false, ts:Create("", "Enable Enemy Level Scaling"), ts:Create("", ""))
settings.Global:AddFlag("LLENEMY_HardmodeEnabled", "Global", false, ts:Create("", "Enable Hardmode"), ts:Create("", ""))
settings.Global:AddFlag("LLENEMY_HardmodeRollingDisabled", "Global", false, ts:Create("", "Disable Hardmode Bonus Rolls"), ts:Create("", ""))
settings.Global:AddFlag("LLENEMY_RewardsDisabled", "Global", false, ts:Create("", "Disable Rewards"), ts:Create("", ""))
settings.Global:AddFlag("LLENEMY_VoidwokenSourceSpawningEnabled", "Global", false, ts:Create("", "Spawn Voidwoken from Source Skills"), ts:Create("", ""))
settings.Global:AddFlag("LLENEMY_AuraUpgradesDisabled", "Global", false, ts:Create("", "Disable Auras"), ts:Create("", ""))
settings.Global:AddFlag("LLENEMY_BonusBuffUpgradesDisabled", "Global", false, ts:Create("", "Disable Bonus Buffs"), ts:Create("", ""))
settings.Global:AddFlag("LLENEMY_BonusSkillsUpgradesDisabled", "Global", false, ts:Create("", "Disable Bonus Skills"), ts:Create("", ""))
settings.Global:AddFlag("LLENEMY_BuffUpgradesDisabled", "Global", false, ts:Create("", "Disable Buffs"), ts:Create("", ""))
settings.Global:AddFlag("LLENEMY_ClassUpgradesUpgradesDisabled", "Global", false, ts:Create("", "Disable Classes"), ts:Create("", ""))
settings.Global:AddFlag("LLENEMY_DuplicationUpgradesDisabled", "Global", false, ts:Create("", "Disable Duplication"), ts:Create("", ""))
settings.Global:AddFlag("LLENEMY_ImmunityUpgradesDisabled", "Global", false, ts:Create("", "Disable Immunities"), ts:Create("", ""))
settings.Global:AddFlag("LLENEMY_TalentUpgradesDisabled", "Global", false, ts:Create("", "Disable Talents"), ts:Create("", ""))
settings.Global:AddFlag("LLENEMY_SummoningUpgradesDisabled", "Global", false, ts:Create("", "Disable Summoning"), ts:Create("", ""))
settings.Global:AddFlag("LLENEMY_SourceBonusSkillsDisabled", "Global", false, ts:Create("", "Disable Source Bonus Skills"), ts:Create("", ""))
settings.Global:AddFlag("LLENEMY_PureRNGMode", "Global", false, ts:Create("", "Enable Pure Randomness"), ts:Create("", ""))
settings.Global:AddFlag("LLENEMY_Debug_LevelCapDisabled", "Global", false, ts:Create("", "[Debug] Disable Level Cap"), ts:Create("", "When level scaling is enabled, this will disable the level cap. Not recommended."))
--settings.Global:AddFlag("MigrateSettings", "Global", true)
settings.Global:AddVariable("AutoLeveling_Modifier", 0)
settings.Global:AddVariable("Hardmode_MinBonusRolls", 1, ts:Create("", "Min Rolls"))
settings.Global:AddVariable("Hardmode_MaxBonusRolls", 4, ts:Create("", "Max Rolls"))
settings.Global:AddVariable("Hardmode_StatusBonusTurnsMin", 0, ts:Create("", "Max Status Turns"))
settings.Global:AddVariable("Hardmode_StatusBonusTurnsMax", 3, ts:Create("", "Min Status Turns"))
settings.Global:AddVariable("BonusSkills_Min", 0)
settings.Global:AddVariable("BonusSkills_Max", 3)
settings.Global:AddVariable("EnemySkillIgnoreList", {})
settings.Global:AddVariable("Duplication_MinDupesPerEnemy", 0)
settings.Global:AddVariable("Duplication_MaxDupesPerEnemy", 1)
settings.Global:AddVariable("Duplication_MaxTotal", -1)
settings.Global:AddVariable("Duplication_Chance", 30)
settings.Global:AddVariable("Hardmode_EliteMultiplier", 2)
settings.Global:AddVariable("Elites_ArmorBoostPerRank", 2.5)
settings.Global:AddVariable("Elites_MagicArmorBoostPerRank", 2.5)
settings.Global:AddVariable("Elites_VitalityBoostPerRank", 2.5)
settings.Global:AddVariable("Elites_DamageBoostPerRank", 1)

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