
print(Classes.UpgradeGroup, Classes.UpgradeSubGroup, Classes.UpgradeEntry)

---@type table<string, UpgradeGroup>
local Data = {
	Auras = Ext.Require("Shared/Data/Upgrades/AuraUpgrades.lua"),
	--BonusSkills = Ext.Require("Shared/Data/Upgrades/BonusSkillUpgrades.lua"),
	Buffs = Ext.Require("Shared/Data/Upgrades/BuffUpgrades.lua"),
	Classes = Ext.Require("Shared/Data/Upgrades/ClassUpgrades.lua"),
	Immunities = Ext.Require("Shared/Data/Upgrades/ImmunityUpgrades.lua"),
	Infusions = Ext.Require("Shared/Data/Upgrades/InfusionUpgrades.lua"),
	Summoning = Ext.Require("Shared/Data/Upgrades/SummoningUpgrades.lua"),
	Talents = Ext.Require("Shared/Data/Upgrades/TalentUpgrades.lua"),
}

return Data