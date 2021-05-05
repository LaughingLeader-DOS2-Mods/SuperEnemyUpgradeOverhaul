local stat_overrides = {
	_NpcDaggers = {
		Talents = "ViolentMagic;Ambidextrous"
	},
	_NpcUnarmed = {
		Talents = "ViolentMagic;Ambidextrous"
	},
	_NpcWands_Water = {
		Talents = "ViolentMagic;Ambidextrous"
	},
	_NpcSwords = {
		Talents = "ViolentMagic;Ambidextrous"
	},
	_NpcAxes = {
		Talents = "ViolentMagic;Ambidextrous"
	},
	_NpcClubs = {
		Talents = "ViolentMagic;Ambidextrous"
	},
	_NpcTwoHandedSwords = {
		Talents = "ViolentMagic"
	},
	_NpcTwoHandedAxes = {
		Talents = "ViolentMagic"
	},
	_NpcTwoHandedMaces = {
		Talents = "ViolentMagic"
	},
	_NpcSpears = {
		Talents = "ViolentMagic"
	},
	_NpcStaffs = {
		Talents = "ViolentMagic;FaroutDude"
	},
	_NpcStaffs_Fire = {
		Talents = "ViolentMagic;FaroutDude"
	},
	_NpcStaffs_Water = {
		Talents = "ViolentMagic;FaroutDude"
	},
	_NpcStaffs_Poison = {
		Talents = "ViolentMagic;FaroutDude"
	},
	_NpcStaffs_Earth = {
		Talents = "ViolentMagic;FaroutDude"
	},
	_NpcStaffs_Air = {
		Talents = "ViolentMagic;FaroutDude"
	},
	_NpcBows = {
		Talents = "ViolentMagic;ElementalRanger"
	},
	_NpcCrossbows = {
		Talents = "ViolentMagic;ElementalRanger"
	},
	_NpcWands_Fire = {
		Talents = "ViolentMagic;Ambidextrous"
	},
	_NpcWands_Air = {
		Talents = "ViolentMagic;Ambidextrous"
	},
	_NpcWands_Poison = {
		Talents = "ViolentMagic;Ambidextrous"
	},
	LLENEMY_TALENT_COUNTER = {
		Description = "LLENEMY_TALENT_COUNTER_EXTENDER_Description",
		DescriptionParams = "CounterChance"
	},
	LLENEMY_ACTIVATE_FLAMING_TONGUES = {
		LeaveAction = "" -- NRD_ApplyActiveDefense instead
	},
	LLENEMY_ACTIVATE_HEALING_TEARS = {
		LeaveAction = "" -- NRD_ApplyActiveDefense instead
	},
	Stats_Herbmix_Courage = {
		StatusIcon = ""--"Item_QUEST_Herbmix_Courage"
	},
	Stats_Herbmix_Ferocity = {
		StatusIcon = ""--"Item_QUEST_Herbmix_Ferocity"
	},
	DEATH_RESIST = {
		StackId = "Stack_Death_Resist"
	},
	MADNESS = {ImmuneFlag="MadnessImmunity"},
	DISARMED = {ImmuneFlag="DisarmedImmunity"},
	BLESSED = {ImmuneFlag="BlessedImmunity"},
	HOLY_WATER = {ImmuneFlag="BlessedImmunity"},
	HOLY_FIRE = {ImmuneFlag="BlessedImmunity"},
	HOLY_FIRE_HEAL = {ImmuneFlag="BlessedImmunity"},
	INVISIBLE = {ImmuneFlag="InvisibilityImmunity"},
	-- So Madness can be cast on allies with Empowered by Madness
	Target_MaddeningSong = {
		TargetConditions = "Character"
	},
	-- So Piercing Immunity doesn't make you immune to deathfog
	DamageSurface_Deathfog = {
		["Damage Type"] = "None"
	},
	Shout_Quest_LureTheKraken = {
		IgnoreSilence = "Yes"
	},
	Shout_Quest_DallisDragonForm = {
		IgnoreSilence = "Yes"
	}
}
local FormatColorOverrides = {
	Fire = {
		"FIRE_BRAND",
		"FIRE_BRAND_AURA",
		"FLAMING_TONGUES",
		"CLEAR_MINDED",
	},
	Healing = {
		"VAMPIRISM",
		"VAMPIRISM_AURA",
		"HEALING_TEARS",
	},
	Summoner = {
		"DEMONIC_TUTELAGE",
	},
	Ranger = {
		"REACTION_SHOT"
	},
	Decay = {
		"DEATH_RESIST",
		"DEATH_WISH",
	}
}

