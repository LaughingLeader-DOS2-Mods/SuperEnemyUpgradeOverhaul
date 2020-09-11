local g = Classes.UpgradeGroup
local sg = Classes.UpgradeSubGroup
local u = Classes.UpgradeEntry

local upgrades = g:Create("Summoning", {
	DisabledFlag = "LLENEMY_SummoningUpgradesDisabled",
	SubGroups = {
		sg:Create("Passive", 1, {
		Upgrades = {
			u:Create("LLENEMY_SUMMON_AUTOMATON", 10, 1, {Duration=24.0, FixedDuration=true}),
		}}),
		sg:Create("Theme", 1, { 
		Upgrades = {
			u:Create("LLENEMY_CLASS_TOTEMANCER", 1, 2),
			u:Create("LLENEMY_CLASS_INCARNATEKING", 4, 4),
		}}),
	}
})

return upgrades