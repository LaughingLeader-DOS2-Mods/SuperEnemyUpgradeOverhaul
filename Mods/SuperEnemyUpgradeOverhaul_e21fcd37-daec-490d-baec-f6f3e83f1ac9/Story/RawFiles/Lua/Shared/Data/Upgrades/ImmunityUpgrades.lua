local g = Classes.UpgradeGroup
local sg = Classes.UpgradeSubGroup
local u = Classes.UpgradeEntry

local upgrades = g:Create("Immunities", {
	DisabledFlag = "LLENEMY_ImmunityUpgradesDisabled",
	SubGroups = {
		sg:Create("None", 10),
		sg:Create("Main", 1, {Upgrades = {
			u:Create("INVULNERABLE", 1, 4, {Duration = 6.0, FixedDuration = true}),
			u:Create("EVADING", 8, 2, {Duration = 6.0}),
			u:Create("ELECTRIC_SKIN", 4, 4, {Duration = 12.0}),
			u:Create("FIRE_SKIN", 4, 4, {Duration = 12.0}),
			u:Create("ICE_SKIN", 4, 4, {Duration = 12.0}),
			u:Create("POISON_SKIN", 4, 4, {Duration = 12.0}),
			u:Create("LLENEMY_IMMUNITY_PIERCING", 1, 5, {Duration = 36.0}),
		}}),
		sg:Create("None", 10),
		sg:Create("StatusImmunity", 4, {
		Upgrades = {
			u:Create("IMMUNE_TO_BURNING", 8, 2, {Duration = 18.0}),
			u:Create("IMMUNE_TO_ELECTRIFYING", 8, 2, {Duration = 18.0}),
			u:Create("IMMUNE_TO_POISONING", 8, 2, {Duration = 18.0}),
			u:Create("LLENEMY_IMMUNITY_LOSECONTROL", 1, 8),
		}}),
		sg:Create("None", 10),
	}
})

return upgrades