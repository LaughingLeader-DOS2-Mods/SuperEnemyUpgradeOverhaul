---@type ModSettings
local ModSettings = LeaderLib.Classes.ModSettingsClasses.ModSettings
local settings = ModSettings:Create("e21fcd37-daec-490d-baec-f6f3e83f1ac9")
settings.Global:AddFlags({
	"LLENEMY_Debug_LevelCapDisabled",
	"LLENEMY_EnemyLevelingEnabled",
	"LLENEMY_HardModeEnabled",
	"LLENEMY_HardModeRollingDisabled",
	"LLENEMY_RewardsDisabled",
	"LLENEMY_VoidwokenSourceSpawningEnabled",
	--"LLENEMY_WorldUpgradesEnabled",
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
})
settings.Global:AddVariable("LLENEMY_Scaling_LevelModifier", 0)
settings.Global:AddVariable("Hardmode_MinBonusRolls", 1)
settings.Global:AddVariable("Hardmode_MaxBonusRolls", 4)
settings.Global:AddVariable("Hardmode_StatusBonusTurnsMin", 0)
settings.Global:AddVariable("BonusSkills_Min", 0)
settings.Global:AddVariable("BonusSkills_Max", 3)
settings.Global:AddVariable("EnemySkillIgnoreList", {})
settings.Global:AddVariable("Hardmode_StatusBonusTurnsMax", 3)
settings.Global:AddVariable("Duplication_MinDupesPerEnemy", 0)
settings.Global:AddVariable("Duplication_MaxDupesPerEnemy", 1)
settings.Global:AddVariable("Duplication_MaxTotal", -1)
settings.Global:AddVariable("Duplication_Chance", 30)

---@param self SettingsData
---@param name string
---@param data VariableData
settings.UpdateVariable = function(self, name, data)
	if name == "LLENEMY_Scaling_LevelModifier" then
		local entry = Osi.DB_LLENEMY_LevelModifier:Get(nil)
		if entry ~= nil then
			data.Value = entry[1][1]
		end
	end
end
return settings