local ts = Classes.TranslatedString

local ArmorBoostText = {Name = ts:Create("h05040c61g84bfg4989ga083g48f7642fbeb5","Armor Boost"), Color = "#CCCCCC"}
local MagicArmorBoostText = {Name = ts:Create("h8fecc0a7g0c7eg4a22g8528g1a6ac5bf5f30","Magic Armor Boost"), Color = "#4499FF"}
local VitalityBoostText = {Name = ts:Create("h0982817bgf111g4dc3g811bga9fbd51ab0ca","Vitality Boost"), Color = "#CC0000"}
local DamageBoostText = {Name = ts:Create("h6f6ccb6ag9cc6g4122g9040g432f4e787491","Damage Boost"), Color = "#FF0033"}

---@class UpgradeInfoData
local UpgradeInfoData = {
	---@type TranslatedString
	Name = {},
	Color = "#FFFFFF",
	Lore = 1
}
UpgradeInfoData.__index = UpgradeInfoData

---@param name TranslatedString
---@return UpgradeInfoData
function UpgradeInfoData:Create(name, ...)
    local this =
    {
		Name = name,
	}
	local params = {...}
	if params[1] ~= nil then
		this.Color = params[1]
	end
	if params[2] ~= nil then
		this.Lore = params[2]
	end
	setmetatable(this, self)
    return this
end

UpgradeData = {
	Statuses = {
		LLENEMY_TALENT_BACKSTAB = 1,
		LLENEMY_TALENT_GLADIATOR = 1,
		LLENEMY_TALENT_GREEDYVESSEL = 1,
		LLENEMY_TALENT_HAYMAKER = 1,
		LLENEMY_TALENT_INDOMITABLE = 1,
		LLENEMY_TALENT_LEECH = 1,
		LLENEMY_TALENT_LONEWOLF = 1,
		LLENEMY_TALENT_MAGICCYCLES = 1,
		LLENEMY_TALENT_MASTERTHIEF = 1,
		LLENEMY_TALENT_QUICKSTEP = 1,
		LLENEMY_TALENT_RANGERRANGE = 1,
		LLENEMY_TALENT_SADIST = 1,
		LLENEMY_TALENT_SOULCATCHER = 1,
		LLENEMY_TALENT_TORTURER = 1,
		LLENEMY_TALENT_WHATARUSH = 1,
		LLENEMY_TALENT_UNSTABLE = 1,
		LLENEMY_INF_ACID = 1,
		LLENEMY_INF_ACID_G = 1,
		LLENEMY_INF_BLESSED_ICE = 1,
		LLENEMY_INF_BLESSED_ICE_G = 1,
		LLENEMY_INF_BLOOD = 1,
		LLENEMY_INF_BLOOD_G = 1,
		LLENEMY_INF_CURSED_ELECTRIC = 1,
		LLENEMY_INF_CURSED_ELECTRIC_G = 1,
		LLENEMY_INF_ELECTRIC = 1,
		LLENEMY_INF_ELECTRIC_G = 1,
		LLENEMY_INF_FIRE = 1,
		LLENEMY_INF_FIRE_G = 1,
		LLENEMY_INF_NECROFIRE = 1,
		LLENEMY_INF_NECROFIRE_G = 1,
		LLENEMY_INF_OIL = 1,
		LLENEMY_INF_OIL_G = 1,
		LLENEMY_INF_POISON = 1,
		LLENEMY_INF_POISON_G = 1,
		LLENEMY_INF_WATER = 1,
		LLENEMY_INF_WATER_G = 1,
		LLENEMY_INF_RANGED = 1,
		LLENEMY_INF_POWER = 1,
		LLENEMY_INF_SHADOW = 2,
		LLENEMY_INF_WARP = 2,
		LLENEMY_BONUS_TREASURE_ROLL = 1,
		LLENEMY_DOUBLE_DIP = 2,
		LLENEMY_PERSEVERANCE_MASTERY = 3,
		LLENEMY_BONUSSKILLS_SINGLE = 2,
		LLENEMY_BONUSSKILLS_SOURCE = 3,
		LLENEMY_BONUSSKILLS_SET_NORMAL = 2,
		LLENEMY_BONUSSKILLS_SET_ELITE = 4,
		LLENEMY_BONUSSKILLS_SET_SOURCE_ELITE = 4,
		LLENEMY_SKILL_MASS_SHACKLES = 1,
		-- Class Upgrades
		LLENEMY_CLASS_GEOPYRO = 3,
		LLENEMY_CLASS_HYDROSHOCK = 3,
		LLENEMY_CLASS_CONTAMINATOR = 3,
		LLENEMY_CLASS_MEDIC = 3,
		LLENEMY_CLASS_TOTEMANCER = 3,
		LLENEMY_CLASS_INCARNATEKING = 3,
		-- Hidden vanilla statuses
		LLENEMY_HERBMIX_COURAGE = 1,
		LLENEMY_HERBMIX_FEROCITY = 1,
		LLENEMY_FARSIGHT = 1,
	},
	--Generated Boosts
	DamageBoostStatuses = {
		["LLENEMY_BOOST_DAMAGE_5"] = DamageBoostText,
		["LLENEMY_BOOST_DAMAGE_10"] = DamageBoostText,
		["LLENEMY_BOOST_DAMAGE_15"] = DamageBoostText,
		["LLENEMY_BOOST_DAMAGE_20"] = DamageBoostText,
		["LLENEMY_BOOST_DAMAGE_25"] = DamageBoostText,
	},
	VitalityBoostStatuses = {
		["LLENEMY_BOOST_VITALITY_5"] = VitalityBoostText,
		["LLENEMY_BOOST_VITALITY_10"] = VitalityBoostText,
		["LLENEMY_BOOST_VITALITY_15"] = VitalityBoostText,
		["LLENEMY_BOOST_VITALITY_20"] = VitalityBoostText,
		["LLENEMY_BOOST_VITALITY_25"] = VitalityBoostText,
		["LLENEMY_BOOST_VITALITY_30"] = VitalityBoostText,
		["LLENEMY_BOOST_VITALITY_35"] = VitalityBoostText,
		["LLENEMY_BOOST_VITALITY_40"] = VitalityBoostText,
		["LLENEMY_BOOST_VITALITY_45"] = VitalityBoostText,
		["LLENEMY_BOOST_VITALITY_50"] = VitalityBoostText,
	},
	ArmorBoostStatuses = {
		["LLENEMY_BOOST_ARMOR_5"] = ArmorBoostText,
		["LLENEMY_BOOST_ARMOR_10"] = ArmorBoostText,
		["LLENEMY_BOOST_ARMOR_15"] = ArmorBoostText,
		["LLENEMY_BOOST_ARMOR_20"] = ArmorBoostText,
		["LLENEMY_BOOST_ARMOR_25"] = ArmorBoostText,
		["LLENEMY_BOOST_ARMOR_30"] = ArmorBoostText,
		["LLENEMY_BOOST_ARMOR_35"] = ArmorBoostText,
		["LLENEMY_BOOST_ARMOR_40"] = ArmorBoostText,
		["LLENEMY_BOOST_ARMOR_45"] = ArmorBoostText,
		["LLENEMY_BOOST_ARMOR_50"] = ArmorBoostText,
	},
	MagicArmorBoostStatuses = {
		["LLENEMY_BOOST_MAGICARMOR_5"] = MagicArmorBoostText,
		["LLENEMY_BOOST_MAGICARMOR_10"] = MagicArmorBoostText,
		["LLENEMY_BOOST_MAGICARMOR_15"] = MagicArmorBoostText,
		["LLENEMY_BOOST_MAGICARMOR_20"] = MagicArmorBoostText,
		["LLENEMY_BOOST_MAGICARMOR_25"] = MagicArmorBoostText,
		["LLENEMY_BOOST_MAGICARMOR_30"] = MagicArmorBoostText,
		["LLENEMY_BOOST_MAGICARMOR_35"] = MagicArmorBoostText,
		["LLENEMY_BOOST_MAGICARMOR_40"] = MagicArmorBoostText,
		["LLENEMY_BOOST_MAGICARMOR_45"] = MagicArmorBoostText,
		["LLENEMY_BOOST_MAGICARMOR_50"] = MagicArmorBoostText,
	},
}

