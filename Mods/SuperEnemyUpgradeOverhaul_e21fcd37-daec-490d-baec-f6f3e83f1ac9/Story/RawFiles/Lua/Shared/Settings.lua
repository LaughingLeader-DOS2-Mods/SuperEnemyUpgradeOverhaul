local function Init()

---@type ModSettings
local settings = CreateModSettings("e21fcd37-daec-490d-baec-f6f3e83f1ac9")
---@type TranslatedString
local ts = LeaderLib.Classes.TranslatedString

if Ext.Version() > 55 then

local MenuSectionUpgrades = ts:Create("hd77b5837g7edag4a4cgbf65g812d6dab70b7", "Upgrades")
local MenuSectionHardmode = ts:Create("ha17708c3g1ac2g4036g9a44gd94ccc794825", "Hardmode")
local MenuSectionElites = ts:Create("h38919f09ga85eg44f8gb1e1g025663ee336b", "Elites")
local MenuSectionLevelScaling = ts:Create("h9915de70gf6d4g44a3g8d65ge4b44ea17266", "Level Scaling")
local MenuSectionDuplication = ts:Create("h49ff6a24gb788g48f0g871cg98390ff6dcb5", "Duplication")
local MenuSectionMisc = ts:Create("h256c71a6ge40dg4ed5gbaffgd20cf19ccab3", "Misc")

settings.GetMenuOrder = function()
	return {{
		DisplayName = MenuSectionUpgrades.Value,
		Entries = {
			"LLENEMY_AuraUpgradesDisabled",
			"LLENEMY_BonusBuffUpgradesDisabled",
			"LLENEMY_BonusSkillsUpgradesDisabled",
			"LLENEMY_BuffUpgradesDisabled",
			"LLENEMY_ClassUpgradesUpgradesDisabled",
			"LLENEMY_ImmunityUpgradesDisabled",
			"LLENEMY_TalentUpgradesDisabled",
			"LLENEMY_SummoningUpgradesDisabled",
			"LLENEMY_SourceBonusSkillsDisabled",
			"LLENEMY_PolymorphSkillUpgradesDisabled",
		}},
		{DisplayName = MenuSectionHardmode.Value, 
		Entries = {		
			"LLENEMY_HardmodeEnabled",
			"LLENEMY_HardmodeRollingDisabled",
			"Hardmode_MinBonusRolls",
			"Hardmode_MaxBonusRolls",
			"Hardmode_StatusBonusTurnsMin",
			"Hardmode_StatusBonusTurnsMax",
		}},
		{DisplayName = MenuSectionElites.Value,
		Entries = {		
			"Hardmode_EliteMultiplier",
			"Elites_ArmorBoostPerRank",
			"Elites_MagicArmorBoostPerRank",
			"Elites_VitalityBoostPerRank",
			"Elites_DamageBoostPerRank",
		}},
		{DisplayName = MenuSectionDuplication.Value, 
		Entries = {
			"LLENEMY_DuplicationEnabled",
			"Duplication_MinDupesPerEnemy",
			"Duplication_MaxDupesPerEnemy",
			"Duplication_MaxTotal",
			"Duplication_Chance",
		}},
		{DisplayName = MenuSectionLevelScaling.Value, 
		Entries = {
			"LLENEMY_EnemyLevelingEnabled",
			"LLENEMY_Debug_LevelCapDisabled",
			"AutoLeveling_Modifier",
			"LLENEMY_LevelEnemiesToPartyLevelDisabled",
		}},
		{DisplayName = MenuSectionMisc.Value, 
		Entries = {
			"LLENEMY_VoidwokenSourceSpawningEnabled",
			"LLENEMY_RewardsDisabled",
			"LLENEMY_PureRNGMode",
			"BonusSkills_Min",
			"BonusSkills_Max",
		}},
	}
end

