local g = Classes.UpgradeGroup
local sg = Classes.UpgradeSubGroup
local u = Classes.UpgradeEntry

local upgrades = g:Create("Classes", {
	DisabledFlag = "LLENEMY_ClassUpgradesUpgradesDisabled",
	SubGroups = {
		sg:Create("Default", 1, {Upgrades = {
			u:Create("LLENEMY_CLASS_GEOPYRO", 10, 4),
			u:Create("LLENEMY_CLASS_HYDROSHOCK", 1, 4),
			u:Create("LLENEMY_CLASS_CONTAMINATOR", 1, 4),
			u:Create("LLENEMY_CLASS_MEDIC", 1, 4),
		}}),
		sg:Create("Mods", 1),
	}
})

return upgrades