DropText = ts:Create("h623a7ed0gaaacg4c3egacdfg56f3c23a1dec", "<font color='#00FFAA' size='16'>Will drop <textformat leftmargin='1' rightmargin='1'>[1]</textformat> on death.</font>")
ShadowDropText = ts:Create("h662390f7gfd9eg4a56g95e5g658283cc548a", "<font color='#9B30FF' size='16'>Drops Void treasure (<textformat leftmargin='1' rightmargin='1'>[1]</textformat>) on death.</font>")
HiddenDropText = ts:Create("h623a9ed0gaaacg4c3egacdfg56f1c23a1dec", "<font color='#00FFAA' size='16'>Drops ??? on death.</font>")
HiddenShadowDropText = ts:Create("h882390f1gfd9eg4a56g95e5g658283cc548a", "<font color='#9B30FF' size='16'>Drops ??? on death.</font>")

ChallengePointsText = {
	{Tag = "LLENEMY_CP_01", Min = 1, Max = 10, Text = ts:Create("h5addfbc4gcac7g4935g8effg8096574b8913", "<font color='#FFFFFF' size='12'>Regular Loot</font>")},
	{Tag = "LLENEMY_CP_02", Min = 11, Max = 16, Text = ts:Create("h8a442345g8c3ag4161g8f45gd93745f99d3e", "<font color='#4197E2' size='14'>Moderate Loot</font>")},
	{Tag = "LLENEMY_CP_03", Min = 17, Max = 31, Text = ts:Create("hf03d120ag2329g476dg94dcg7df0d27c3e1e", "<font color='#F7BA14' size='16'>Good Loot</font>")},
	{Tag = "LLENEMY_CP_04", Min = 32, Max = 99, Text = ts:Create("h8886e1f1gb725g4e9fg8f5bg4ab1f7262f48", "<font color='#B823CB' size='18'>Great Loot</font>")},
	{Tag = "LLENEMY_CP_05", Min = 100, Max = 999, Text = ts:Create("h99aba0bag7acbg4deagb9f3g0c52b807ce09", "<font color='#FF00CC' size='18'>Amazing Loot</font>")},
}