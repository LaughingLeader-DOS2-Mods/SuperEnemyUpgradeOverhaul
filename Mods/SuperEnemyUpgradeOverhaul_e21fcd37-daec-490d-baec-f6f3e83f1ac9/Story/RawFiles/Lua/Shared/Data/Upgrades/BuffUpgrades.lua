local g = Classes.UpgradeGroup
local sg = Classes.UpgradeSubGroup
local u = Classes.UpgradeEntry

---@param target EsvCharacter
local function CanApplySubgroup(target, entry)
	return true
end

---@param target EsvCharacter
---@param entry UpgradeEntry
local function CanApplyUpgrade(target, entry)
	if entry.StatusType == "SPARK" and (target.Stats.MainWeapon ~= nil and Game.Math.IsRangedWeapon(target.Stats.MainWeapon)) then
		return false
	elseif entry.ID == "LLENEMY_GRANADA" and Osi.LeaderLib_Helper_QRY_CharacterIsHumanoid(target.MyGuid) == false then
		return false
	end
	return true
end

local MODID = {
	OdinAero = "961ae59d-2964-46dd-9762-073697915dc2",
	OdinGeo = "ffb501cc-ab6d-46de-be89-732c9e289f3e",
	OdinHydro = "02ca48b9-e4ef-a8e4-91d7-0b9df70bb595",
	OdinPyro = "aab53301-4f38-1d49-91f7-28dfa468084b",
	OdinNecro = "8700ba4e-7d4b-40ca-a23f-b43816794957",
	OdinHuntsman = "7db12ae8-0e96-4050-adb2-06c906897b70",
}

local upgrades = g:Create("Buffs", {
	DisabledFlag = "LLENEMY_BuffUpgradesDisabled",
	CanApply = CanApplySubgroup,
	SubGroups = {
		sg:Create("Weak", 10, {
		CanApply = CanApplyUpgrade,
		Upgrades = {
			u:Create("CLEAR_MINDED", 10),
			u:Create("RESTED", 10),
			u:Create("IMPROVED_INITIATIVE", 9),
			u:Create("FORTIFIED", 8, 2, {Duration = 12.0}),
			u:Create("MAGIC_SHELL", 8, 2, {Duration = 12.0}),
			u:Create("HASTED", 6, {Duration = 12.0}),
			u:Create("LLENEMY_FARSIGHT", 4),
			u:Create("DRUNK", 1, 0, {Duration = 12.0}),
			u:Create("OdinAERO_THUNDERBRAND", 1, 1, {ModRequirement=MODID.OdinAero}),
			u:Create("OdinPyro_BLAZING", 1, 1, {ModRequirement=MODID.OdinPyro}),
			u:Create("OdinPyro_FLAMEBELLY", 1, 1, {ModRequirement=MODID.OdinPyro}),
			u:Create("OdinGEO_Earthbrand", 1, 1, {ModRequirement=MODID.OdinGeo}),
			u:Create("OdinWater_FROSTBLADE", 1, 1, {ModRequirement=MODID.OdinHydro}),
			u:Create("OdinNECRO_TRANSFIXED_IMMUNITY", 1, 1, {ModRequirement=MODID.OdinNecro}),
			u:Create("OdinHUN_NIMBLE", 1, 1, {ModRequirement=MODID.OdinHuntsman}),
		}}),
		sg:Create("Normal", 6, {
		CanApply = CanApplyUpgrade,
		Upgrades = {
			u:Create("BLESSED", 1, 2, {Duration = 18.0}),
			u:Create("BREATHING_BUBBLE", 3, 3, {Duration = 18.0}),
			u:Create("ETHEREAL_SOLES", 4, 1, {Duration = 12.0}),
			u:Create("FIREBLOOD", 2, 2, {Duration = 12.0}),
			u:Create("FORTIFIED", 8, 1, {Duration = 12.0}),
			u:Create("MAGIC_SHELL", 8, 1, {Duration = 12.0}),
			u:Create("LLENEMY_DEMONIC_HASTED", 1),
			u:Create("LLENEMY_HERBMIX_COURAGE", 6),
			u:Create("LLENEMY_HERBMIX_FEROCITY", 6),
			u:Create("LLENEMY_GRANADA", 1, 4),
			u:Create("SPARKING_SWINGS", 5, 3),
			u:Create("OdinAERO_VOLTSWINGS", 2, 2, {ModRequirement=MODID.OdinAero}),
			u:Create("OdinWater_ICEARMOUR", 1, 2, {ModRequirement=MODID.OdinHydro}),
			u:Create("OdinNECRO_REANIMATOR", 1, 2, {ModRequirement=MODID.OdinNecro}),
			u:Create("OdinNECRO_OATHOFDESECRATION", 1, 3, {ModRequirement=MODID.OdinNecro}),
		}}),
		sg:Create("Elite", 1, {
		CanApply = CanApplyUpgrade,
		Upgrades = {
			u:Create("DEATH_WISH", 3, 3, {Duration = 24.0}),
			u:Create("DEATH_RESIST", 2, 4, {Duration = 6.0, FixedDuration = true}),
			u:Create("DOUBLE_DAMAGE", 1, 8, {Duration = 12.0, FixedDuration = true}),
			u:Create("FLAMING_CRESCENDO", 3, 3, {Duration = 12.0}),
			u:Create("LLENEMY_ACTIVATE_FLAMING_TONGUES", 1, 3, {Duration = 0.0, DefaultDropCount=5}),
			u:Create("LLENEMY_CHICKEN_OVERLORD", 2, 7, {Duration = 12.0}),
			u:Create("SPARK_MASTER", 3, 6),
			u:Create("OdinAERO_VOLTMASTER", 3, 6, {ModRequirement=MODID.OdinAero}),
			u:Create("OdinGEO_Ironbark", 3, 4, {ModRequirement=MODID.OdinGeo}),
			u:Create("OdinGEO_ParasiticAffliction", 1, 3, {ModRequirement=MODID.OdinGeo}),
		}})
	},
	SessionLoaded = {

	}
})

return upgrades