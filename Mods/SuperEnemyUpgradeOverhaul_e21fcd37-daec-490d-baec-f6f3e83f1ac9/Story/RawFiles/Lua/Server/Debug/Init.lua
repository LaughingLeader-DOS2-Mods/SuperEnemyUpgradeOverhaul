local character_stats = {
	"CurrentVitality",
	"CurrentArmor",
	"CurrentMagicArmor",
	"ArmorAfterHitCooldownMultiplier",
	"MagicArmorAfterHitCooldownMultiplier",
	"CurrentAP",
	"BonusActionPoints",
	"Experience",
	"Reputation",
	"Flanked",
	"Karma",
	"MaxVitality",
	"BaseMaxVitality",
	"MaxArmor",
	"BaseMaxArmor",
	"MaxMagicArmor",
	"BaseMaxMagicArmor",
	"Sight",
	"BaseSight",
	"MaxSummons",
	"BaseMaxSummons"
}

local character_stats_computed = {
	"MaxMp",
	"APStart",
	"APRecovery",
	"APMaximum",
	"Strength",
	"Finesse",
	"Intelligence",
	"Vitality",
	"Memory",
	"Wits",
	"Accuracy",
	"Dodge",
	"CriticalChance",
	"FireResistance",
	"EarthResistance",
	"WaterResistance",
	"AirResistance",
	"PoisonResistance",
	"ShadowResistance",
	"CustomResistance",
	"LifeSteal",
	"Sight",
	"Hearing",
	"Movement",
	"Initiative",
	"ChanceToHitBoost"
}

function TraceCharacterStats_Restricted(char)
	Ext.Print("====== Stats: "..tostring(char).." ======")
	Ext.Print("==== COMPUTED ====")
	for _,stat in pairs(character_stats_computed) do
		Ext.Print(stat..": "..tostring(Common.Dump(char[stat])))
	end
	Ext.Print("==== REGULAR ====")
	for _,stat in pairs(character_stats) do
		Ext.Print(stat..": "..tostring(Common.Dump(char[stat])))
	end
end

function TraceCharacterStats(char)
	Ext.Print("====== Stats: "..tostring(char).." ======")
	Ext.Print("==== COMPUTED ====")
	for _,stat in pairs(character_stats_computed) do
		local base = NRD_CharacterGetComputedStat(char, stat, 1)
		local current = NRD_CharacterGetComputedStat(char, stat, 0)
		Ext.Print(stat..": "..tostring(current).."("..tostring(base)..")")
	end
	Ext.Print("==== REGULAR ====")
	for _,stat in pairs(character_stats) do
		local val = NRD_CharacterGetStatInt(char, stat)
		Ext.Print(stat..": "..tostring(val))
	end
end

function InitDebugLevel()
	local char = "Lizards_Hero_Male_Undead_000_09478f32-8fbf-4502-a59d-011e4d1b3d4d"
	ApplyStatus(char, "LLENEMY_RAGE", -1.0, 1, char)

	local host = CharacterGetHostCharacter()
	CharacterApplyPreset(host, "Rogue_Act2")
	--CharacterLevelUpTo(host, 10)
	CharacterAddAbility(host, "Loremaster", 10)
	CharacterAddAttribute(host, "Memory", 20)
	--CharacterTransformAppearanceToWithEquipmentSet(host, host, "ArenaRogue", 0)
	for k,skill in pairs(Ext.GetSkillSet("ArenaRogue").Skills) do
		CharacterAddSkill(host, skill, 0)
	end
	
	CharacterRemoveSkill(host, "Projectile_Chloroform")
	CharacterAddSkill(host, "Projectile_Chloroform", 0)
	CharacterAddSkill(host, "Target_EnemyFlurry", 0)
	NRD_SkillBarSetSkill(host, 0, "Projectile_Chloroform")

	local slots = Osi.DB_LeaderLib_EquipmentSlots:Get(nil)
	for k,v in pairs(slots) do
		local slot = v[1]
		local item = CharacterGetEquippedItem(host, slot)
		if item ~= nil then
			ItemLevelUpTo(host, 10)
		end
	end

	--ApplyStatus(host, "LLENEMY_TALENT_BULLY", -1.0, 1, host)
	CharacterSetImmortal(host, 1)
end

function Debug_TraceItemOwnership(item)
	local inventoryOwner = GetInventoryOwner(item)
	local inventoryOwnerOwner = GetInventoryOwner(inventoryOwner)
	local goblinOwner = ItemGetOwner(item)
	Ext.Print("[Debug_TraceItemOwnership] item("..tostring(item)..") inventoryOwner("..tostring(inventoryOwner)..") inventoryOwnerOwner("..tostring(inventoryOwnerOwner)..") goblinOwner("..tostring(goblinOwner)..")")
end

function DumpUpgradeTables()
	print(Ext.JsonStringify(Upgrades))
end

