local g = Classes.UpgradeGroup
local sg = Classes.UpgradeSubGroup
local u = Classes.UpgradeEntry

local upgrades = g:Create("Classes", {
	DisabledFlag = "LLENEMY_ClassUpgradesUpgradesDisabled",
	SubGroups = {
		sg:Create("None", 10),
		sg:Create("Default", 1, {Upgrades = {
			u:Create("LLENEMY_CLASS_GEOPYRO", 1, 4),
			u:Create("LLENEMY_CLASS_HYDROSHOCK", 1, 4),
			u:Create("LLENEMY_CLASS_CONTAMINATOR", 1, 4),
			u:Create("LLENEMY_CLASS_MEDIC", 1, 4),
		}}),
		sg:Create("None", 10),
	}
})

return upgrades