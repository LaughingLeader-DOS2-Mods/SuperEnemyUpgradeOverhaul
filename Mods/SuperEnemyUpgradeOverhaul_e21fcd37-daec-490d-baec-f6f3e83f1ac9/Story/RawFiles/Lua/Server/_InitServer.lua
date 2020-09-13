
Ext.Require("Server/UpgradeInfo.lua")
Ext.Require("Server/GameMechanics.lua")
Ext.Require("Server/ItemMechanics.lua")
Ext.Require("Server/HardmodeMechanics.lua")
Ext.Require("Server/Items/ItemCorruption.lua")
Ext.Require("Server/Items/ItemCorruptionStatCreator.lua")
Ext.Require("Server/Items/ItemBonuses.lua")
Ext.Require("Server/Items/SkillEnhancers.lua")
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

if Ext.IsDeveloperMode() then
	Ext.Require("Server/Debug/Init.lua")
	Ext.Require("Server/Debug/ConsoleCommands.lua")
end