function Debug_TraceStats(char)
	local stats = nil
	local character = Ext.GetCharacter(char)
	if character ~= nil then
		stats = character.Stats.Name
	end
	if stats == nil then stats = GetStatString(char) end
	if stats ~= nil then
		Osi.LeaderLog_Log("DEBUG", "[LLENEMY_Debug.lua:Debug_TraceStats] Character's instance stat ID is (",stats,")")
	end
end

function Debug_RerollLevel(char)
	local character = Ext.GetCharacter(char)
	if character ~= nil then
		SetVarFixedString(char, "LLENEMY_Debug_Stats", character.Stats.Name)
	end
	SetStoryEvent(char, "LLENEMY_Debug_SetStats")
	CharacterRemoveAttribute(char, "Dummy", 0)
	CharacterAddAttribute(char, "Dummy", 0)
	--CharacterAddExplorationExperience(char, 1, 1, 1)
	--Ext.Print("[LLENEMY_ExperienceScaling:Debug_RerollLevel] Leveling up (".. char ..").")
	--CharacterLevelUp(char)
	--Ext.Print("[LLENEMY_ExperienceScaling:Debug_RerollLevel] Transforming (".. char ..").")
	--CharacterTransformFromCharacter(char, char, 1, 1, 1, 1, 1, 1, 1)
	--Transform(char, "57b70554-36bf-4b86-b9aa-8f7cc3944153", 1, 1, 1)
	--Ext.Print("[LLENEMY_ExperienceScaling:Debug_RerollLevel] Leveling up (".. char ..").")
	--CharacterLevelUpTo(char, 3)
	--CharacterLevelUp(char)
end

local debugCheckEnemies = {
	"S_FTJ_SeekerCaptain_1329f018-23e4-4717-9bc8-074b28d04c54"
}

function CheckFactions()
	for i,uuid in pairs(debugCheckEnemies) do
		if ObjectExists(uuid) == 1 then
			local name = CharacterGetDisplayName(uuid)
			Ext.Print("[CheckFactions] ["..uuid.."]("..name..") faction ("..GetFaction(uuid)..")")
		end
	end
end

local function LLENEMY_DebugInit()
	Ext.Print("[LLENEMY:Debug.lua:LLENEMY_DebugInit] Running debug tests.")
	local host = CharacterGetHostCharacter()
	local user = CharacterGetReservedUserID(host)
	local profile = GetUserName(user)
	if string.find(profile, "LaughingLeader") then
		if CharacterGetEquippedWeapon(host) == nil then
			local inventory = Ext.GetCharacter(host):GetInventoryItems()
			for k,v in pairs(inventory) do
				local stat = NRD_ItemGetStatsId(v)
				if NRD_StatGetType(stat) == "Weapon" then
					CharacterEquipItem(host, v)
				end
			end
		end
		ObjectSetFlag(host, "FTJ_RemoveSourceCollar", 0)
		CharacterOverrideMaxSourcePoints(host, 30)
		CharacterAddSourcePoints(host, 30)
		CharacterAddSkill(host, "Projectile_EnemyChainLightning", 0)
		CharacterAddSkill(host, "Shout_EnemyElectricFence", 0)
		CharacterAddSkill(host, "Shout_EnemyNecromancerTotems", 0)
		CharacterAddSkill(host, "Storm_EnemyLightning", 0)
		CharacterAddSkill(host, "ProjectileStrike_EnemyShatteredStone", 0)
		CharacterAddSkill(host, "Target_EnemyRestoration", 0)
		--ApplyStatus(host, "LLENEMY_VENOM_AURA", -1.0, 1, host)
		--ApplyStatus(host, "LLENEMY_FIRE_BRAND_AURA", -1.0, 1, host)
		--local barrel = CreateItemTemplateAtPosition("0ae0668f-418c-46c4-bcbb-1683aa3c68e3", x, y, z)
		--TeleportTo(barrel, host)
		--NRD_Summon(host, "e63a712f-fc87-4469-8848-fd8941043afd", x, y, z, -1, 1, 1, 1)
		--NRD_Summon(host, "26f10a2d-910c-42ed-b629-9a3ce550c1f7", x, y, z, -1, 1, 1, 1)
		--CharacterSetImmortal(host, 1)
		--VoidWokenSpawning.Spawn(host, 0, true)
	end

	if Ext.IsDeveloperMode() then
		GlobalSetFlag("LLENEMY_Ext_IsDeveloperMode")
	else
		GlobalClearFlag("LLENEMY_Ext_IsDeveloperMode")
	end

	VoidWokenSpawning.GetSourceDegredation(300000, 50)
end

function Debug_PrintFlags(obj)
	local stat = nil
	if ObjectIsItem(obj) == 1 then
		stat = NRD_ItemGetStatsId(obj)
	elseif ObjectIsCharacter(obj) then
		stat = NRD_CharacterGetStatString(obj)
	end
	Ext.Print("[Debug_PrintFlags] Object ("..tostring(stat)..")["..tostring(obj).."] Flags:")
	Ext.Print("==========================")
	for i=0,72,1 do
		local flagVal = NRD_ObjectGetInternalFlag(obj,i)
		Ext.Print("["..tostring(i).."] = "..tostring(flagVal))
	end
	Ext.Print("==========================")