-- v40 and up introduced a way to add talents to NPCs
local talent_belt_overrides = {
	--LLENEMY_TALENT_LONEWOLF = { Items = "", StackId = "Stack_LLENEMY_Talent_LoneWolf"},
	LLENEMY_TALENT_TORTURER = { Items = "", StackId = "Stack_LLENEMY_Talent_Torturer"},
	--LLENEMY_TALENT_UNSTABLE = { Items = "", StackId = "Stack_LLENEMY_Talent_Unstable"},
	LLENEMY_TALENT_WHATARUSH = { Items = "", StackId = "Stack_LLENEMY_Talent_WhatARush"},
	LLENEMY_TALENT_LEECH = { Items = "", StackId = "Stack_LLENEMY_Talent_Leech"},
	LLENEMY_TALENT_QUICKSTEP = { Items = "", StackId = "Stack_LLENEMY_Talent_Quickstep"},
	LLENEMY_TALENT_SADIST = { Items = "", StackId = "Stack_LLENEMY_Talent_Sadist"},
	LLENEMY_TALENT_GLADIATOR = { Items = "", StackId = "Stack_LLENEMY_Talent_Gladiator"},
	LLENEMY_TALENT_HAYMAKER = { Items = "", StackId = "Stack_LLENEMY_Talent_Haymaker"},
	LLENEMY_TALENT_INDOMITABLE = { Items = "", StackId = "Stack_LLENEMY_Talent_Indomitable"},
	LLENEMY_TALENT_SOULCATCHER = { Items = "", StackId = "Stack_LLENEMY_Talent_SoulCatcher"},
	LLENEMY_TALENT_MAGICCYCLES = { Items = "", StackId = "Stack_LLENEMY_Talent_MagicCycles"},
	LLENEMY_TALENT_GREEDYVESSEL = { Items = "", StackId = "Stack_LLENEMY_Talent_GreedyVessel"},
	LLENEMY_TALENT_BACKSTAB = { Items = "", StackId = "Stack_LLENEMY_Talent_Backstab"},
}

