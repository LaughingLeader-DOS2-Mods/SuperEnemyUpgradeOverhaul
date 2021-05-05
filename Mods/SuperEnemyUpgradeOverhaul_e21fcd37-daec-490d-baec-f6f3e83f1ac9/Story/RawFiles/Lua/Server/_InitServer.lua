
---@type CharacterData
CharacterData = LeaderLib.Classes.CharacterData

PersistentVars = {}
if PersistentVars.Upgrades == nil then
	PersistentVars.Upgrades = {}
end
if PersistentVars.Upgrades.DropCounts == nil then
	PersistentVars.Upgrades.DropCounts = {}
end
if PersistentVars.Upgrades.Results == nil then
	---@type table<string, table<string, SavedUpgradeData[]>>
	PersistentVars.Upgrades.Results = {}
end
if PersistentVars.ActiveDuplicants == nil then
	PersistentVars.ActiveDuplicants = 0
end
if PersistentVars.LeveledRegions == nil then
	PersistentVars.LeveledRegions = {}
end

Ext.Require("Server/Listeners.lua")
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
Ext.Require("Server/UpgradeSystem/UpgradesController.lua")
Ext.Require("Server/UpgradeSystem/Duplicants.lua")
Ext.Require("Server/UpgradeSystem/BonusSkills.lua")
Ext.Require("Server/UpgradeSystem/MiscUpgradeMechanics.lua")
Ext.Require("Server/Hardmode/_Init.lua")

Ext.Require("Server/Debug/ConsoleCommands.lua")
if Ext.IsDeveloperMode() then
	Ext.Require("Server/Debug/Init.lua")
	Ext.Require("Server/Debug/DeveloperCommands.lua")
end

local function LLENEMY_Server_ModuleLoading()
	LLENEMY_Shared_InitModuleLoading()
end
Ext.RegisterListener("ModuleLoading", LLENEMY_Server_ModuleLoading)

local function LLENEMY_Server_SessionLoaded()
	-- Odinblade's Necromancy Overhaul
	if Ext.IsModLoaded("8700ba4e-7d4b-40ca-a23f-b43816794957") then
		-- This is a skill that applies DOS1's Oath of Desecration potion for +40% damage
		IgnoredSkills["Target_EnemyTargetedDamageBoost"] = true
	end
	-- Odinblade's Aerotheurge Class Overhaul
	if Ext.IsModLoaded("961ae59d-2964-46dd-9762-073697915dc2") then
		-- Pretty brutal apparently
		IgnoredSkills["Target_OdinAERO_Enemy_InsulationShield"] = true
	end
	-- Divinity Conflux by Xorn
	if Ext.IsModLoaded("723ad06b-0241-4a2e-a9f3-4d2b419e0fe3") then
		-- Super damage
		IgnoredSkills["ProjectileStrike_Enemy_Xorn_Comdor_Smash"] = true
	end
	BuildEnemySkills()

	-- Defaults
	Settings.Global:SetVariable("Hardmode_MinBonusRolls", math.tointeger(Ext.ExtraData.LLENEMY_Hardmode_DefaultBonusRolls_Min or 1))
	Settings.Global:SetVariable("Hardmode_MaxBonusRolls", math.tointeger(Ext.ExtraData.LLENEMY_Hardmode_DefaultBonusRolls_Max or 4))
end
Ext.RegisterListener("SessionLoaded", LLENEMY_Server_SessionLoaded)