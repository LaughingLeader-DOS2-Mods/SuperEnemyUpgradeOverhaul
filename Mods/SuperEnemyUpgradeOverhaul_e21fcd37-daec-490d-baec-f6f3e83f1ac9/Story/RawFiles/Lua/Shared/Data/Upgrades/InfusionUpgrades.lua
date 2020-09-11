local g = Classes.UpgradeGroup
local sg = Classes.UpgradeSubGroup
local u = Classes.UpgradeEntry

local upgrades = g:Create("Infusion", {
	DisabledFlag = "LLENEMY_InfusionUpgradesDisabled",
	SubGroups = {
		sg:Create("Normal", 3, {DisabledFlag = "LLENEMY_ImmunityUpgradesDisabled", 
		Upgrades = {
			u:Create("LLENEMY_INF_ACID", 1, 3, {Duration = 24.0}),
			u:Create("LLENEMY_INF_BLESSED_ICE", 1, 3, {Duration = 24.0}),
			u:Create("LLENEMY_INF_CURSED_ELECTRIC", 1, 3, {Duration = 24.0}),
			u:Create("LLENEMY_INF_NECROFIRE", 1, 3, {Duration = 24.0}),
			u:Create("LLENEMY_INF_BLOOD", 4, 2, {Duration = 24.0}),
			u:Create("LLENEMY_INF_ELECTRIC", 4, 2, {Duration = 24.0}),
			u:Create("LLENEMY_INF_FIRE", 4, 2, {Duration = 24.0}),
			u:Create("LLENEMY_INF_OIL", 4, 2, {Duration = 24.0}),
			u:Create("LLENEMY_INF_POISON", 4, 2, {Duration = 24.0}),
			u:Create("LLENEMY_INF_WATER", 4, 2, {Duration = 24.0}),
		}}),
		sg:Create("Elite", 1, {DisabledFlag = "LLENEMY_ImmunityUpgradesDisabled", 
		Upgrades = {
			u:Create("LLENEMY_INF_ACID_G", 1, 4, {Duration = 36.0}),
			u:Create("LLENEMY_INF_BLESSED_ICE_G", 1, 4, {Duration = 36.0}),
			u:Create("LLENEMY_INF_CURSED_ELECTRIC_G", 1, 4, {Duration = 36.0}),
			u:Create("LLENEMY_INF_NECROFIRE_G", 1, 4, {Duration = 36.0}),
			u:Create("LLENEMY_INF_BLOOD_G", 4, 3, {Duration = 36.0}),
			u:Create("LLENEMY_INF_ELECTRIC_G", 4, 3, {Duration = 36.0}),
			u:Create("LLENEMY_INF_FIRE_G", 4, 3, {Duration = 36.0}),
			u:Create("LLENEMY_INF_OIL_G", 4, 3, {Duration = 36.0}),
			u:Create("LLENEMY_INF_POISON_G", 4, 3, {Duration = 36.0}),
			u:Create("LLENEMY_INF_WATER_G", 4, 3, {Duration = 36.0}),
		}}),
		sg:Create("Bonus", 2, { 
		Upgrades = {
			u:Create("LLENEMY_INF_RANGED", 10, 1, {Duration = -1.0}),
			u:Create("LLENEMY_INF_POWER", 10, 1, {Duration = -1.0}),
			u:Create("LLENEMY_INF_SHADOW", 1, 3, {Duration = -1.0}),
			u:Create("LLENEMY_INF_WARP", 1, 3, {Duration = -1.0}),
		}}),
	}
})

return upgrades