end

function Debug_PrintTags(uuid)
	SetTag(uuid, "DEBUGGING")
	local character = Ext.GetCharacter(uuid)
	if character ~= nil then
		Osi.LLSENEMY_Debug_SaveNetID(character.NetID)
		Ext.Print("[LLENEMY_Debug.lua:PrintTags] Tags for ("..tostring(uuid)..") Name("..NRD_CharacterGetStatString(uuid, "Name")..") NetID("..tostring(character.NetID)..") character.Stats.NetID("..tostring(character.Stats.NetID).."):")
		Ext.Print("==========================")
		Ext.Print(Common.Dump(character:GetTags()))
		Ext.Print("==========================")
	end
end

function Debug_PrintTagsOnClient()
	local data = Ext.JsonStringify(Osi.DB_LLSENEMY_Debug_PrintTags:Get(nil))
	Ext.Print("[LLENEMY_Debug.lua:PrintTagsOnClient] Broadcasting data to clients ("..data..")")
	Ext.BroadcastMessage("LLENEMY_Debug_PrintTags", data, nil)
end

local ItemProperties = {
	"MyGuid",
	"WorldPos",
	"CurrentLevel",
	"Scale",
	"CurrentTemplate",
	"CustomDisplayName",
	"CustomDescription",
	"CustomBookContent",
	"StatsId",
	"InventoryHandle",
	"ParentInventoryHandle",
	"Slot",
	"Amount",
	"Vitality",
	"Armor",
	"InUseByCharacterHandle",
	"Key",
	"LockLevel",
	"ComputedVitality",
	"ItemType",
	"GoldValueOverwrite",
	"WeightValueOverwrite",
	"TreasureLevel",
	"LevelOverride",
	"ForceSynch",
}

function Debug_PrintItemProperties(obj)
	local item = Ext.GetItem(obj)
	local stat = NRD_ItemGetStatsId(obj)
	Ext.Print("[Debug_PrintItemProperties] Object ("..tostring(stat)..")["..tostring(obj).."] Properties:")
	Ext.Print("==========================")
	for i,prop in pairs(ItemProperties) do
		Ext.Print("["..tostring(prop).."] = "..tostring(item[prop]))
	end
	Ext.Print("==========================")
end

BuiltinColorCodes = {
    [0] = "#FFFFFF",
    "#454545",
    "#AE9F95", -- Physical
    "#DBDBDB",
    "#CD1F1F", -- Pure/None, Piercing, Chaos
    "#188EDE",
    "#078FC8",
    "#CFECFF",
    "#7DC807",
    "#00AA00",
    "#FCD203",
    "#FF9600",
    "#FFC3C3",
    "#7F00FF",
    "#B97A57",
    "#C7A758", -- Custom / Sulfuric?
    "#000000",
    "#FFFFFF",
    "#D040D0",
    "#797980", -- Corrosive, Shadow
    "#65C900", -- Poison
    "#F7BA14", -- Earth
    "#7D71D9", -- Air
    "#4197E2", -- Water
    "#FE6E27", -- Fire
    "#46B195",
    "#B823CB",
    "#F7BA14",
    "#81AB00",
    "#639594",
    "#B260FF",
    "#73F6FF",
    "#DA2512",
    "#C9AA58",
    "#97FBFF",
    "#FFB8B8",
    "#FFAB00",
    "#7F00FF",
    "#F10000",
    "#00893A",
    "#403625",
    "#00547F",
    "#FFFFFF",
    "#9A6A46",
    "#745035",
    "#AA3938",
    "#ED9D07",
    "#FCD203",
    "#88A25B",
    "#34789C",
    "#D66565",
    "#D85B00",
    "#E4CE93",
    "#CD1F1F",
    "#318666",
    "#3C6983",
    "#85662F",
    "#87365C",
    "#F1D466",
    "#008858",
    "#CD1F1F",
    "#13D177",
    "#FCD203",
    "#188EDE",
}

local groupColours = {
	"#FFFFFF",
	"#FFCC00",
	"#FF9600",
	"#FF00CC",
	"#FE6E27",
	"#F7BA14",
	"#CD1F1F",
	"#C80030",
	"#C7A758",
	"#AE9F95",
	"#A3894A",
	"#A1D7BF",
	"#97FBFF",
	"#92755F",
	"#7DC807",
	"#7D71D9",
	"#70B10E",
	"#65C900",
	"#564132",
	"#4197E2",
	"#078FC8",
	"#078FC8"
}

local groupValueColours = {
	"#FFFFFF",
	"#FFCC00",
	"#FF9600",
	"#FF00CC",
	"#FE6E27",
	"#F7BA14",
	"#CD1F1F",
	"#C80030",
	"#C7A758",
	"#AE9F95",
	"#A3894A",
	"#A1D7BF",
	"#92755F",
	"#7DC807",
	"#7D71D9",
	"#70B10E",
	"#65C900",
	"#564132",
	"#4197E2",
	"#078FC8"
}