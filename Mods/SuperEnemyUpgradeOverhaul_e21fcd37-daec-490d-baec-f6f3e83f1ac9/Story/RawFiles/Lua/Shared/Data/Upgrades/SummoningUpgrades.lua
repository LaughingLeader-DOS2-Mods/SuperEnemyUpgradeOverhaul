local g = Classes.UpgradeGroup
local sg = Classes.UpgradeSubGroup
local u = Classes.UpgradeEntry

---@param target EsvCharacter
---@param entry UpgradeSubGroup
---@return boolean
local function CanApplyUpgrade(target, entry)
	if target:HasTag("LLENEMY_Duplicant") then
		return false
	end
	return true
end

local upgrades = g:Create("Summoning", {
	DisabledFlag = "LLENEMY_SummoningUpgradesDisabled",
	SubGroups = {
		sg:Create("Passive", 1, {
		Upgrades = {
			u:Create("LLENEMY_SUMMON_AUTOMATON", 1, 8, {Duration=18.0, FixedDuration=true, DefaultDropCount=4}),
		}}),
		sg:Create("None", 10),
		sg:Create("Theme", 1, {
		CanApply = CanApplyUpgrade,
		Upgrades = {
			u:Create("LLENEMY_CLASS_TOTEMANCER", 3, 2),
			u:Create("LLENEMY_CLASS_INCARNATEKING", 1, 6),
		}}),
		sg:Create("None", 10),
	}
})

return upgrades