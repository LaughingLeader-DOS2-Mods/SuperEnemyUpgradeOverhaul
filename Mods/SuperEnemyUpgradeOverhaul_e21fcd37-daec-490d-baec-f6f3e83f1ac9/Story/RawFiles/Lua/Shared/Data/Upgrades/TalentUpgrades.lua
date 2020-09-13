local g = Classes.UpgradeGroup
local sg = Classes.UpgradeSubGroup
local u = Classes.UpgradeEntry

---@param target EsvCharacter
local function HasRangedWeapon(target)
	if (target.Stats.MainWeapon ~= nil and Game.Math.IsRangedWeapon(target.Stats.MainWeapon)) then
		return true
	elseif (target.Stats.OffHandWeapon ~= nil and Game.Math.IsRangedWeapon(target.Stats.OffHandWeapon)) then
		return true
	end
	return false
end

---@param target EsvCharacter
---@param entry UpgradeEntry
local function CanApplyUpgrade(target, entry)
	if entry.ID == "LLENEMY_TALENT_MASTERTHIEF" and HasRangedWeapon(target) then
		return false
	end
	return true
end

local upgrades = g:Create("Talents", {
	DisabledFlag = "LLENEMY_TalentUpgradesDisabled",
	SubGroups = {
		sg:Create("None", 6),
		sg:Create("Normal", 10, {
		CanApply = CanApplyUpgrade,
		Upgrades = {
			u:Create("LLENEMY_TALENT_LEECH", 10, 1),
			u:Create("LLENEMY_TALENT_QUICKSTEP", 10, 1),
			u:Create("LLENEMY_TALENT_NATURALCONDUCTOR", 1, 1),
			u:Create("LLENEMY_TALENT_MASTERTHIEF", 2, 1),
			u:Create("LLENEMY_TALENT_WHATARUSH", 10, 1),
		}}),
		sg:Create("Elite", 1, {
		Upgrades = {
			u:Create("LLENEMY_TALENT_LIGHTNINGROD", 3, 2),
			u:Create("LLENEMY_TALENT_LONEWOLF", 1, 6),
			u:Create("LLENEMY_TALENT_RESISTDEAD", 3, 4),
			u:Create("LLENEMY_TALENT_RESISTDEAD2", 1, 6),
			u:Create("LLENEMY_TALENT_TORTURER", 4, 3),
			u:Create("LLENEMY_TALENT_UNSTABLE", 4, 3),
			u:Create("LLENEMY_TALENT_WHATARUSH", 4, 2),
			u:Create("LLENEMY_TALENT_BULLY", 4, 4),
			u:Create("LLENEMY_TALENT_BACKSTAB", 4, 3),
		}}),
		sg:Create("None", 6),
		sg:Create("DivineTalents", 1, {
		ModRequirement="ca32a698-d63e-4d20-92a7-dd83cba7bc56",
		Upgrades = {
			u:Create("LLENEMY_TALENT_GREEDYVESSEL", 1, 1),
			u:Create("LLENEMY_TALENT_HAYMAKER", 1, 1),
			u:Create("LLENEMY_TALENT_SOULCATCHER", 1, 1),
			u:Create("LLENEMY_TALENT_MAGICCYCLES", 1, 1),
			u:Create("LLENEMY_TALENT_INDOMITABLE", 1, 1),
			u:Create("LLENEMY_TALENT_SADIST", 1, 1),
			u:Create("LLENEMY_TALENT_GLADIATOR", 1, 1),
		}}),
	}
})

return upgrades