local g = Classes.UpgradeGroup
local sg = Classes.UpgradeSubGroup
local u = Classes.UpgradeEntry

local upgrades = g:Create("BonusSkills", {
	DisabledFlag = "LLENEMY_BonusSkillsUpgradesDisabled",
	SubGroups = {
		sg:Create("Normal", 10, {Upgrades = {
			u:Create("LLENEMY_BONUSSKILLS_SINGLE", 10, 1),
			u:Create("LLENEMY_BONUSSKILLS_SET_NORMAL", 1, 3),
		}}),
		sg:Create("Elite", 1, { 
		Upgrades = {
			u:Create("LLENEMY_SKILL_MASS_SHACKLES", 1, 6),
			u:Create("LLENEMY_BONUSSKILLS_SET_ELITE", 4, 6),
			u:Create("LLENEMY_BONUSSKILLS_SET_SOURCE_ELITE", 2, 6),
		}}),
		sg:Create("Source", 1, { 
		Upgrades = {
			u:Create("LLENEMY_BONUSSKILLS_SOURCE", 1, 2),
		}}),
	}
})

return upgrades