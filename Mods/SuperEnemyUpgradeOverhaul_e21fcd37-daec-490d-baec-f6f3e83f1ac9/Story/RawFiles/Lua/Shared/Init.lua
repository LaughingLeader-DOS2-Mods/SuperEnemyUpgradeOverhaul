LeaderLib = Mods["LeaderLib"]
GameHelpers = LeaderLib.GameHelpers
Common = LeaderLib.Common
StringHelpers = LeaderLib.StringHelpers

Vars = {
	UPGRADE_MAX_ROLL = 99999,
	DefaultDropCount = 4,
}

---@type table<string, boolean>
IgnoredSkills = {}
---@type string[]
IgnoredWords = {}
--- Skills ignored from the Voidwoken spawning system.
---@type table<string, boolean>
IgnoredSourceSkills = {}
--- Enemy skills used when granting enemies bonus skills.
---@type SkillGroup[]
EnemySkills = {}
---@type table<string, SkillEntry>
EnemySummonSkills = {}
StatusDescriptionParams = {}
HighestLoremaster = 0
InvisibleStatuses = {
	["SNEAKING"] = true,
	["INVISIBLE"] = true,
}
VoiceMetaData = {}
Commands = {
	CHECKLOREMASTER = "CheckLoremaster"
}

Ext.Require("Shared/Classes/Init.lua")

if ItemCorruption == nil then
	ItemCorruption = {}
end

---@type table<string, TagBoost>
ItemCorruption.TagBoosts = Ext.Require("Shared/Data/Corruption/TagBoostEntries.lua")
ItemCorruption.Boosts = {}

---@type table<string, EliteData>
EliteData = Ext.Require("Shared/Data/Elites/_Init.lua")

---@class EUOBoostsScript
---@field Init function Initializes boosts while pulling chances from Data.txt
local boostsScript = Ext.Require("Shared/Data/Corruption/Boosts.lua")

---@class ModBoostInitializer
---@field Init function Checks active mods and adds additional corruption boosts.
local modBoosts = Ext.Require("Shared/Data/Corruption/ModBoosts.lua")

---@type string[]
ItemCorruption.Colors = Ext.Require("Shared/Data/Corruption/Colors.lua")

--ItemCorruption.DeltaMods = Ext.Require("Shared/Data/Corruption/DeltaMods.lua")

---@type string[]
ItemCorruption.Names = Ext.Require("Shared/Data/Corruption/Names.lua")

local statOverrides = Ext.Require("Shared/StatOverrides.lua")
Ext.Require("Shared/VoiceData.lua")
Ext.Require("Shared/SharedUpgradeInfo.lua")
---@type ModSettings
Settings = Ext.Require("Shared/Settings.lua")

local function FixModTypos()
	-- Greed typos
	if Ext.IsModLoaded("d1ba8097-dba1-d74b-7efe-8fca3ef71fe5") then
		local dm = Ext.GetDeltaMod("Boost_Weapon_Status_Set_TankerClub", "Weapon")
		dm.WeaponType = "Club" -- Legendary -> Club
		dm.BoostType = "Legendary" -- Normal -> Legendary
		Ext.UpdateDeltaMod(dm)

		dm = Ext.GetDeltaMod("Gloves_PiercingDamage", "Armor")
		dm.BoostType = "Normal" -- Norma -> Normal
		Ext.UpdateDeltaMod(dm)

		dm = Ext.GetDeltaMod("Gloves_AirDamage", "Armor")
		dm.BoostType = "Normal" -- Norma -> Normal
		Ext.UpdateDeltaMod(dm)
	end
end

function LLENEMY_Shared_InitModuleLoading()
	statOverrides.Init()
	Ext.Print("LLENEMY_Shared.lua] Module is loading.")
	FixModTypos()
end

local function LLENEMY_Shared_SessionLoading()
	Ext.Print("[LLENEMY:Bootstrap.lua] Session is loading.")
	local statuses = Ext.GetStatEntries("StatusData")
	for _,stat in pairs(statuses) do
		local status_type = Ext.StatGetAttribute(stat, "StatusType")
		if status_type == "INVISIBLE" and InvisibleStatuses[stat] == nil then
			InvisibleStatuses[stat] = true
		end
	end

	boostsScript.Init()
	modBoosts.Init()
end
Ext.RegisterListener("SessionLoading", LLENEMY_Shared_SessionLoading)

local function RegisterVoiceMetaData()
	for speaker,entries in pairs(VoiceMetaData) do
		for i,data in pairs(entries) do
			Ext.Print("[LLENEMY_Shared.lua:LLENEMY_ModuleLoading] Registered VoiceMetaData - Speaker[" .. speaker .. "] Handle(" .. tostring(data.Handle) .. ") Source(" .. tostring(data.Source) .. ") Length(" .. tostring(data.Length) .. ")")
			Ext.AddVoiceMetaData(speaker, data.Handle, data.Source, data.Length)
		end
	end
end

Ext.RegisterListener("SessionLoaded", function()
	LeaderLib.EnableFeature("ResistancePenetration")
	LeaderLib.EnableFeature("BackstabCalculation")
	
	LeaderLib.EnableFeature("ApplyBonusWeaponStatuses")
    LeaderLib.EnableFeature("ReplaceTooltipPlaceholders")
	LeaderLib.EnableFeature("TooltipGrammarHelper")
	LeaderLib.EnableFeature("FixChaosDamageDisplay")
	LeaderLib.EnableFeature("StatusParamSkillDamage")
	LeaderLib.EnableFeature("ReduceTooltipSize")
	LeaderLib.EnableFeature("FormatTagElementTooltips")
end)