-- Statuses displayed in LLENEMY_UPGRADE_INFO
local upgrade_info_statuses = {
	"LLENEMY_TALENT_BACKSTAB",
	"LLENEMY_TALENT_LEECH",
	"LLENEMY_TALENT_LONEWOLF",
	"LLENEMY_TALENT_QUICKSTEP",
	"LLENEMY_TALENT_RANGERRANGE",
	"LLENEMY_TALENT_WHATARUSH",
	"LLENEMY_TALENT_TORTURER",
	"LLENEMY_TALENT_SADIST",
	"LLENEMY_TALENT_HAYMAKER",
	"LLENEMY_TALENT_GLADIATOR",
	"LLENEMY_TALENT_INDOMITABLE",
	"LLENEMY_TALENT_SOULCATCHER",
	--"LLENEMY_TALENT_MASTERTHIEF",
	--"LLENEMY_TALENT_GREEDYVESSEL",
	--"LLENEMY_TALENT_MAGICCYCLES",
	"LLENEMY_INF_NECROFIRE",
	"LLENEMY_INF_NECROFIRE_G",
	"LLENEMY_INF_WATER",
	"LLENEMY_INF_WATER_G",
	"LLENEMY_INF_BLESSED_ICE",
	"LLENEMY_INF_BLESSED_ICE_G",
	"LLENEMY_INF_POISON",
	"LLENEMY_INF_POISON_G",
	"LLENEMY_INF_ACID",
	"LLENEMY_INF_ACID_G",
	"LLENEMY_INF_ELECTRIC",
	"LLENEMY_INF_ELECTRIC_G",
	"LLENEMY_INF_CURSED_ELECTRIC",
	"LLENEMY_INF_CURSED_ELECTRIC_G",
	"LLENEMY_INF_BLOOD",
	"LLENEMY_INF_BLOOD_G",
	"LLENEMY_INF_OIL",
	"LLENEMY_INF_OIL_G",
	"LLENEMY_INF_FIRE",
	"LLENEMY_INF_FIRE_G",
	"LLENEMY_BONUS_TREASURE_ROLL",
	--"LLENEMY_IMMUNITY_LOSECONTROL",
	"LLENEMY_DOUBLE_DIP",
	"LLENEMY_PERSEVERANCE_MASTERY",
	"LLENEMY_BONUSSKILLS_SINGLE",
	"LLENEMY_BONUSSKILLS_SET_NORMAL",
	"LLENEMY_BONUSSKILLS_SOURCE",
	"LLENEMY_BONUSSKILLS_SET_ELITE",
}

local function OverrideStats()
    local total_changes = 0
    local total_stats = 0
    --LeaderLib_7e737d2f-31d2-4751-963f-be6ccc59cd0c
    -- if _G["LeaderLib"] ~= nil or Ext.IsModLoaded("7e737d2f-31d2-4751-963f-be6ccc59cd0c") then
    --     if _G["LeaderLib_Lua_PrintEnabled"] == true then
    --     end
    -- end

    for statname,overrides in pairs(stat_overrides) do
        for property,value in pairs(overrides) do
            --LeaderLib.PrintDebug("LLENEMY_StatOverrides.lua] Overriding stat: " .. statname .. " (".. property ..") = \"".. value .."\"")
            Ext.StatSetAttribute(statname, property, value)
            total_changes = total_changes + 1
        end
        total_stats = total_stats + 1
	end

	for statname,overrides in pairs(talent_belt_overrides) do
		for property,value in pairs(overrides) do
			--LeaderLib.PrintDebug("LLENEMY_StatOverrides.lua] Overriding stat: " .. statname .. " (".. property ..") = \"".. value .."\"")
			Ext.StatSetAttribute(statname, property, value)
			total_changes = total_changes + 1
		end
		total_stats = total_stats + 1
	end

	--LeaderLib.PrintDebug("LLENEMY_StatOverrides.lua] Enabling v42+ enhancements.")
	--LeaderLib.PrintDebug("==============================================================")
	--LeaderLib.PrintDebug("LLENEMY_StatOverrides.lua] (Upgrade Info) enabled. Hiding statuses used for info.")
	for _,statname in pairs(upgrade_info_statuses) do
		Ext.StatSetAttribute(statname, "Icon", "")
		total_changes = total_changes + 1
		total_stats = total_stats + 1
	end
	--LeaderLib.PrintDebug("==============================================================")

	for color,tbl in pairs(FormatColorOverrides) do
		for _,stat in pairs(tbl) do
			Ext.StatSetAttribute(stat, "FormatColor", color)
		end
	end

	-- Gravedigger_be822931-e829-4555-b50f-3b80b6f17d86
	if Ext.IsModLoaded("be822931-e829-4555-b50f-3b80b6f17d86") then
		Ext.StatSetAttribute("WPN_LLENEMY_ShadowTreasure_Shovel_2H", "Skills", "Target_HeavyAttack;Target_LLGRAVE_Dig")
	end
	LeaderLib.PrintDebug("LLENEMY_StatOverrides.lua] Changed ("..tostring(total_changes)..") properties in ("..tostring(total_stats)..") stats (added talents to enemy weapons).")
end

return {
	Init = OverrideStats
}