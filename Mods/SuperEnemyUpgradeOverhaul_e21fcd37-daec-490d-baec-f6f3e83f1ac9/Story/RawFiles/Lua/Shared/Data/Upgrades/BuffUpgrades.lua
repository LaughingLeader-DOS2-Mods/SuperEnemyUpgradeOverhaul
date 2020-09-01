
local g = Classes.UpgradeGroup
local sg = Classes.UpgradeSubGroup
local u = Classes.UpgradeEntry

local upgrades = g:Create("GeneralBuff", {
	DisabledFlag = "LLENEMY_BuffUpgradesDisabled",
	SubGroups = {
		sg:Create("Weak", 10, {
		Upgrades = {
			u:Create("CLEAR_MINDED", 10),
			u:Create("RESTED", 10),
			u:Create("IMPROVED_INITIATIVE", 9),
			u:Create("FORTIFIED", 8, 2, {Duration = 12.0}),
			u:Create("MAGIC_SHELL", 8, 2, {Duration = 12.0}),
			u:Create("HASTED", 6, {Duration = 12.0}),
			u:Create("LLENEMY_FARSIGHT", 4),
			u:Create("DRUNK", 1, 0, {Duration = 12.0}),
		}}),
		sg:Create("Normal", 6, {
		Upgrades = {
			u:Create("BLESSED", 1, 2, {Duration = 18.0}),
			u:Create("BREATHING_BUBBLE", 3, 3, {Duration = 18.0}),
			u:Create("ETHEREAL_SOLES", 4, 1, {Duration = 12.0}),
			u:Create("FIREBLOOD", 2, 2, {Duration = 12.0}),
			u:Create("FORTIFIED", 8, 2, {Duration = 12.0}),
			u:Create("MAGIC_SHELL", 8, 2, {Duration = 12.0}),
			u:Create("LLENEMY_DEMONIC_HASTED", 1),
			u:Create("LLENEMY_HERBMIX_COURAGE", 6),
			u:Create("LLENEMY_HERBMIX_FEROCITY", 6),
			u:Create("LLENEMY_GRANADA", 1, 4),
			u:Create("SPARKING_SWINGS", 5, 3),
		}}),
		sg:Create("Elite", 1, {
		Upgrades = {
			u:Create("DEATH_WISH", 6, 3, {Duration = 24.0}),
			u:Create("DEATH_RESIST", 2, 2, {Duration = 6.0, FixedDuration = true}),
			u:Create("DOUBLE_DAMAGE", 1, 1, {Duration = 12.0, FixedDuration = true}),
			u:Create("FLAMING_CRESCENDO", 3, 2, {Duration = 12.0}),
			u:Create("LLENEMY_ACTIVATE_FLAMING_TONGUES", 8, 3, {Duration = 0.0}),
			u:Create("LLENEMY_CHICKEN_OVERLORD", 2, 7, {Duration = 12.0}),
			u:Create("SPARK_MASTER", 10, 6),
		}}),
		sg:Create("Polymorph", 2, {DisabledFlag = "LLENEMY_PolymorphSkillUpgradesDisabled", 
		Upgrades = {
			u:Create("LLENEMY_SKILL_MEDUSA_HEAD", 1, 6),
			u:Create("LLENEMY_SKILL_SPIDER_LEGS", 4, 3),
			u:Create("LLENEMY_SKILL_WINGS", 8, 1),
			u:Create("LLENEMY_SKILL_HORNS", 10, 1),
		}}),
	}
})

return upgrades