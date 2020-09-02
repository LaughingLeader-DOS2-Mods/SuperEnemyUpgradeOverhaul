local g = Classes.UpgradeGroup
local sg = Classes.UpgradeSubGroup
local u = Classes.UpgradeEntry

local upgrades = g:Create("Immunities", {
	DisabledFlag = "LLENEMY_AuraUpgradesDisabled",
	SubGroups = {
		sg:Create("Main", 10, {Upgrades = {
			u:Create("FAVOURABLE_WIND_AURA", 10, 1, {Duration = 12.0}),
			u:Create("LLENEMY_FIRE_BRAND_AURA", 8, 4),
			u:Create("FROST_AURA", 4, 2),
			u:Create("GUARDIAN_ANGEL_AURA", 1, 3),
			u:Create("VACUUM_AURA", 1, 2, 6, {Duration = 6.0}),
			u:Create("VAMPIRISM_AURA", 3, 4),
			u:Create("LLENEMY_VENOM_AURA", 4, 3),
			u:Create("LLENEMY_ACTIVATE_HEALING_TEARS", 4, 3, {Duration = 0.0}),
		}}),
		sg:Create("Immunity", 10, {DisabledFlag = "LLENEMY_ImmunityUpgradesDisabled", 
		Upgrades = {
			u:Create("AIR_IMMUNITY_AURA", 10, 4, {Duration = 6.0}),
			u:Create("EARTH_IMMUNITY_AURA", 10, 4, {Duration = 6.0}),
			u:Create("WATER_IMMUNITY_AURA", 10, 4, {Duration = 12.0}),
			u:Create("FIRE_IMMUNITY_AURA", 10, 4, {Duration = 12.0}),
			u:Create("EVASION_AURA", 1, 4, {Duration = 6.0}),
			u:Create("ELEMENTAL_IMMUNITY_AURA", 1, 6, {Duration = 6.0, FixedDuration = true}),
			u:Create("PHYSICAL_IMMUNITY_AURA", 1, 4, {Duration = 6.0, FixedDuration = true}),
		}}),
	}
})

return upgrades