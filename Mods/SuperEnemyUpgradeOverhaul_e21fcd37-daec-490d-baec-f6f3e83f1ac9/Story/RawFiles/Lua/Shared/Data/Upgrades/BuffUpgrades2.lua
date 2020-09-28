local g = Classes.UpgradeGroup
local sg = Classes.UpgradeSubGroup
local u = Classes.UpgradeEntry

---@param target EsvCharacter
local function CanApplySubgroup(target, entry)
	if entry.ID == "Polymorph" and Osi.LeaderLib_Helper_QRY_CharacterIsHumanoid(target.MyGuid) == false then
		return false
	end
	return true
end

---@param target EsvCharacter
---@param entry UpgradeEntry
local function CanApplyUpgrade(target, entry)
	if entry == "LLENEMY_GATHERING_POWER" 
	and (HasActiveStatus(target.MyGuid, "LLENEMY_GATHERING_POWER") == 1 
	or HasActiveStatus(target.MyGuid, "LLENEMY_EMPOWERED") == 1)  then
		return false
	elseif entry.StatusType == "SPARK" and (target.Stats.MainWeapon ~= nil and Game.Math.IsRangedWeapon(target.Stats.MainWeapon)) then
		return false
	end
	return true
end

local upgrades = g:Create("BonusBuffs", {
	DisabledFlag = "LLENEMY_BonusBuffUpgradesDisabled",
	CanApply = CanApplySubgroup,
	SubGroups = {
		sg:Create("None", 4),
		sg:Create("Polymorph", 2, {DisabledFlag = "LLENEMY_PolymorphSkillUpgradesDisabled",
		Upgrades = {
			u:Create("LLENEMY_SKILL_MEDUSA_HEAD", 1, 6),
			u:Create("LLENEMY_SKILL_SPIDER_LEGS", 4, 3),
			u:Create("LLENEMY_SKILL_WINGS", 8, 1),
			u:Create("LLENEMY_SKILL_HORNS", 10, 1),
		}}),
		sg:Create("None", 4),
		sg:Create("Special", 2, {
		CanApply = CanApplyUpgrade,
		Upgrades = {
			u:Create("LLENEMY_DOUBLE_DIP", 1, 6),
			u:Create("LLENEMY_PERSEVERANCE_MASTERY", 1, 8),
			u:Create("LLENEMY_SEEKER", 4, 4),
			u:Create("LLENEMY_GATHERING_POWER", 8, 2, {Duration=24.0, FixedDuration=true}),
			u:Create("LLENEMY_RAGE", 4, 6),
		}}),
		sg:Create("None", 4),
	},
	SessionLoaded = {

	}
})

return upgrades