settings.Global:AddLocalizedFlags({
	"LLENEMY_EnemyLevelingEnabled",
	"LLENEMY_LevelEnemiesToPartyLevelDisabled",
	"LLENEMY_HardmodeEnabled",
	"LLENEMY_HardmodeRollingDisabled",
	"LLENEMY_RewardsDisabled",
	"LLENEMY_VoidwokenSourceSpawningEnabled",
	"LLENEMY_AuraUpgradesDisabled",
	"LLENEMY_BonusBuffUpgradesDisabled",
	"LLENEMY_PolymorphSkillUpgradesDisabled",
	"LLENEMY_BonusSkillsUpgradesDisabled",
	"LLENEMY_BuffUpgradesDisabled",
	"LLENEMY_ClassUpgradesUpgradesDisabled",
	"LLENEMY_ImmunityUpgradesDisabled",
	"LLENEMY_TalentUpgradesDisabled",
	"LLENEMY_SummoningUpgradesDisabled",
	"LLENEMY_SourceBonusSkillsDisabled",
	"LLENEMY_PureRNGMode",
	"LLENEMY_Debug_LevelCapDisabled",
	"LLENEMY_DuplicationEnabled",
})

settings.Global.Flags.LLENEMY_PureRNGMode.DebugOnly = true
settings.Global.Flags.LLENEMY_Debug_LevelCapDisabled.DebugOnly = true

--settings.Global:AddFlag("MigrateSettings", "Global", true)
settings.Global:AddLocalizedVariable("AutoLeveling_Modifier", "LLENEMY_Variable_AutoLeveling_Modifier", 0, 1, Ext.ExtraData.SoftLevelCap)
settings.Global:AddLocalizedVariable("Hardmode_MinBonusRolls", "LLENEMY_Variable_Hardmode_MinBonusRolls", 1, 0, 99)
settings.Global:AddLocalizedVariable("Hardmode_MaxBonusRolls", "LLENEMY_Variable_Hardmode_MaxBonusRolls", 4, 0, 99)
settings.Global:AddLocalizedVariable("Hardmode_StatusBonusTurnsMin", "LLENEMY_Variable_Hardmode_StatusBonusTurnsMin", 0, 0, 99)
settings.Global:AddLocalizedVariable("Hardmode_StatusBonusTurnsMax", "LLENEMY_Variable_Hardmode_StatusBonusTurnsMax", 3, 0, 99)
settings.Global:AddLocalizedVariable("BonusSkills_Min", "LLENEMY_Variable_BonusSkills_Min", 0, 0, 16)
settings.Global:AddLocalizedVariable("BonusSkills_Max", "LLENEMY_Variable_BonusSkills_Max", 3, 0, 16)
settings.Global:AddLocalizedVariable("Duplication_MinDupesPerEnemy", "LLENEMY_Variable_Duplication_MinDupesPerEnemy", 0, 0, 10)
settings.Global:AddLocalizedVariable("Duplication_MaxDupesPerEnemy", "LLENEMY_Variable_Duplication_MaxDupesPerEnemy", 1, 0, 10)
settings.Global:AddLocalizedVariable("Duplication_MaxTotal", "LLENEMY_Variable_Duplication_MaxTotal", -1, -1, 99)
settings.Global:AddLocalizedVariable("Duplication_Chance", "LLENEMY_Variable_Duplication_Chance", 30, 0, 100)
settings.Global:AddLocalizedVariable("Hardmode_EliteMultiplier", "LLENEMY_Variable_Hardmode_EliteMultiplier", 2, 0, 10, 0.1)
settings.Global:AddLocalizedVariable("Elites_ArmorBoostPerRank", "LLENEMY_Variable_Elites_ArmorBoostPerRank", 2.5, 0, 10, 0.1)
settings.Global:AddLocalizedVariable("Elites_MagicArmorBoostPerRank", "LLENEMY_Variable_Elites_MagicArmorBoostPerRank", 2.5, 0, 10, 0.1)
settings.Global:AddLocalizedVariable("Elites_VitalityBoostPerRank", "LLENEMY_Variable_Elites_VitalityBoostPerRank", 2.5, 0, 10, 0.1)
settings.Global:AddLocalizedVariable("Elites_DamageBoostPerRank", "LLENEMY_Variable_Elites_DamageBoostPerRank", 1, 0, 10, 0.1)
settings.Global:AddVariable("EnemySkillIgnoreList", {})
end

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

settings.OnVariableSet = function(uuid, name, data)
	if name == "AutoLeveling_Modifier" then
		Osi.DB_LLSENEMY_LevelModifier:Delete(nil)
		Osi.DB_LLSENEMY_LevelModifier(data.Value)
	end
end

return settings
end

return Init