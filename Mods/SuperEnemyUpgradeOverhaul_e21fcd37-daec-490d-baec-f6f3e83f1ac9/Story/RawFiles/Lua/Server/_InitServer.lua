---@class SuperEnemyUpgradeOverhaulPersistentVars
local defaultPersistentVars = {
	Upgrades = {
		DropCounts = {},
		---@type table<string, table<string, SavedUpgradeData[]>>
		Results = {}
	},
	LeveledRegions = {},
	---@type table<integer,table<string,boolean>>
	WaitForCombatEnd = {},
	---@type table<UUID, string>
	WaitForStatusRemoval = {},
	---@type table<string, table>
	BloodyWinterTargets = {},
	ActiveDuplicants = {},
	Rage = {},
	Seekers = {},
}

---@type SuperEnemyUpgradeOverhaulPersistentVars
PersistentVars = GameHelpers.PersistentVars.Initialize(Mods.SuperEnemyUpgradeOverhaul, defaultPersistentVars, nil, true)

Ext.Require("Server/Listeners.lua")
Ext.Require("Server/CombatHelpers.lua")
Ext.Require("Server/UpgradeInfo.lua")
Ext.Require("Server/GameMechanics.lua")
Ext.Require("Server/ItemMechanics.lua")
Ext.Require("Server/Items/ItemCorruption.lua")
Ext.Require("Server/Items/ItemCorruptionStatCreator.lua")
Ext.Require("Server/Items/Bonuses/ItemBonusManager.lua")
Ext.Require("Server/Items/Bonuses/MiscItemBonuses.lua")
Ext.Require("Server/Items/Bonuses/SkillEnhancers.lua")
Ext.Require("Server/TreasureGoblins.lua")
Ext.Require("Server/VoidwokenSpawning.lua")
Ext.Require("Server/ServerMessages.lua")
Ext.Require("Server/Recruiter.lua")
Ext.Require("Server/SummoningMechanics.lua")
Ext.Require("Server/LevelScaling.lua")
Ext.Require("Server/Upgrades/UpgradesController.lua")
Ext.Require("Server/Upgrades/Duplicants.lua")
Ext.Require("Server/Upgrades/BonusSkills.lua")
Ext.Require("Server/Hardmode/_Init.lua")

Ext.Require("Server/Debug/ConsoleCommands.lua")
if Ext.Debug.IsDeveloperMode() then
	Ext.Require("Server/Debug/Init.lua")
	Ext.Require("Server/Debug/DeveloperCommands.lua")
end

local function LLENEMY_Server_SessionLoaded()
	-- Odinblade's Necromancy Overhaul
	if Ext.Mod.IsModLoaded("8700ba4e-7d4b-40ca-a23f-b43816794957") then
		-- This is a skill that applies DOS1's Oath of Desecration potion for +40% damage
		IgnoredSkills["Target_EnemyTargetedDamageBoost"] = true
	end
	-- Odinblade's Aerotheurge Class Overhaul
	if Ext.Mod.IsModLoaded("961ae59d-2964-46dd-9762-073697915dc2") then
		-- Pretty brutal apparently
		IgnoredSkills["Target_OdinAERO_Enemy_InsulationShield"] = true
	end
	-- Divinity Conflux by Xorn
	if Ext.Mod.IsModLoaded("723ad06b-0241-4a2e-a9f3-4d2b419e0fe3") then
		-- Super damage
		IgnoredSkills["ProjectileStrike_Enemy_Xorn_Comdor_Smash"] = true
	end
	BuildEnemySkills()

	-- Defaults
	Settings.Global:SetVariable("Hardmode_MinBonusRolls", math.tointeger(Ext.ExtraData.LLENEMY_Hardmode_DefaultBonusRolls_Min or 1))
	Settings.Global:SetVariable("Hardmode_MaxBonusRolls", math.tointeger(Ext.ExtraData.LLENEMY_Hardmode_DefaultBonusRolls_Max or 4))
end
Ext.Events.SessionLoaded:Subscribe(LLENEMY_Server_SessionLoaded)