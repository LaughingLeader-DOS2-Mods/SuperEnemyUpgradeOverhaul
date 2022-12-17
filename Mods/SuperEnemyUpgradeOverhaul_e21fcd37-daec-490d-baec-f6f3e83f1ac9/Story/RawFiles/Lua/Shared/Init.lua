Vars = {
	UPGRADE_MAX_ROLL = 100,
	DefaultDropCount = 4,
	FreezeSkills = {}
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

Mods.LeaderLib.Import(Mods.SuperEnemyUpgradeOverhaul)

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
local initSettings = Ext.Require("Shared/Settings.lua")
---@type ModSettings
Settings = initSettings()

local function FixModTypos()
	-- Greed typos
	if Ext.Mod.IsModLoaded("d1ba8097-dba1-d74b-7efe-8fca3ef71fe5") then
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

Ext.Events.SessionLoaded:Subscribe(function()
	--statOverrides.Init()
	FixModTypos()

	Ext.Utils.Print("[LLENEMY:Bootstrap.lua] Session is loading.")
	local statuses = Ext.GetStatEntries("StatusData")
	for _,stat in pairs(statuses) do
		local status_type = Ext.StatGetAttribute(stat, "StatusType")
		if status_type == "INVISIBLE" and InvisibleStatuses[stat] == nil then
			InvisibleStatuses[stat] = true
		end
	end

	boostsScript.Init()
	modBoosts.Init()

	SettingsManager.AddSettings(Settings)
end)

local function RegisterVoiceMetaData()
	for speaker,entries in pairs(VoiceMetaData) do
		for i,data in pairs(entries) do
			Ext.Utils.Print("[LLENEMY_Shared.lua:LLENEMY_ModuleLoading] Registered VoiceMetaData - Speaker[" .. speaker .. "] Handle(" .. tostring(data.Handle) .. ") Source(" .. tostring(data.Source) .. ") Length(" .. tostring(data.Length) .. ")")
			Ext.AddVoiceMetaData(speaker, data.Handle, data.Source, data.Length)
		end
	end
end

Ext.Events.SessionLoaded:Subscribe(function()
	EnableFeature("ApplyBonusWeaponStatuses")
	EnableFeature("BackstabCalculation")
	EnableFeature("FixChaosDamageDisplay")
	EnableFeature("FormatTagElementTooltips")
	EnableFeature("ReduceTooltipSize")
	EnableFeature("ResistancePenetration")
	EnableFeature("StatusParamSkillDamage")
	EnableFeature("TooltipGrammarHelper")
	EnableFeature("WingsWorkaround")
    EnableFeature("ReplaceTooltipPlaceholders")

	local freezeSkills = {}
	local ignoredKeywords = {"_Quest", "_Status", "_Talent", "_Trap"}

	for _,name in pairs(Ext.GetStatEntries("SkillData")) do
		if not StringHelpers.IsMatch(name, ignoredKeywords, false) then
			local skillProperties = GameHelpers.Stats.GetSkillProperties(name)
			if skillProperties and #skillProperties > 0 then
				for _,prop in pairs(skillProperties) do
					if not Vars.FreezeSkills[name] and prop.Action == "Freeze" then
						Vars.FreezeSkills[name] = true
						if Ext.IsClient() then
							if not SkillTagBonuses.Skill[name] then
								SkillTagBonuses.Skill[name] = {}
							end
							if not Common.TableHasValue(SkillTagBonuses.Skill[name], "LLENEMY_ShadowBonus_BloodyWinter") then
								table.insert(SkillTagBonuses.Skill[name], "LLENEMY_ShadowBonus_BloodyWinter")
							end
						else
							table.insert(freezeSkills, name)
						end
					end
				end
			end
		end
	end

	if Ext.IsServer() then
		ItemBonusManager.RegisterToSkillListener(freezeSkills, ItemBonusManager.AllItemBonuses.BloodyWinter)
	end
end)

if Ext.IsServer() then
	local function SyncAllUpgradeData()
		local upgradeData = {}
		local regionData = PersistentVars.Upgrades.Results[SharedData.RegionData.Current]
		if regionData ~= nil then
			for char,upgrades in pairs(regionData) do
				local netid = char
				local character = Ext.GetCharacter(char)
				if character ~= nil then
					netid = character.NetID
				end
				for i,upgrade in pairs(upgrades) do
					if upgradeData[upgrade.ID] == nil then
						upgradeData[upgrade.ID] = {}
					end
					upgradeData[upgrade.ID][netid] = upgrade.HardmodeOnly
				end
			end
			Ext.PostMessageToUser(id, "LLENEMY_SyncUpgradeData", Ext.JsonStringify(upgradeData))
		end
	end

	Events.SyncData:Subscribe(function (e)
		GameHelpers.Net.PostToUser(e.UserID, "LLENEMY_SetHighestLoremaster", tostring(HighestLoremaster))
	end)

	Ext.RegisterNetListener("LLENEMY_RequestUpgradeInfo", function(cmd, payload)
		local data = Ext.JsonParse(payload)
		if data ~= nil then
			local id = data.ID
			local netid = data.NetID
			local character = Ext.GetCharacter(netid)
			local characterData = UpgradeSystem.GetCharacterData(character.MyGuid)
			if characterData ~= nil then
				local upgradeData = {ID = netid, Upgrades = {}}
				for i,upgrade in pairs(characterData) do
					if not upgrade.HardmodeOnly or (upgrade.HardmodeOnly and Settings.Global:FlagEquals("LLENEMY_HardmodeEnabled", true)) then
						upgradeData.Upgrades[upgrade.ID] = upgrade.HardmodeOnly
					end
				end
				Ext.PostMessageToUser(id, "LLENEMY_SyncUpgradeData", Ext.JsonStringify(upgradeData))
			end
		end
	end)
end
if Ext.IsClient() then
	Ext.RegisterNetListener("LLENEMY_SyncUpgradeData", function(cmd, payload)
		local data = Ext.JsonParse(payload)
		if data ~= nil then
			local id = data.ID
			UpgradeResultData[id] = data.Upgrades
		end
	end)
end