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
		sg:Create("None", 2),
		sg:Create("Passive", 1, {
		Upgrades = {
			u:Create("LLENEMY_SUMMON_AUTOMATON", 1, 8, {Duration=24.0, FixedDuration=true}),
		}}),
		sg:Create("None", 6),
		sg:Create("Theme", 1, {
		CanApply = CanApplyUpgrade,
		Upgrades = {
			u:Create("LLENEMY_CLASS_TOTEMANCER", 1, 2),
			u:Create("LLENEMY_CLASS_INCARNATEKING", 4, 4),
		}}),
	}
})

return upgrades